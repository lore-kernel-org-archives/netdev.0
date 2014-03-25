From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 19/54] enic: Call dev_kfree_skb_any instead of
 dev_kfree_skb.
Date: Tue, 25 Mar 2014 08:24:50 -0700
Message-ID: <1395761090.12610.138.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	 <1395727540-12148-19-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:35453 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751854AbaCYPYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 11:24:53 -0400
Received: by mail-pd0-f171.google.com with SMTP id r10so579234pdi.30
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 08:24:53 -0700 (PDT)
In-Reply-To: <1395727540-12148-19-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 23:05 -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Replace dev_kfree_skb with dev_kfree_skb_any in enic_hard_start_xmit
> that can be called in hard irq and other contexts.
> 
> enic_hard_start_xmit only frees the skb when dropping it.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  drivers/net/ethernet/cisco/enic/enic_main.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
> index 4c35fc8fad99..2945718ce806 100644
> --- a/drivers/net/ethernet/cisco/enic/enic_main.c
> +++ b/drivers/net/ethernet/cisco/enic/enic_main.c
> @@ -521,7 +521,7 @@ static netdev_tx_t enic_hard_start_xmit(struct sk_buff *skb,
>  	unsigned int txq_map;
>  
>  	if (skb->len <= 0) {
> -		dev_kfree_skb(skb);
> +		dev_kfree_skb_any(skb);
>  		return NETDEV_TX_OK;
>  	}
>  
> @@ -536,7 +536,7 @@ static netdev_tx_t enic_hard_start_xmit(struct sk_buff *skb,
>  	if (skb_shinfo(skb)->gso_size == 0 &&
>  	    skb_shinfo(skb)->nr_frags + 1 > ENIC_NON_TSO_MAX_DESC &&
>  	    skb_linearize(skb)) {
> -		dev_kfree_skb(skb);
> +		dev_kfree_skb_any(skb);
>  		return NETDEV_TX_OK;
>  	}
>  

Yep, apparently this driver do not care incrementing tx_errors...

Acked-by: Eric Dumazet <edumazet@google.com>
