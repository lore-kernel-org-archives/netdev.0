From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/15] Neighbour table and ax25 cleanups
Date: Mon, 02 Mar 2015 16:44:26 -0500 (EST)
Message-ID: <20150302.164426.494515497595921630.davem@davemloft.net>
References: <20150301.230306.2023670900391030920.davem@davemloft.net>
	<871tl8dlxn.fsf@x220.int.ebiederm.org>
	<87lhjg9byo.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org,
	linux-hams@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54182 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753543AbbCBVoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 16:44:32 -0500
In-Reply-To: <87lhjg9byo.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sun, 01 Mar 2015 23:59:11 -0600

> While looking at the neighbour table to what it would take to allow
> using next hops in a different address family than the current packets
> I found a partial resolution for my issues and I stumbled upon some
> work that makes the neighbour table code easier to understand and
> maintain.
> 
> Long ago in a much younger kernel ax25 found a hack to use
> dev_rebuild_header to transmit it's packets instead of going through
> what today is ndo_start_xmit.
> 
> When the neighbour table was rewritten into it's current form the ax25
> code was such a challenge that arp_broken_ops appeard in arp.c and
> neigh_compat_output appeared in neighbour.c to keep the ax25 hack alive.
> 
> With a little bit of work I was able to remove some of the hack that
> is the ax25 transmit path for ip packets and to isolate what remains
> into a slightly more readable piece of code in ax25_ip.c.  Removing the
> need for the generic code to worry about ax25 special cases.
> 
> After cleaning up the old ax25 hacks I also performed a little bit of
> work on neigh_resolve_output to remove the need for a dst entry and to
> ensure cached headers get a deterministic protocol value in their cached
> header.   This guarantees that a cached header will not be different
> depending on which protocol of packet is transmitted, and it allows
> packets to be transmitted that don't have a dst entry.  There remains
> a small amount of code that takes advantage of when packets have a dst
> entry but that is something different.

Wow... simply, wow.

I thought we'd be stuck with that crap forever, great work!

Applied to net-next, thanks again!
