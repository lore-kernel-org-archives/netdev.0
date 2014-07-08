From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_tunnel: fix ip_tunnel_lookup
Date: Tue, 08 Jul 2014 15:12:10 -0700 (PDT)
Message-ID: <20140708.151210.1879376103263511218.davem@davemloft.net>
References: <20140705022637.73152ff57309c468c1fdb563@qrator.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ixaphire@qrator.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140705022637.73152ff57309c468c1fdb563@qrator.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Popov <ixaphire@qrator.net>
Date: Sat, 5 Jul 2014 02:26:37 +0400

> @@ -205,6 +207,8 @@ struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
>  
>  	hlist_for_each_entry_rcu(t, head, hash_node) {
>  		if (t->parms.i_key != key ||
> +		    t->parms.iph.saddr != 0 ||
> +		    t->parms.iph.daddr != 0 ||
>  		    !(t->dev->flags & IFF_UP))
>  			continue;
>  

I don't really understand the logic of these tests.

Usually the canonical way to test these kinds of things is:

	if (parms->saddr && parms->saddr != saddr)
		goto no_match;

But you are signalling a non-match any time the address is not a
wildcard.

Why?
