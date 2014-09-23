From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv6 net-next 1/3] sunvnet: upgrade to VIO protocol
 version 1.6
Date: Tue, 23 Sep 2014 14:44:32 -0400 (EDT)
Message-ID: <20140923.144432.343377380510348797.davem@davemloft.net>
References: <541AD838.50700@oracle.com>
	<20140923.122420.1216927815526255624.davem@davemloft.net>
	<5421A497.9060903@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Raghuram.Kothakota@oracle.com, netdev@vger.kernel.org
To: david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36927 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbaIWSof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 14:44:35 -0400
In-Reply-To: <5421A497.9060903@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <david.stevens@oracle.com>
Date: Tue, 23 Sep 2014 12:49:27 -0400

> Actually, that's exactly what I've been working on for the last few
> days. I hope to post this soon. Currently, I allow for misaligned
> packets by reallocating the skbs with the proper alignment, skip and
> length restrictions, so the code can handle either, but still copies
> most of the time. Once I have all the kinks worked out there, I was
> planning to possibly make *all* skb allocations on LDOMs and/or SPARC64 fit
> those requirements, since they are compatible with the existing alignments
> and would allow using the HV copy in any case.

You should be able to avoid the copy on TX almost all of the time.

If you do a skb_push(skb, VNET_PACKET_SKIP) (and initialize with some
garbage bytes) it ought to be aligned.

If not, we could tool around with the hard_header_ops to make
things come out the way we need it to.
