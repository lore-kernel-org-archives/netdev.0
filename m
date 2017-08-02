From: Dave Watson <davejwatson@fb.com>
Subject: Re: [PATCH v2 net-next 3/4] tcp: Adjust TCP ULP to defer to sockets
 ULP
Date: Wed, 2 Aug 2017 12:58:13 -0700
Message-ID: <20170802195813.GB47485@apz-mbp.dhcp.thefacebook.com>
References: <20170802031846.21993-1-tom@quantonium.net>
 <20170802031846.21993-4-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <rohit@quantonium.net>
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:51310 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751923AbdHBT6X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 15:58:23 -0400
Content-Disposition: inline
In-Reply-To: <20170802031846.21993-4-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/17 08:18 PM, Tom Herbert wrote:
>  
> -static int tls_init(struct sock *sk)
> +static int tls_init(struct sock *sk, char __user *optval, int len)
>  {
> -	struct inet_connection_sock *icsk = inet_csk(sk);
>  	struct tls_context *ctx;
>  	int rc = 0;
>  
> @@ -450,7 +449,7 @@ static int tls_init(struct sock *sk)
>  		rc = -ENOMEM;
>  		goto out;
>  	}
> -	icsk->icsk_ulp_data = ctx;
> +	sk->sk_ulp_data = ctx;
>  	ctx->setsockopt = sk->sk_prot->setsockopt;
>  	ctx->getsockopt = sk->sk_prot->getsockopt;
>  	sk->sk_prot = &tls_base_prot;
> @@ -458,7 +457,7 @@ static int tls_init(struct sock *sk)
>  	return rc;
>  }

It looks like tls_init should be checking if this is a tcp socket now
also, and failing if not
