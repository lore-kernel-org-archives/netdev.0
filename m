From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH] cxgb3: Keep LRO off if disabled when interface is down
Date: Sun, 11 Jan 2009 21:10:54 -0800
Message-ID: <496AD0DE.2020009@chelsio.com>
References: <adaljtimh4m.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:19839 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791AbZALFLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 00:11:52 -0500
In-Reply-To: <adaljtimh4m.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roland Dreier wrote:
> I have a system with a Chelsio adapter (driven by cxgb3) whose ports are
> part of a Linux bridge.  Recently I updated the kernel and discovered
> that things stopped working because cxgb3 was doing LRO on packets that
> were passed into the bridge code for forwarding.  (Incidentally, this
> problem manifested itself in a strange way that made debugging a bit
> interesting -- for some reason, the skb_warn_if_lro() check in bridge
> didn't trigger and these LROed packets were forwarded out a forcedeth
> interface, and caused the forcedeth transmit path to get stuck)
> 
> This is because cxgb3 has no way of keeping state for the LRO flag until
> the interface is brought up, so if the bridging code disables LRO while
> the interface is down, then cxgb3_up() will just reenable LRO, and on my
> Debian system at least, the init scripts add interfaces to a bridge
> before bringing the interfaces up.
> 
> Fix this by keeping track of each interface's LRO state in cxgb3 so that
> when bridge disables LRO, it stays disabled in cxgb3_up() when the
> interface is brought up.  I did this by changing the rx_csum_offload
> flag into a pair of bit flags; the effect of this on the rx_eth() fast
> path is miniscule enough that it should be fine (eg on x86, a cmpb
> instruction becomes a testb instruction).
> 

Hi Roland, thanks a lot for finding and fixing this bug.

Cheers,
Divy
