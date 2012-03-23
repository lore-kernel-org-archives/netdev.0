From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: NETDEV_ALIGN should match L1_CACHE_BYTES
Date: Thu, 22 Mar 2012 22:57:56 -0400 (EDT)
Message-ID: <20120322.225756.1072869324737577667.davem@davemloft.net>
References: <1332454760.6521.9.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59947 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756612Ab2CWC57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 22:57:59 -0400
In-Reply-To: <1332454760.6521.9.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 22 Mar 2012 15:19:20 -0700

> 32 bytes alignment had a meaning 10 years ago, it is not anymore the
> case.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

This value is supposed to conceptually be ARCH_DMA_MINALIGN.

Drivers, like the AMD Lance, would DMA in and out of the netdev
private struct.  And as such DMA alignments have to be adhered
to.

There is way too much ISA and ancient crap out there to mess with
this, I think.  Maybe we could set it to ARCH_DMA_MINALIGN (you'd need
to use a CPP test since architectures are not required to set this,
and use L1_CACHE_BYTES if it's not).  But certainly we can't
unilaterally change it to L1_CACHE_BYTES.
