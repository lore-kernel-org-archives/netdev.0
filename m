From: Dave Jones <davej@redhat.com>
Subject: Re: via-velocity dma-debug warnings again. (2.6.35.2)
Date: Wed, 1 Sep 2010 16:05:55 -0400
Message-ID: <20100901200555.GA30689@redhat.com>
References: <20100831111052.31f22185@marrow.netinsight.se>
 <20100831172106.GC1844@redhat.com>
 <20100901122059.5761802f@marrow.netinsight.se>
 <20100901.130333.148556201.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: simon.kagstrom@netinsight.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43469 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754246Ab0IAUGM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 16:06:12 -0400
Content-Disposition: inline
In-Reply-To: <20100901.130333.148556201.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 01, 2010 at 01:03:33PM -0700, David Miller wrote:
 > From: Simon Kagstrom <simon.kagstrom@netinsight.net>
 > Date: Wed, 1 Sep 2010 12:20:59 +0200
 > 
 > > I'm not really an expert on the subject, but with skb_headlen(), the size
 > > should be the same for pci_map_single and pci_unmap_single as far as I
 > > can tell.
 > 
 > That's not the case.
 > 
 > You'll have to use exactly the same formula for computing the length
 > as the pci_map_single() call uses, which is:
 > 
 > 	pktlen = skb_shinfo(skb)->nr_frags == 0 ?
 > 			max_t(unsigned int, skb->len, ETH_ZLEN) :
 > 				skb_headlen(skb);
 > 
 > Otherwise packets smaller than ETH_ZLEN will be unmapped properly
 > and trigger the same kind of debugging checks Dave is seeing.

Looks like you're right.

[ 5674.506024] via-velocity 0000:00:0e.0: DMA-API: device driver frees DMA memory with different size [device address=0x0000000018e555fa] [map size=54 bytes] [unmap size=108 bytes]

	Dave

