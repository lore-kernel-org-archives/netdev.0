From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: add driver for Netronome NFP4000/NFP6000 NIC
 VFs
Date: Mon, 26 Oct 2015 18:23:07 -0700 (PDT)
Message-ID: <20151026.182307.873190227567325622.davem@davemloft.net>
References: <1445626691-19819-1-git-send-email-jakub.kicinski@netronome.com>
	<1445626691-19819-3-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rolf.neugebauer@netronome.com,
	jason.mcmullan@netronome.com, simon.horman@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34694 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750859AbbJ0BG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 21:06:28 -0400
In-Reply-To: <1445626691-19819-3-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Fri, 23 Oct 2015 19:58:11 +0100

> +struct nfp_net_tx_buf {
> +	struct sk_buff *skb;
> +	dma_addr_t dma_addr;
> +	short int fidx;
> +	u16 pkt_cnt;
> +	u32 real_len;
> +};

This packs very poorly, and has a lot of padding holes.  Better ordering
would be:

struct nfp_net_tx_buf {
	struct sk_buff *skb;
	dma_addr_t dma_addr;
	u32 real_len;
	short int fidx;
	u16 pkt_cnt;
};

You really should audit the most core datastructures in this driver
for the same problem.
