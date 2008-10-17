From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 0/6] Add qdisc->ops->peek() support.
Date: Fri, 17 Oct 2008 22:45:43 +0200
Message-ID: <20081017204543.GB2527@ami.dom.local>
References: <20081016220905.GA2747@ami.dom.local> <48F88613.1060404@trash.net> <20081017130333.GA8297@ff.dom.local> <48F89D33.9090809@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.183]:42430 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752763AbYJQUoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 16:44:09 -0400
Received: by ik-out-1112.google.com with SMTP id c30so590835ika.5
        for <netdev@vger.kernel.org>; Fri, 17 Oct 2008 13:44:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48F89D33.9090809@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 17, 2008 at 04:12:03PM +0200, Patrick McHardy wrote:
...
> Some general thoughts ...
>
> We've never had any systematic checks for useful and non-useful
> combination of qdiscs, which is causing a lot of these complications.
> Think of all the multiq work that was required to make it work
> properly with non-work-conserving qdiscs - while at the same time,
> using a non-work-conserving qdisc (which require a global view)
> defeats basically all of the benefits.
>
> So it would be really useful to come up with a systematic definition
> of valid combinations instead of trying handling lots of purely
> theoretical case that don't make sense. One more example - all the
> qdiscs implement ->drop(), yet its only needed by CBQ and it doesn't
> make any sense at all to use lets say HFSC as child of CBQ.
>
> About this specific case - yes, it would break compatibility for
> users using f.i. TBF as child of netem. But if you look at the
> netem_enqueue() function, it in fact assumes that the inner qdisc
> is a tfifo, so we'd be breaking an already broken case. We can
> of course be nice and warn about it for a few releases, but I believe
> there is some real potential for simplification that makes it
> worth it.

I'm not sure this is all right: at least until there is not too much
problems with some code (like with requeuing). We probably should try
before this official ways like feature-removal-schedule.txt, and/or
maybe some CONFIG_XXX_DEPRECATED things. But I don't persist with this.

BTW, I'm not sure if I'm expected to redo any patches in this thread.
(Probably some things like this teql_peek() could be removed with
->requeue() killing.)

Jarek P.
