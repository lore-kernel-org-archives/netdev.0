From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: propogate MTU changes
Date: Tue, 07 Oct 2008 16:05:53 -0700 (PDT)
Message-ID: <20081007.160553.78745069.davem@davemloft.net>
References: <48EA98F0.40302@trash.net>
	<48EA9CCC.2050505@hp.com>
	<48EAA05B.20004@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, shemminger@vyatta.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57429
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754370AbYJGXGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 19:06:18 -0400
In-Reply-To: <48EAA05B.20004@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 07 Oct 2008 01:33:47 +0200

> Rick Jones wrote:
> > Patrick McHardy wrote:
> >> Rick Jones wrote:
> >>
> >>> Patrick McHardy wrote:
> >>>
> >>>> Agreed. But the question when to do automatic adjustments remains.
> >>>
> >>>
> >>> A matter of interpretation of the principle of least surprise right? Which is less surprising - that a VLAN's MTU drops to match that of the physical interface or that some traffic on the VLAN stops when the physical interface's MTU drops?
> >>
> >>
> >> The traffic actually shouldn't stop since the MTU isn't enforced by
> >> the lower layers and also usually not by the driver. So I feel unable
> >> to make a policy decision when both views don't seem unreasonable.
> >> Especially given the fact that the "more suprising" behaviour so far
> >> has been our default.
> > Does changing the MTU on a physical interface not change the size frame the NIC itself will be willing to accept?
> 
> IIRC a lot of the simpler ones just use the default eth_setup change_mtu
> callback and the ones that have their one (just had a very brief look at
> sky2, tg3 and e1000) only seem to use it indirectly for enabling jumbo
> frame support and (e1000) memory allocation.
> 
> So I guess what we should do in case of the MTU depends on what we can
> expect from the majority of hardware. If its just some older drivers
> which can be reasonably expected to handle larger frames we should cap
> at the maximum of the real device and maybe introduce the "desired
> mtu" you suggested. It would be useful if people more familiar with
> the drivers and hardware than me could comment on this.

Since there is no agreement on exactly what we should be doing, I'm
tossing this from my patch queue.

I will say, however, that our current behavior isn't so horrible. :)

