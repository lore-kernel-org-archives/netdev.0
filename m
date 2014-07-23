From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2] skbedit: allow the user to specify bitmask for mark
Date: Wed, 23 Jul 2014 18:39:17 +0200
Message-ID: <1406133557.3363.11.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1406102589-8441-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com,
	Antonio Quartulli <antonio@open-mesh.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Antonio Quartulli <antonio@meshcoding.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:45014 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757425AbaGWQjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 12:39:31 -0400
Received: by mail-wg0-f41.google.com with SMTP id z12so1494358wgg.24
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 09:39:30 -0700 (PDT)
In-Reply-To: <1406102589-8441-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-07-23 at 10:03 +0200, Antonio Quartulli wrote:
> From: Antonio Quartulli <antonio@open-mesh.com>
> 


>  
> @@ -160,6 +174,10 @@ static int tcf_skbedit_dump(struct sk_buff *skb, struct tc_action *a,
>  	    nla_put(skb, TCA_SKBEDIT_MARK, sizeof(d->mark),
>  		    &d->mark))
>  		goto nla_put_failure;
> +	if ((d->flags & SKBEDIT_F_MASK) &&
> +	    nla_put(skb, TCA_SKBEDIT_MASK, sizeof(d->mask),
> +		    &d->mark))

typo here : d->mask is better.

Or even better :

	nla_put_u32(skb, TCA_SKBEDIT_MASK, d->mask)

> +		goto nla_put_failure;
>  	t.install = jiffies_to_clock_t(jiffies - d->tcf_tm.install);
>  	t.lastuse = jiffies_to_clock_t(jiffies - d->tcf_tm.lastuse);
>  	t.expires = jiffies_to_clock_t(d->tcf_tm.expires);
