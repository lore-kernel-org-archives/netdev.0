From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] namespace: Remove no longer needed goto label in the function, ops_init
Date: Thu, 28 May 2015 22:38:58 -0500
Message-ID: <87y4k8cast.fsf@x220.int.ebiederm.org>
References: <1432857028-5458-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, nicolas.dichtel@6wind.com,
	viro@zeniv.linux.org.uk, edumazet@google.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:57262 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932236AbbE2DoC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 23:44:02 -0400
In-Reply-To: <1432857028-5458-1-git-send-email-xerofoify@gmail.com> (Nicholas
	Krause's message of "Thu, 28 May 2015 19:50:28 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicholas Krause <xerofoify@gmail.com> writes:

> This removes the no longer needed goto label, cleanup in the
> function ops_init due to kfree being NULL pointer safe and
> therefore no need to avoid calling it the call to kzalloc
> fails inside this particular function.

Your proposed change pessimizes the error path without a description of
why that would be a benefit.

Further the subject on this patch is incorrect.  You don't remove any
gotos.

So I don't like this change as it.  The description is wrong
and the change provides little to no real world benefit.

Eric


> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  net/core/net_namespace.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
> index 572af00..e8b5568 100644
> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -102,7 +102,7 @@ static int ops_init(const struct pernet_operations *ops, struct net *net)
>  
>  		err = net_assign_generic(net, *ops->id, data);
>  		if (err)
> -			goto cleanup;
> +			goto out;
>  	}
>  	err = 0;
>  	if (ops->init)
> @@ -110,10 +110,8 @@ static int ops_init(const struct pernet_operations *ops, struct net *net)
>  	if (!err)
>  		return 0;
>  
> -cleanup:
> -	kfree(data);
> -
>  out:
> +	kfree(data);
>  	return err;
>  }
