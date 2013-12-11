From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 06/13] bna: UDP RX Processing Improvements
Date: Tue, 10 Dec 2013 21:11:20 -0500 (EST)
Message-ID: <20131210.211120.1956754760208726379.davem@davemloft.net>
References: <1386481724-32367-7-git-send-email-rmody@brocade.com>
	<20131209.191755.1735369355458133155.davem@davemloft.net>
	<E5313AF6F2BFD14293E5FD0F94750F86B69010DB7B@HQ1-EXCH01.corp.brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@Brocade.COM
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53657 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750960Ab3LKCLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 21:11:25 -0500
In-Reply-To: <E5313AF6F2BFD14293E5FD0F94750F86B69010DB7B@HQ1-EXCH01.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Tue, 10 Dec 2013 16:05:46 -0800

> By having the bnad_rx_unmap structure marked as __packed we were trying to
> reduce the unmap_q size by 16K, __packed would ensure the RX unmap
> structure of 40 bytes is packed to 32 bytes. This change was also captured
> as a part of the commit message of patch #6 under change details.

Do you have any idea what the costs are on certain architectures
for adding this attribute?

When you mark something __packed, the compiler can no longer assume
anything about the alignment of any instance of that structure, nor
nor any structure which is contained within that type either.

So the compiler will, for example, emit byte by byte operations
to load multi-byte quantities on architectures where unaligned
data accesses can trap.

You should only use __packed as the extreme, very last resort method
to achieve a certain goal.  Frankly I think it should never be used
except in cases where layout is dictated by a network protocol or
hardware descriptor _AND_ the layout cannot be achieved using portable
fixed sized types.
