From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM]: Fix outbound statistics.
Date: Fri, 21 Dec 2007 23:11:11 +0800
Message-ID: <20071221151111.GA2466@gondor.apana.org.au>
References: <1198247100998-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2402 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751000AbXLUPLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 10:11:14 -0500
Content-Disposition: inline
In-Reply-To: <1198247100998-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 21, 2007 at 11:25:00PM +0900, Masahide NAKAMURA wrote:
>
>  	do {
>  		err = xfrm_state_check_space(x, skb);
> -		if (err)
> +		if (err) {
> +			XFRM_INC_STATS(LINUX_MIB_XFRMOUTERROR);
>  			goto error_nolock;
> +		}
>  
>  		err = x->outer_mode->output(x, skb);
> -		if (err)
> +		if (err) {
> +			XFRM_INC_STATS(LINUX_MIB_XFRMOUTSTATEMODEERROR);

BTW, none of our existing mode output functions actually return
an error.  I noticed that the description for this field is actually
"Transformation mode specific error, e.g. Outer header space is not
enough".  This is slightly misleading as output header space is
checked by xfrm_state_check_space so if there's an error that's
where it'll show up.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
