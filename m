From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next 3/3] tcp: use dctcp if enabled on the route to
 the initiator
Date: Fri, 28 Aug 2015 14:18:58 -0700 (PDT)
Message-ID: <20150828.141858.298466824970321801.davem@davemloft.net>
References: <1440763869-23067-1-git-send-email-fw@strlen.de>
	<1440763869-23067-4-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55979 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752624AbbH1VS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 17:18:59 -0400
In-Reply-To: <1440763869-23067-4-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri, 28 Aug 2015 14:11:09 +0200

> @@ -418,10 +418,13 @@ enum {
>  
>  #define RTAX_MAX (__RTAX_MAX - 1)
>  
> -#define RTAX_FEATURE_ECN	0x00000001
> -#define RTAX_FEATURE_SACK	0x00000002
> -#define RTAX_FEATURE_TIMESTAMP	0x00000004
> -#define RTAX_FEATURE_ALLFRAG	0x00000008
> +#define RTAX_FEATURE_ECN	(1 << 0)
> +#define RTAX_FEATURE_SACK	(1 << 1)
> +#define RTAX_FEATURE_TIMESTAMP	(1 << 2)
> +#define RTAX_FEATURE_ALLFRAG	(1 << 3)
> +#define RTAX_FEATURE_ECN_CA	(1 << 4)
> +
> +#define RTAX_FEATURE_MASK_ECN	(RTAX_FEATURE_ECN | RTAX_FEATURE_ECN_CA)

I don't know about this.

You're adding a new user visible feature bit, but...

The user can set it and silently the kernel will accept it, but this
bit is ignored.

Regardless of it's internal value, we never publish it to the user.

This is just asking for trouble, and it's a bit sloppy if you ask me.

I think you're going to need to hold this piece of state outside of
the metric value, sorry.
