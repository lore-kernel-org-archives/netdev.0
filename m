From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 af-packet 2/2] Enhance af-packet to provide
 (near zero)lossless packet capture functionality.
Date: Fri, 19 Aug 2011 03:36:13 -0700 (PDT)
Message-ID: <20110819.033613.1959565749346388734.davem@davemloft.net>
References: <1313116260-1000-1-git-send-email-loke.chetan@gmail.com>
	<1313116260-1000-3-git-send-email-loke.chetan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: loke.chetan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47185 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054Ab1HSKgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 06:36:16 -0400
In-Reply-To: <1313116260-1000-3-git-send-email-loke.chetan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chetan Loke <loke.chetan@gmail.com>
Date: Thu, 11 Aug 2011 22:31:00 -0400

> +struct kbdq_ft_ops {
> +	int num_ops;
> +	void (*ft_ops[2])(void *, void *);
> +};
...
> +	struct kbdq_ft_ops kfops;
 ...
> +static void prb_init_ft_ops(struct kbdq_core *p1,
> +			union tpacket_req_u *req_u)
> +{
> +	p1->kfops.ft_ops[p1->kfops.num_ops++] = prb_fill_vlan_info;
> +
> +	if (req_u->req3.tp_feature_req_word) {
> +		if (req_u->req3.tp_feature_req_word & TP_FT_REQ_FILL_RXHASH)
> +			p1->kfops.ft_ops[p1->kfops.num_ops++] = prb_fill_rxhash;
> +		else
> +			p1->kfops.ft_ops[p1->kfops.num_ops++] =
> +			prb_clear_rxhash;
> +	}
> +}

It is a lot cheaper to just test the flags in-line than do indirect calls.
Indirect calls are very expensive on many cpus.

In fact, since the first op (prb_fill_vlan_info) is unconditional, we eat
the indirect call cost for absolutely no reason at all.

This kfops stuff was not present in your previous changes.  And I'm
going to tell you that if you keep adding things each revision instead
of just fixing the specific items you've received feedback about, a
set of changes this invasive and of this size will never get merged.

Please resist the urge to further tinker with the code, and just
address the feedback we give you.
