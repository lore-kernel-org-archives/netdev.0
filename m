From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [Patch] Dead code in net/sunrpc/auth_gss/auth_gss.c
Date: Tue, 18 Apr 2006 12:34:02 -0400
Message-ID: <1145378042.8115.25.camel@lade.trondhjem.org>
References: <1145376431.11649.2.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dugsong@monkey.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.6]:20704 "EHLO pat.uio.no")
	by vger.kernel.org with ESMTP id S1751023AbWDRQeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2006 12:34:14 -0400
To: Eric Sesterhenn <snakebyte@gmx.de>
In-Reply-To: <1145376431.11649.2.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-04-18 at 18:07 +0200, Eric Sesterhenn wrote:
> Hi,
> 
> the coverity checker spotted that cred is always NULL
> when we jump to out_err ( there is just one case, when
> we fail to allocate the memory for cred )
> This is Coverity ID #79
> 
> Signed-off-by: Eric Sesterhenn <snakebyte@gmx.de>
> 

I'll take it, but please send sunrpc patches to the NFS lists, not
netdev.

Cheers,
  Trond

> --- linux-2.6.17-rc1/net/sunrpc/auth_gss/auth_gss.c.orig	2006-04-18 13:23:22.000000000 +0200
> +++ linux-2.6.17-rc1/net/sunrpc/auth_gss/auth_gss.c	2006-04-18 13:24:10.000000000 +0200
> @@ -794,7 +794,6 @@ gss_create_cred(struct rpc_auth *auth, s
>  
>  out_err:
>  	dprintk("RPC:      gss_create_cred failed with error %d\n", err);
> -	if (cred) gss_destroy_cred(&cred->gc_base);
>  	return ERR_PTR(err);
>  }
>  
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

