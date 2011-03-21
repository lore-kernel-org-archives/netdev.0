From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: [PATCH] irda: validate peer name and attribute lengths
Date: Mon, 21 Mar 2011 07:32:58 -0400
Message-ID: <1300707178.9043.33.camel@dan>
References: <1300671126.9043.8.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	security@kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:63817 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753211Ab1CULdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 07:33:07 -0400
In-Reply-To: <1300671126.9043.8.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-03-20 at 21:32 -0400, Dan Rosenberg wrote:
> Length fields provided by a peer for names and attributes may be longer
> than the destination array sizes.  Validate lengths to prevent stack
> buffer overflows.
> 

While this is the most serious bug I see, this function also seems to
lack any validation against skb->len.  If someone wants to take care of
this, by all means...if not, I'll post a follow-up patch in the next day
or so.

-Dan

> Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
> Cc: stable@kernel.org
> ---
>  net/irda/iriap.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/net/irda/iriap.c b/net/irda/iriap.c
> index 5b743bd..3647753 100644
> --- a/net/irda/iriap.c
> +++ b/net/irda/iriap.c
> @@ -656,10 +656,16 @@ static void iriap_getvaluebyclass_indication(struct iriap_cb *self,
>  	n = 1;
>  
>  	name_len = fp[n++];
> +
> +	IRDA_ASSERT(name_len < IAS_MAX_CLASSNAME + 1, return;);
> +
>  	memcpy(name, fp+n, name_len); n+=name_len;
>  	name[name_len] = '\0';
>  
>  	attr_len = fp[n++];
> +
> +	IRDA_ASSERT(attr_len < IAS_MAX_ATTRIBNAME + 1, return;);
> +
>  	memcpy(attr, fp+n, attr_len); n+=attr_len;
>  	attr[attr_len] = '\0';
>  
> 


