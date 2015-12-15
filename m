From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v5 net-next 4/4] ila: Add generic ILA translation facility
Date: Tue, 15 Dec 2015 08:06:58 +0100
Message-ID: <20151215070658.GA16703@breakpoint.cc>
References: <1450137408-2589240-1-git-send-email-tom@herbertland.com>
 <1450137408-2589240-5-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:57405 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752746AbbLOHHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 02:07:04 -0500
Content-Disposition: inline
In-Reply-To: <1450137408-2589240-5-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <tom@herbertland.com> wrote:
> +static int ila_add_mapping(struct net *net, struct ila_xlat_params *p)
> +{
> +	struct ila_net *ilan = net_generic(net, ila_net_id);
> +	struct ila_map *ila, *head;
> +	spinlock_t *lock = ila_get_lock(ilan, p->identifier);
> +	int err = 0, order;
> +
> +	if (!ilan->hooks_registered) {
> +		/* We defer registering net hooks in the namespace until the
> +		 * first mapping is added.
> +		 */
> +		err = nf_register_net_hooks(net, ila_nf_hook_ops,
> +					    ARRAY_SIZE(ila_nf_hook_ops));
> +		if (err)
> +			return err;

Looks as if this misses a
		ilan->hooks_registered = true
> +	}
> +
> +	ila = kzalloc(sizeof(*ila), GFP_KERNEL);
