From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Fix sk_buff page offsets and lengths.
Date: Wed, 01 Aug 2007 13:44:06 -0700 (PDT)
Message-ID: <20070801.134406.59657351.davem@davemloft.net>
References: <20070730.185028.26532012.davem@davemloft.net>
	<20070731105215.b7e1044c.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfr@canb.auug.org.au,
	shemminger@linux-foundation.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48740
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751245AbXHAUoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2007 16:44:09 -0400
In-Reply-To: <20070731105215.b7e1044c.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 31 Jul 2007 10:52:15 +0200

> I understand ifdefs are ugly, but in the common case
> (PAGE_SIZE<64K), this change seems very unfortunate.

If this bothers you so much start where the real problems are and
advocate on linux-kernel for descreasing the type size of "offset" and
"length" in struct scatterlist.  It's a bit on the hypocritical side
to complain about this skb_frag_t change when I've never seen a peep
out of you about scatterlist doing the same thing :-)

Otherwise, we're better off with the types being the same so that we
can use scatterlist in skb_frag_t and therefore kill serious
performance problems with DMA mapping of sk_buff objects that exists
today on platforms such as powerpc.

