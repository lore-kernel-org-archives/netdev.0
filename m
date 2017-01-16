From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH v2 net-next] IPsec: do not ignore crypto err in ah input
Date: Mon, 16 Jan 2017 08:35:35 +0100
Message-ID: <20170116073535.GL3541@gauss.secunet.com>
References: <1484460583-2303-1-git-send-email-gilad@benyossef.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <herbert@gondor.apana.org.au>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>, <ofir.drang@arm.com>,
        <gilad.benyossef@arm.com>,
        Alexander Alemayhu <alexander@alemayhu.com>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:51292 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750845AbdAPHfj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Jan 2017 02:35:39 -0500
Content-Disposition: inline
In-Reply-To: <1484460583-2303-1-git-send-email-gilad@benyossef.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 15, 2017 at 08:09:43AM +0200, Gilad Ben-Yossef wrote:
> ah input processing uses the asynchronous hash crypto API which supplies 
> an error code as part of the operation completion but the error code was 
> being ignored.
> 
> Treat a crypto API error indication as a verification failure.
> 
> While a crypto API reported error would almost certainly result in a 
> memcmp of the digest failing anyway and thus the security risk seems 
> minor, performing a memory compare on what might be uninitialized memory 
> is wrong.
> 
> Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
> CC: Alexander Alemayhu <alexander@alemayhu.com>
> ---
> 
> The change was boot tested on Arm64 but I did not exercise
> the specific error code path in question.
> 
> Changes from v1:
> - Fixed typo in patch description pointed out by Alexander
> 
>  net/ipv4/ah4.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
> index f2a7102..22377c8 100644
> --- a/net/ipv4/ah4.c
> +++ b/net/ipv4/ah4.c
> @@ -270,6 +270,9 @@ static void ah_input_done(struct crypto_async_request *base, int err)
>  	int ihl = ip_hdrlen(skb);
>  	int ah_hlen = (ah->hdrlen + 2) << 2;
>  
> +	if (err)
> +		goto out;
> +

IPv6 has the same problem, can we get it fixed there too?

Thanks!
