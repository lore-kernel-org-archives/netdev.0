From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next bugfix] tun, rfs:  fix the incorrect hash value
Date: Thu, 02 Jan 2014 13:41:56 +0800
Message-ID: <52C4FC24.6060805@redhat.com>
References: <1388640268-25575-1-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Zhi Yong Wu <zwu.kernel@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52230 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750983AbaABFmR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jan 2014 00:42:17 -0500
In-Reply-To: <1388640268-25575-1-git-send-email-zwu.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/02/2014 01:24 PM, Zhi Yong Wu wrote:
> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>
> The code incorrectly save the queue index as the hash, so this patch
> is fixing it with the hash received in the stack receive path.
>
> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> ---
>  drivers/net/tun.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 3cf0457..09f6662 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -378,8 +378,8 @@ static u16 tun_select_queue(struct net_device *dev, struct sk_buff *skb)
>  	if (txq) {
>  		e = tun_flow_find(&tun->flows[tun_hashfn(txq)], txq);
>  		if (e) {
> -			txq = e->queue_index;
>  			tun_flow_save_rps_rxhash(e, txq);
> +			txq = e->queue_index;
>  		} else
>  			/* use multiply and shift instead of expensive divide */
>  			txq = ((u64)txq * numqueues) >> 32;

Acked-by: Jason Wang <jasowang@redhat.com>
