From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 03/06] MLSXFRM: Add security sid to sock
Date: Wed, 21 Jun 2006 10:41:14 +1000
Message-ID: <20060621004114.GA31992@gondor.apana.org.au>
References: <44983D36.8070609@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3085 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751877AbWFUAl1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 20:41:27 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
Content-Disposition: inline
In-Reply-To: <44983D36.8070609@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 20, 2006 at 06:23:50PM +0000, Venkat Yekkirala wrote:
>
> --- linux-2.6.16.vanilla/include/net/sock.h	2006-06-19 
> 17:02:23.000000000 -0500
> +++ linux-2.6.16/include/net/sock.h	2006-06-19 19:48:24.000000000 -0500
> @@ -964,6 +964,15 @@ static inline void sock_graft(struct soc
> 	write_unlock_bh(&sk->sk_callback_lock);
> }
> 
> +static inline void sock_copy(struct sock *nsk, const struct sock *osk)
> +{
> +	void *sptr = nsk->sk_security;
> +
> +	memcpy(nsk, osk, osk->sk_prot->obj_size);
> +	nsk->sk_security = sptr;

I don't get it.  Why do you put sk_security away and then set it back.
Doesn't memcpy already do this for you?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
