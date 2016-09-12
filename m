From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 25/26] pch_gbe: constify local structures
Date: Mon, 12 Sep 2016 11:07:15 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1609121058580.3049@hadrien>
References: <1473599168-30561-1-git-send-email-Julia.Lawall@lip6.fr>        <1473599168-30561-26-git-send-email-Julia.Lawall@lip6.fr> <20160911.194819.1394072668837372328.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, joe@perches.com,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:1471 "EHLO
        mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756630AbcILJHk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 05:07:40 -0400
In-Reply-To: <20160911.194819.1394072668837372328.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sun, 11 Sep 2016, David Miller wrote:

>
> Julia, I went over the networking driver patches in this series and
> I have to say that I'd rather see these changes be more durable
> and self-checking.
>
> By this I mean that I want you to also make the driver private pointer
> that holds these structures be const too.

Sorry, I'm not sure what you are asking for.  In these cases, we often end
up with something like:

static const struct foo = { ... };

and then later

xxx.ops = foo;

So foo is protected, but its lifetime of interest is quite short.  But we
can't set the ops field of the type of xxx to be const either, because it
is obviously not - the code above modifies it.  Everything would be fine
if ops were of pointer type but not structure type, but that is not the
case in this patch series, because the semantic patch disallows &foo.
There is the __ro_after_init annotation that might help in some cases, but
I have often seen these assignments in probe functions that are not
__init.  Kees Cook mentioned some code that could be inserted before and
after an assignment to make a field temporarily writeable, but I haven't
looked into that possibility yet.

Have I misunderstood something?

thanks,
julia

> Then if there are really any assignments to the objects being marked
> const, it will show immediately.
>
> Thank you.
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
