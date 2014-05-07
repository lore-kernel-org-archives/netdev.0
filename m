From: Brian Lilly <brian@crystalfontz.com>
Subject: Re: i.MX28 based system losing eth0 on boot
Date: Wed, 7 May 2014 12:00:02 -0700
Message-ID: <CAOk88BJm2n2X8=pbREZWYceaDdwT47pppzdkF7mf+7cYA9yAMA@mail.gmail.com>
References: <CAOk88BLR=nwNGdT++39vLdOt=TwZmemF-trSQPY8AdMN9tKtKQ@mail.gmail.com>
 <CAOMZO5C4GiLu3sGPxuEDX+cVOvXsk=z9iqLSvZX8HzpncJuJOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?Q?Uwe_Kleine=2DK=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Jim Baxter <jim_baxter@mentor.com>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f44.google.com ([209.85.219.44]:37001 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969AbaEGTAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 15:00:43 -0400
Received: by mail-oa0-f44.google.com with SMTP id i11so1783182oag.17
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 12:00:42 -0700 (PDT)
In-Reply-To: <CAOMZO5C4GiLu3sGPxuEDX+cVOvXsk=z9iqLSvZX8HzpncJuJOw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moving forward to 3.15.0-rc4 merged with Russell's FEC patches makes it much
more noisy  (http://pastebin.com/17TyyMPn):

Populating dev cache
Configuring network interfaces... [   26.268156] fec 800f0000.ethernet
eth0: MDIO write timeout
[   26.298087] fec 800f0000.ethernet eth0: MDIO read timeout
[   26.328074] fec 800f0000.ethernet eth0: MDIO write timeout
[   26.358077] fec 800f0000.ethernet eth0: MDIO read timeout
[   26.388070] fec 800f0000.ethernet eth0: MDIO write timeout
[   26.393631] fec 800f0000.ethernet eth0: could not attach to PHY
ip: SIOCSIFFLAGS: Connection timed out
Starting rpcbind daemon...rpcbind: cannot create socket for udp6
rpcbind: cannot create socket for tcp6
done.
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.rp_filter = 1
INIT: Entering runlevel: 5
Starting Xserver
Starting system message bus: dbus.
Starting Connection Manager
Starting wpa_supplicant
Successfully initialized wpa_supplicant
Starting Dropbear SSH server: dropbear.
starting Busybox UDHCP Server: u[   31.129045] fec 800f0000.ethernet
eth0: MDIO write timeout
dhcpd... [   31.158388] fec 800f0000.ethernet eth0: MDIO read timeout
[   31.188437] fec 800f0000.ethernet eth0: MDIO write timeout
done.
[   31.218260] fec 800f0000.ethernet eth0: MDIO read timeout
[   31.248256] fec 800f0000.ethernet eth0: MDIO write timeout
[   31.253830] fec 800f0000.ethernet eth0: could not attach to PHY
Starting syslogd/klogd: done

from dmesg:

[   26.268156] fec 800f0000.ethernet eth0: MDIO write timeout
[   26.298087] fec 800f0000.ethernet eth0: MDIO read timeout
[   26.328074] fec 800f0000.ethernet eth0: MDIO write timeout
[   26.358077] fec 800f0000.ethernet eth0: MDIO read timeout
[   26.388070] fec 800f0000.ethernet eth0: MDIO write timeout
[   26.393631] fec 800f0000.ethernet eth0: could not attach to PHY
[   31.129045] fec 800f0000.ethernet eth0: MDIO write timeout
[   31.158388] fec 800f0000.ethernet eth0: MDIO read timeout
[   31.188437] fec 800f0000.ethernet eth0: MDIO write timeout
[   31.218260] fec 800f0000.ethernet eth0: MDIO read timeout
[   31.248256] fec 800f0000.ethernet eth0: MDIO write timeout
[   31.253830] fec 800f0000.ethernet eth0: could not attach to PHY

I can go back and cull the timeout bits in 3.12 or 3.14 and report
back if you think that it'd be helpful ...

Please let me know if you have any questions.

Thank you.

Brian Lilly
Crystalfontz America, Incorporated
12412 East Saltese Road
Spokane Valley, WA 99216
brian@crystalfontz.com http://www.crystalfontz.com
Twitter: @Crystalfontz
US toll-free (888) 206-9720 voice (509) 892-1200


On Tue, May 6, 2014 at 8:17 PM, Fabio Estevam <festevam@gmail.com> wrote:
> Brian,
>
> On Tue, May 6, 2014 at 1:44 PM, Brian Lilly <brian@crystalfontz.com> wrote:
>> Uwe:
>>
>> With commit a264b981f2c76e281ef27e7232774bf6c54ec865 we're having eth0
>> come up, then brought right back down with an MDIO rx timeout moments
>> after.  Adding back in the removed code keeps the interface alive and
>> it's working afterward without trouble.  I've tested the re-inserted
>> code in 3.12, 3.14 without issue on our boards.
>>
>> Is there something else that can be done to prevent the MDIO timeouts?
>> We are using basically the same schematic for networking as the
>> imx28evk.
>>
>> Any thoughts on how to resolve this?
>
> Could you try the latest Russell's FEC patches available at?
>  http://ftp.arm.linux.org.uk/cgit/linux-arm.git/log/?h=fec-testing
>
> In particular this one could help with your "MDIO timeout" issue:
> http://ftp.arm.linux.org.uk/cgit/linux-arm.git/commit/?h=fec-testing&id=ec1fac3de70b16c69d3edc9f223e91d56b1915de
