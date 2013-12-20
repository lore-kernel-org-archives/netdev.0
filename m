From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC PATCH] net, gro: fix the truesize of all fragments
Date: Fri, 20 Dec 2013 17:52:23 +0400
Message-ID: <52B44B97.4060400@cogentembedded.com>
References: <1387539943-25521-1-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Zhi Yong Wu <zwu.kernel@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:57631 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422654Ab3LTNwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 08:52:14 -0500
Received: by mail-la0-f43.google.com with SMTP id n7so1134059lam.30
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 05:52:13 -0800 (PST)
In-Reply-To: <1387539943-25521-1-git-send-email-zwu.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 20-12-2013 15:45, Zhi Yong Wu wrote:

> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

> When the truesize of all fragments was calculated, it didn't take
> the first small piece of data into account.

> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> ---
>   net/core/skbuff.c |   10 +++++++---
>   1 files changed, 7 insertions(+), 3 deletions(-)

> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 2b6b863..0665bd6 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3027,9 +3027,12 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
>   		frag->page_offset += offset;
>   		skb_frag_size_sub(frag, offset);
>
> -		/* all fragments truesize : remove (head size + sk_buff) */
> +		/**

    Why kernel-doc style comment here? Networking code uses the following 
comment style:

/* bla
  * bla
  */

> +		 * all fragments truesize :
> +		 * remove (head size + sk_buff + offset)
> +		 */
>   		delta_truesize = skb->truesize -
> -				 SKB_TRUESIZE(skb_end_offset(skb));
> +				 SKB_TRUESIZE(skb_end_offset(skb) + offset);
>
>   		skb->truesize -= skb->data_len;
>   		skb->len -= skb->data_len;

WBR, Sergei
