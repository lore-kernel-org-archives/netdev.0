From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 02/11] bnx2: Call dev_kfree_skby_any instead of
 dev_kfree_skb.
Date: Mon, 10 Mar 2014 20:47:57 -0700
Message-ID: <1394509677.21721.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <874n3fow2i.fsf@xmission.com>
	 <20140304.160825.893718566461536483.davem@davemloft.net>
	 <871ty9qvaf.fsf_-_@xmission.com> <87ppltpgme.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:59287 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753190AbaCKDr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 23:47:59 -0400
Received: by mail-pa0-f46.google.com with SMTP id kp14so8152993pab.19
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 20:47:59 -0700 (PDT)
In-Reply-To: <87ppltpgme.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-10 at 20:18 -0700, Eric W. Biederman wrote:
> Replace dev_kfree_skb with dev_kfree_skb_any in functions that can
> be called in hard irq and other contexts.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2.c |   10 +++++-----
>  1 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
> index ca6b36220d94..c94735de808d 100644
> --- a/drivers/net/ethernet/broadcom/bnx2.c
> +++ b/drivers/net/ethernet/broadcom/bnx2.c
> @@ -2885,7 +2885,7 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
>  		sw_cons = BNX2_NEXT_TX_BD(sw_cons);
>  
>  		tx_bytes += skb->len;
> -		dev_kfree_skb(skb);
> +		dev_kfree_skb_any(skb);

This looks like a dev_consume_skb_any() candidate ?

Anyway, why can this be called from hard irq ?

I'll stop my review here, it seems either me or you are confused/tired.
