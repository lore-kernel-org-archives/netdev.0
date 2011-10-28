From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: Re: [PATCH] xfrm: fix error checking in xfrm_output_gso
Date: Fri, 28 Oct 2011 08:47:34 +0800
Message-ID: <4EA9FBA6.1070806@intel.com>
References: <4EA8ED1E.6080808@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:38473 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751447Ab1J1Arf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Oct 2011 20:47:35 -0400
In-Reply-To: <4EA8ED1E.6080808@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/2011 01:33 PM, Yan, Zheng wrote:
> xfrm_output2() returns 1 on success. This bug makes xfrm_output_gso()
> drop all segments except the first one.
> 
> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
> ---
> diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
> index 47bacd8..04e963a 100644
> --- a/net/xfrm/xfrm_output.c
> +++ b/net/xfrm/xfrm_output.c
> @@ -159,7 +159,7 @@ static int xfrm_output_gso(struct sk_buff *skb)
>  		segs->next = NULL;
>  		err = xfrm_output2(segs);
>  
> -		if (unlikely(err)) {
> +		if (unlikely(err < 0)) {
>  			while ((segs = nskb)) {
>  				nskb = segs->next;
>  				segs->next = NULL;

Return 1 means collision, please ignore this patch. Thanks
