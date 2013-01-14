From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] CDC_NCM adding support IFF_NOARP for infineon modem
 platform
Date: Mon, 14 Jan 2013 11:19:13 -0600
Message-ID: <1358183953.1713.28.camel@dcbw.foobar.com>
References: <1357990479-5836-1-git-send-email-cpuwolf@gmail.com>
	 <20130112.153533.1713284383322153346.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: cpuwolf@gmail.com, gregkh@linuxfoundation.org,
	alexey.orishko@stericsson.com, bjorn@mork.no,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45924 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756522Ab3ANRQn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2013 12:16:43 -0500
In-Reply-To: <20130112.153533.1713284383322153346.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-01-12 at 15:35 -0800, David Miller wrote:
> From: Wei Shuai <cpuwolf@gmail.com>
> Date: Sat, 12 Jan 2013 19:34:39 +0800
> 
> > Infineon(now Intel) HSPA Modem platform NCM cannot support ARP. so I
> > introduce a flag CDC_NCM_DRIVER_DATA_NOARP which is defined in
> > driver_info:data. so later on, if more such buggy devices are found,
> > they could use same flag to handle.
> 
> Is it no able to do ARP or, the more likely case, does broadcast
> not work at all?
> 
> If it's the latter, IFF_NOARP is just making over the real problem.
> 
> I'm not applying this, no hardware device should set IFF_NOARP.
> You probably really want IFF_POINTOPOINT or similar.

IFF_NOARP is already done for other WWAN devices (sierra_net, hso,
cdc-ether, cdc-phonet, lg-vl600, etc) so there is some precedent.  Some
drivers (phonet, hso) set *both* POINTTOPOINT and NOARP.  Is that
redundant, and should all WWAN drivers be moved to only POINTTOPOINT?

(aside: usbnet has FLAG_POINTTOPOINT, but that's nothing to do with
IFF_POINTTOPOINT, it only controls whether the interface is named usbX
or ethX.  Confusing.)

Dan
