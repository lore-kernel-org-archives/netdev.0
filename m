From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v3] fib_rules: Added NLM_F_EXCL support to fib_nl_newrule
Date: Tue, 28 Jun 2016 19:10:52 -0600
Message-ID: <9eece57e-cc3b-3dc2-9aac-3b3e05219dd7@cumulusnetworks.com>
References: <577267A8.4020101@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Mateusz Bajorski <mateusz.bajorski@nokia.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33642 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752466AbcF2BLM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 21:11:12 -0400
Received: by mail-pa0-f47.google.com with SMTP id b13so11576824pat.0
        for <netdev@vger.kernel.org>; Tue, 28 Jun 2016 18:10:53 -0700 (PDT)
In-Reply-To: <577267A8.4020101@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/28/16 6:03 AM, Mateusz Bajorski wrote:
> diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
> index 98298b1..fa0c3ff 100644
> --- a/net/core/fib_rules.c
> +++ b/net/core/fib_rules.c
> @@ -269,6 +269,46 @@ errout:
>  	return err;
>  }
>
> +static int rule_exists(struct fib_rules_ops *ops, struct fib_rule_hdr *frh,
> +		       struct nlattr **tb, struct fib_rule *rule)
> +{
> +	struct fib_rule *r;
> +
> +	list_for_each_entry(r, &ops->rules_list, list) {
> +		if (r->action != rule->action)
> +			continue;
> +
> +		if (r->table != rule->table)
> +			continue;
> +
> +		if (r->pref != rule->pref)
> +			continue;
> +
> +		if (memcmp(r->iifname, rule->iifname, IFNAMSIZ))
> +			continue;
> +
> +		if (memcmp(r->oifname, rule->oifname, IFNAMSIZ))
> +			continue;
> +
> +		if (r->mark != rule->mark)
> +			continue;
> +
> +		if (r->mark_mask != rule->mark_mask)
> +			continue;
> +
> +		if (r->tun_id != rule->tun_id)
> +			continue;
> +
> +		if (r->fr_net != rule->fr_net)
> +			continue;
> +
> +		if (!ops->compare(r, frh, tb))
> +			continue;

l3mdev attribute snuck in a couple of weeks ago. You need to compare 
r->l3mdev != rule->l3mdev
