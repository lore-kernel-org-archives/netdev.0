From: David Miller <davem@davemloft.net>
Subject: Re: via-velocity dma-debug warnings again. (2.6.35.2)
Date: Wed, 01 Sep 2010 13:03:33 -0700 (PDT)
Message-ID: <20100901.130333.148556201.davem@davemloft.net>
References: <20100831111052.31f22185@marrow.netinsight.se>
	<20100831172106.GC1844@redhat.com>
	<20100901122059.5761802f@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org
To: simon.kagstrom@netinsight.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33728
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754357Ab0IAUDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 16:03:17 -0400
In-Reply-To: <20100901122059.5761802f@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Date: Wed, 1 Sep 2010 12:20:59 +0200

> I'm not really an expert on the subject, but with skb_headlen(), the size
> should be the same for pci_map_single and pci_unmap_single as far as I
> can tell.

That's not the case.

You'll have to use exactly the same formula for computing the length
as the pci_map_single() call uses, which is:

	pktlen = skb_shinfo(skb)->nr_frags == 0 ?
			max_t(unsigned int, skb->len, ETH_ZLEN) :
				skb_headlen(skb);

Otherwise packets smaller than ETH_ZLEN will be unmapped properly
and trigger the same kind of debugging checks Dave is seeing.
