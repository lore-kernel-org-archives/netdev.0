From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 1/19] [NETNS] Add netns parameter to
 fib_rules_(un)register.
Date: Thu, 20 Dec 2007 15:46:36 -0800 (PST)
Message-ID: <20071220.154636.86238588.davem@davemloft.net>
References: <4769370F.5020303@openvz.org>
	<1198077889-10693-2-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benjamin.thery@bull.net, dlezcano@fr.ibm.com, devel@openvz.org,
	containers@lists.osdl.org, netdev@vger.kernel.org, xemul@openvz.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32787
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754548AbXLTXqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 18:46:37 -0500
In-Reply-To: <1198077889-10693-2-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Wed, 19 Dec 2007 18:24:31 +0300

> @@ -101,14 +101,12 @@ static inline u32 frh_get_table(struct fib_rule_hdr *frh, struct nlattr **nla)
>  	return frh->table;
>  }
>  
> -extern int			fib_rules_register(struct fib_rules_ops *);
> -extern int			fib_rules_unregister(struct fib_rules_ops *);
> -extern void                     fib_rules_cleanup_ops(struct fib_rules_ops *);
> +extern int fib_rules_register(struct net *, struct fib_rules_ops *);
> +extern int fib_rules_unregister(struct net *, struct fib_rules_ops *);
> +extern void fib_rules_cleanup_ops(struct fib_rules_ops *);
>  
> -extern int			fib_rules_lookup(struct fib_rules_ops *,
> -						 struct flowi *, int flags,
> -						 struct fib_lookup_arg *);
> -extern int			fib_default_rule_add(struct fib_rules_ops *,
> -						     u32 pref, u32 table,
> -						     u32 flags);
> +extern int fib_rules_lookup(struct fib_rules_ops *, struct flowi *, int flags,
> +			    struct fib_lookup_arg *);
> +extern int fib_default_rule_add(struct fib_rules_ops *, u32 pref, u32 table,
> +				u32 flags);
>  #endif

Please do not make gratuitous coding style changes like this!

What bothers you so much that there is lots of whitespace there after
the "extern int"?  Does it bother you so much that you think the side
effect of your patch being unreadable is worth it?!?!

Why is it unreadable?  I'm glad you asked....

Just like me, someone will have to read this over carefully to
see what you're actually doing.

Are you deleting all the existing declarations and adding new
ones with different names?

Are you deleting some of them, but keeping others yet changing
the arguments to them somehow?

Are you deleting some of them, but masterbating with the coding
style of others?

NOBODY KNOWS!

Whereas if you just deleted the lines for the functions you
are removing, it would be totally clear what is happening.

This patch, from a reviewability standpoint, sucks.  It makes
efficient patch review next to impossible.

I'm not looking at the rest of this patch set, clean this stuff up and
resubmit it all, thank you.
