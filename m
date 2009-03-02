From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: '< 0' test on unsigned
Date: Mon, 2 Mar 2009 12:30:56 +0800
Message-ID: <20090302043056.GA16090@gondor.apana.org.au>
References: <49AAF989.8070000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41116 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752127AbZCBEbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2009 23:31:07 -0500
Content-Disposition: inline
In-Reply-To: <49AAF989.8070000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roel Kluin <roel.kluin@gmail.com> wrote:
>
> diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
> index 25524d4..0b9d63f 100644
> --- a/net/ipv4/tcp_probe.c
> +++ b/net/ipv4/tcp_probe.c
> @@ -167,7 +167,7 @@ static ssize_t tcpprobe_read(struct file *file, char __user *buf,
> {
>        int error = 0, cnt = 0;
> 
> -       if (!buf || len < 0)
> +       if (!buf || (ssize_t)len < 0)
>                return -EINVAL;
> 
>        while (cnt < len) {

Either cnt needs to be promoted, or you need to limit len to INT_MAX.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
