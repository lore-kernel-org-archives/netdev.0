From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] fib_rules: don't break ECN with TOS rules
Date: Mon, 13 Jun 2016 23:49:45 +0200
Message-ID: <1465854585.1443672.636616881.5FACCAD4@webmail.messagingengine.com>
References: <1465679423-27414-1-git-send-email-hannes@stressinduktion.org>
 <c5fb0fbf-6b8e-a479-198a-817ff9071d74@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:57310 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752701AbcFMVtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 17:49:47 -0400
In-Reply-To: <c5fb0fbf-6b8e-a479-198a-817ff9071d74@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 13, 2016, at 00:18, David Ahern wrote:
> On 6/11/16 3:10 PM, Hannes Frederic Sowa wrote:
> > @@ -215,6 +216,9 @@ static int fib4_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
> >  	rule4->dst_len = frh->dst_len;
> >  	rule4->dstmask = inet_make_mask(rule4->dst_len);
> >  	rule4->tos = frh->tos;
> > +	if (!INET_ECN_ignore(rule4->tos))
> > +		pr_warn("ipv4: never matching ipv4 rule with match for %x added\n",
> > +			rule4->tos);
> >
> 
> The wording of the warning message is not very clear on what the problem
> is.

I will redesign this whole patch and will improve those warnings, too.

Thanks,
Hannes
