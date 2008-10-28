From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] cipso: unsigned buf_len cannot be negative
Date: Tue, 28 Oct 2008 18:02:24 -0400
Message-ID: <200810281802.24600.paul.moore@hp.com>
References: <49070A69.1090200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: roel kluin <roel.kluin@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:47190 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752720AbYJ1WC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 18:02:26 -0400
In-Reply-To: <49070A69.1090200@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 28 October 2008 8:49:45 am you wrote:
> unsigned buf_len cannot be negative
>
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Acked-by: Paul Moore <paul.moore@hp.com>

Hi Roel,

Nice catch, thanks for the patch.  Dave, can you apply this patch even 
though it is in a reply and not the original form?  If not let me know 
and I can re-send Roel's mail if he isn't able.

> ---
> diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
> index 490e035..2e78f6b 100644
> --- a/net/ipv4/cipso_ipv4.c
> +++ b/net/ipv4/cipso_ipv4.c
> @@ -2063,9 +2063,10 @@ int cipso_v4_skbuff_setattr(struct sk_buff
> *skb, u32 opt_len;
>  	int len_delta;
>
> -	buf_len = cipso_v4_genopt(buf, buf_len, doi_def, secattr);
> -	if (buf_len < 0)
> -		return buf_len;
> +	ret_val = cipso_v4_genopt(buf, buf_len, doi_def, secattr);
> +	if (ret_val < 0)
> +		return ret_val;
> +	buf_len = ret_val;
>  	opt_len = (buf_len + 3) & ~3;
>
>  	/* we overwrite any existing options to ensure that we have enough

-- 
paul moore
linux @ hp
