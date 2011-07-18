From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v3 af-packet 2/2] Enhance af-packet to provide
 (near zero)lossless packet capture functionality.
Date: Sun, 17 Jul 2011 20:46:30 -0700
Message-ID: <1310960790.2286.39.camel@Joe-Laptop>
References: <1310959610-1688-1-git-send-email-loke.chetan@gmail.com>
	 <1310959610-1688-3-git-send-email-loke.chetan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Chetan Loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4110 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755140Ab1GRDqb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jul 2011 23:46:31 -0400
In-Reply-To: <1310959610-1688-3-git-send-email-loke.chetan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-07-17 at 23:26 -0400, Chetan Loke wrote:
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
[]
> +#define V3_ALIGNMENT	(8)
> +#define ALIGN_V3(x)	(((x)+V3_ALIGNMENT-1)&~(V3_ALIGNMENT-1))

Maybe just use the kernel.h macro ALIGN()?

> +#define BLK_HDR_LEN	(ALIGN_V3(sizeof(struct block_desc)))

So this becomes:
#define BLK_HDR_LEN	ALIGN(sizeof(struct block_desc), V3_ALIGNMENT)


