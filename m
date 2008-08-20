From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [Patch RFC 01/10 v2] mlx4_en: mlx4_en header file
Date: Wed, 20 Aug 2008 09:46:00 -0700
Message-ID: <adabpznprcn.fsf@cisco.com>
References: <48AC1556.20801@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.co.il>, tziporet@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:58636 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753384AbYHTQqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 12:46:04 -0400
In-Reply-To: <48AC1556.20801@mellanox.co.il> (Yevgeny Petrilin's message of
	"Wed, 20 Aug 2008 16:00:06 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > +enum {
 > +	MLX4_EN_FLAG_MSI_X      = 1 << 1,
 > +	MLX4_EN_FLAG_HIGH_DMA   = 1 << 2,
 > +	MLX4_EN_FLAG_FW_RUNNING = 1 << 3
 > +};

I can't find anywhere that any of these flags are used?

 > +#ifdef MLX4_EN_PREFETCH
 > +	#define PREFETCH(x)	prefetch(x)
 > +#else
 > +	#define PREFETCH(x)	do {} while (0)
 > +#endif

Probably better to figure out if you want to prefetch or not rather than
having this compile-time option.  Probably not, given that HW
prefetchers keep getting better.

 > +#define ROUNDUP_LOG2(x)		ilog2(roundup_pow_of_two(x))

<linux/log2.h> calls this order_base_2()

 > +#define XNOR(x, y)		(!(x) == !(y))

I think I said this before, but given that you only use this once, it
would be clearer to just open-code it there.



 - R.
