From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] fib_rules: don't break ECN with TOS rules
Date: Sun, 12 Jun 2016 16:18:07 -0600
Message-ID: <c5fb0fbf-6b8e-a479-198a-817ff9071d74@cumulusnetworks.com>
References: <1465679423-27414-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:37777 "EHLO
	mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932891AbcFLWSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 18:18:06 -0400
Received: by mail-it0-f42.google.com with SMTP id e5so31329192ith.0
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 15:18:05 -0700 (PDT)
In-Reply-To: <1465679423-27414-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/11/16 3:10 PM, Hannes Frederic Sowa wrote:
> @@ -215,6 +216,9 @@ static int fib4_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
>  	rule4->dst_len = frh->dst_len;
>  	rule4->dstmask = inet_make_mask(rule4->dst_len);
>  	rule4->tos = frh->tos;
> +	if (!INET_ECN_ignore(rule4->tos))
> +		pr_warn("ipv4: never matching ipv4 rule with match for %x added\n",
> +			rule4->tos);
>

The wording of the warning message is not very clear on what the problem is.
