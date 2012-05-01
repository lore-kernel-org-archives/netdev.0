From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH net-next] netem: add ECN capability
Date: Tue, 1 May 2012 11:28:50 +0200
Message-ID: <20120501092849.GB3453@hell>
References: <1335863465.11396.45.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:42730 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754392Ab2EAJiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 05:38:03 -0400
Content-Disposition: inline
In-Reply-To: <1335863465.11396.45.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nice!


* Eric Dumazet | 2012-05-01 11:11:05 [+0200]:

> 	u32 loss;
>+	u32 ecn;

Why no bool here Eric?

> 	u32 limit;
> 	u32 counter;
> 	u32 gap;
>@@ -374,9 +376,12 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
> 		++count;
> 
> 	/* Drop packet? */
>-	if (loss_event(q))
>-		--count;
>-
>+	if (loss_event(q)) {
>+		if (q->ecn && INET_ECN_set_ce(skb))
>+			sch->qstats.drops++; /* mark packet */
>+		else
>+			--count;
>+	}
> 	if (count == 0) {
> 		sch->qstats.drops++;
> 		kfree_skb(skb);
>@@ -706,6 +711,7 @@ static const struct nla_policy netem_policy[TCA_NETEM_MAX + 1] = {
> 	[TCA_NETEM_CORRUPT]	= { .len = sizeof(struct tc_netem_corrupt) },
> 	[TCA_NETEM_RATE]	= { .len = sizeof(struct tc_netem_rate) },
> 	[TCA_NETEM_LOSS]	= { .type = NLA_NESTED },
>+	[TCA_NETEM_ECN]		= { .type = NLA_U32 },

This netem API, what a heck ... Ideal we would extend TCA_NETEM_LOSS
somehow[tm], but yes ... ;(

Acked-by: Hagen Paul Pfeifer <hagen@jauu.net>
