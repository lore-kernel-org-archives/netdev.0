From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/11] batman-adv: randomize initial seqno to avoid
 collision
Date: Tue, 17 Apr 2012 22:45:27 -0400 (EDT)
Message-ID: <20120417.224527.288514574622832184.davem@davemloft.net>
References: <1334663907-22725-1-git-send-email-ordex@autistici.org>
	<1334663907-22725-4-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	lindner_marek@yahoo.de
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32966 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751693Ab2DRCsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 22:48:39 -0400
In-Reply-To: <1334663907-22725-4-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Tue, 17 Apr 2012 13:58:19 +0200

> @@ -33,6 +33,11 @@
>  static void bat_iv_ogm_iface_enable(struct hard_iface *hard_iface)
>  {
>  	struct batman_ogm_packet *batman_ogm_packet;
> +	unsigned long random_seqno;
> +
> +	/* randomize initial seqno to avoid collision */
> +	get_random_bytes(&random_seqno, sizeof(unsigned long));
> +	atomic_set(&hard_iface->seqno, (uint32_t)random_seqno);

This is silly.

Just use "uint32_t" for the type of random_seqno and the sizeof passed
to get_random_bytes.

And here comes the magic part.

Amazing, no ugly and pointless casts needed!
