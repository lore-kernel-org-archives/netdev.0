From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net: Fix tentative IPv6 address due to DAD looping back
Date: Fri, 12 Apr 2013 22:03:53 +0200
Message-ID: <20130412200353.GA23992@order.stressinduktion.org>
References: <D6EA916C7149064CB4D5C686612478A3183E2D27D1@MX34A.corp.emc.com> <027526AF93736D4380632CD4F3B42B80030B85@MX101CL02.corp.emc.com> <20130412175141.GA30292@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: "Meng, Jilin" <Jilin.Meng@emc.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"Sun, Yinglin" <yinglin.sun@emc.com>,
	"Prithviraj, Lakshmanan" <lakshmanan.prithviraj@emc.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:40701 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752909Ab3DLUDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 16:03:55 -0400
Content-Disposition: inline
In-Reply-To: <20130412175141.GA30292@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 12, 2013 at 07:51:41PM +0200, Hannes Frederic Sowa wrote:
> On Fri, Apr 12, 2013 at 07:45:54AM +0000, Meng, Jilin wrote:
> > This version accepted David's comments of coding style, Eric's comments of ether_addr_equal_64bits(), and Hannes' comments of eth_hdr(), etc.
> > 
> > we should ignore the looped-back IPv6 DAD packet to avoid configuration failure.
> > This occurs when a bonding interface with roundrobin mode is being configured an IPv6 address while the switch side isn't configured bonding/channel yet.
> [...]
> What do you think if we hook up a function which does reenable ipv6 on
> an interface as soon as 'disable_ipv6' is switched to '0'? So you could
> control reacquiring the ipv6 address from userspace without ifup&ifdown
> and the risk of disturbing ipv4 connections? This seems to be the
> easiest solution (but have not checked thoroughly).
> [...]

I just looked into it and it does already worked as expected. Didn't know why
I assumed that there was only a disable handler. So you can resolve this issue
from userspace by a timer or a small program which listens for loopback
traffic in userspace and do DAD after the loop is resolved. I think this is a
more sensible solution.

Thanks,

  Hannes
