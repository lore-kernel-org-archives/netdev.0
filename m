From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] changing value of NETDEV_ALIGN to cacheline size
Date: Mon, 15 May 2006 14:30:11 -0700 (PDT)
Message-ID: <20060515.143011.36635008.davem@davemloft.net>
References: <200605151408.29688.borntrae@de.ibm.com>
	<20060515080258.bdcfba5f.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: borntrae@de.ibm.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:11145
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751644AbWEOVa2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 17:30:28 -0400
To: rdunlap@xenotime.net
In-Reply-To: <20060515080258.bdcfba5f.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Randy.Dunlap" <rdunlap@xenotime.net>
Date: Mon, 15 May 2006 08:02:58 -0700

> > -#define	NETDEV_ALIGN		32
> > +#define	NETDEV_ALIGN		L1_CACHE_BYTES
> >  #define	NETDEV_ALIGN_CONST	(NETDEV_ALIGN - 1)
> 
> I don't know about the fixed value of 32, but if this patch is
> accepted, I'd prefer NETDEV_ALIGN_MASK instead of NETDEV_ALIGN_CONST.

The reason it's 32 is that old drivers depended on the
struct being at least 32-byte aligned because they would
embed structures DMA'd to/from the card in their private
area and just assumed that would be aligned enough for
the card's restrictions.

So setting it to L1_CACHE_BYTES would be wrong, because if
that happens to be less than 32 it would violate said
assumption which we are catering to.
