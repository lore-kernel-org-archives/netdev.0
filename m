From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 2/2] tg3: Allow for receive of full-size 8021AD frames
Date: Fri, 19 Sep 2014 15:59:12 -0700
Message-ID: <1411167552.26859.58.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411165389-21276-1-git-send-email-vyasevic@redhat.com>
	 <1411165389-21276-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vladislav Yasevich <vyasevic@redhat.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:58657 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932237AbaISW7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 18:59:15 -0400
Received: by mail-pa0-f45.google.com with SMTP id rd3so968609pab.18
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 15:59:14 -0700 (PDT)
In-Reply-To: <1411165389-21276-3-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-19 at 18:23 -0400, Vladislav Yasevich wrote:
> When receiving a vlan-tagged frame that still contains
> a vlan header, the length of the packet will be greater
> then MTU+ETH_HLEN since it will account of the extra
> vlan header.  TG3 checks this for the case for 802.1Q,
> but not for 802.1ad.  As a result, full sized 802.1ad
> frames get dropped by the card.
> 
> Add a check for 802.1ad protocol when receiving full
> sized frames.
> 
> Suggested-by: Prashant Sreedharan <prashant@broadcom.com>
> CC: Prashant Sreedharan <prashant@broadcom.com>
> CC: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> ---
>  drivers/net/ethernet/broadcom/tg3.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index 0a0938d..4f674f9 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -6918,7 +6918,8 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
>  		skb->protocol = eth_type_trans(skb, tp->dev);
>  
>  		if (len > (tp->dev->mtu + ETH_HLEN) &&
> -		    skb->protocol != htons(ETH_P_8021Q)) {
> +		    skb->protocol != htons(ETH_P_8021Q) &&
> +		    skb->protocol != htons(ETH_P_8021AD)) {
>  			dev_kfree_skb_any(skb);
>  			goto drop_it_no_recycle;
>  		}

Really I do not understand what is the value of this check.

If NIC is dumb enough to send oversized frames, what prevents these
frames being VLAN ones, and this test wont avoid the crash anyway ?
