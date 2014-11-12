From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next 1/1] ipvlan: Initial check-in of the IPVLAN driver.
Date: Tue, 11 Nov 2014 18:46:20 -0800
Message-ID: <CAF2d9jj+CjcDpk5Ke-X1L7v_YGOC6cTzA1ssKC29mHmZ7FgzWQ@mail.gmail.com>
References: <1415744984-25802-1-git-send-email-maheshb@google.com>
 <CAHA+R7OZxCLFYetGHONWkL7uzGur=xSc=ASBT4i5EEeS2Xzwog@mail.gmail.com>
 <1415748160.2292.8.camel@localhost> <CAHA+R7MgjOKuVY_egNz2SOWZG6X2rkFGfcaP0PiMKc_YVKAULA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Hannes Frederic Sowa <hannes@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	Laurent Chavey <chavey@google.com>,
	Tim Hockin <thockin@google.com>,
	David Miller <davem@davemloft.net>,
	Brandon Philips <brandon.philips@coreos.com>,
	Pavel Emelianov <xemul@parallels.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f181.google.com ([209.85.220.181]:53613 "EHLO
	mail-vc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754461AbaKLCqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 21:46:42 -0500
Received: by mail-vc0-f181.google.com with SMTP id hy10so5017178vcb.12
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 18:46:41 -0800 (PST)
In-Reply-To: <CAHA+R7MgjOKuVY_egNz2SOWZG6X2rkFGfcaP0PiMKc_YVKAULA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 11, 2014 at 4:39 PM, Cong Wang <cwang@twopensource.com> wrote:
> On Tue, Nov 11, 2014 at 3:22 PM, Hannes Frederic Sowa <hannes@redhat.com> wrote:
>> On Di, 2014-11-11 at 15:12 -0800, Cong Wang wrote:
>>> On Tue, Nov 11, 2014 at 2:29 PM, Mahesh Bandewar <maheshb@google.com> wrote:
>>> > This driver is very similar to the macvlan driver except that it
>>> > uses L3 on the frame to determine the logical interface while
>>> > functioning as packet dispatcher. It inherits L2 of the master
>>> > device hence the packets on wire will have the same L2 for all
>>> > the packets originating from all virtual devices off of the same
>>> > master device.
>>>
>>> Why do we need this from the beginning?
>>> IOW, what problem does this solve while macvlan doesn't?
>>
>> I think it is good to reduce the number of mac addresses before a NIC
>> switches into promisc mode.
>>
>
> Sounds like over-kill to have a new device just for not worrying about mac.
> Or you mean our neigh table doesn't scale?

I do not think this is a neigh-table scaling issue and certainly wont
feel it's a over kill. It's addressing the need that macvlan does not
address. Having said that, this certainly does not mean that this is
the replacement of macvlan driver.

(Linux) Hosts could be connected to devices with stricter security
policies allowing only a mac per port it's connected to barring the
use of devices like macvlan. This would mean that you need something
like ipvlan type of device to address that need. Also as Hannes has
mentioned, burning more macs per port and putting the NIC in promisc
mode is taxing for performance. That could be avoided by using ipvlan.

At LPC there was another talk / discussion about using pure L2 device
in docker container was a security concern
(http://www.linuxplumbersconf.net/2014/ocw//system/presentations/1959/original/lxc-security-issues.pdf)

However, point taken, I will summarize all this macvlan to ipvlan
comparison and add into the document that is part of this patch.

Thanks,
--mahesh..
