From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] tcp: tcp_tso_autosize() minimum is one packet
Date: Wed, 27 May 2015 08:03:42 +0800
Message-ID: <20150527000342.GA16379@gondor.apana.org.au>
References: <1432655728.4060.257.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, ncardwell@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:40752 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237AbbE0ADr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 20:03:47 -0400
Content-Disposition: inline
In-Reply-To: <1432655728.4060.257.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> -               if (tso_segs == 1 || !max_segs) {
> +               if (tso_segs == 1) {

What we're testing for here with max_segs is actually the question
"is TSO enabled".  So with your patch we will be taking the TSO
code path even when TSO is disabled.  Now this may or may not
trigger the original bug that I was trying to fix but it still
feels unsafe.

So please convince me that it is totally safe to take the TSO
code path with TSO disabled, e.g., when PMTU causes tso_segs
to be greater than one.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
