From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 5/7] qlcnic: fix TSO race condition
Date: Wed, 17 Apr 2013 11:36:25 -0700
Message-ID: <1366223785.3205.30.camel@edumazet-glaptop>
References: <1366218359-17701-1-git-send-email-shahed.shaikh@qlogic.com>
	 <1366218359-17701-6-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sritej Velaga <sritej.velaga@qlogic.com>
To: Shahed Shaikh <shahed.shaikh@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:51132 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966121Ab3DQSg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 14:36:28 -0400
Received: by mail-pd0-f175.google.com with SMTP id g10so1004095pdj.6
        for <netdev@vger.kernel.org>; Wed, 17 Apr 2013 11:36:27 -0700 (PDT)
In-Reply-To: <1366218359-17701-6-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-17 at 13:05 -0400, Shahed Shaikh wrote:
> From: Sritej Velaga <sritej.velaga@qlogic.com>
> 
> When driver receives a packet with gso size > 0 and when TSO is disabled,
> it should be transmitted as a TSO packet to prevent Tx timeout and subsequent
> firmware reset.
> 
> Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
> Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
> ---
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
> index a85ca63..910346d 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
> @@ -362,8 +362,7 @@ set_flags:
>  		memcpy(&first_desc->eth_addr, skb->data, ETH_ALEN);
>  	}
>  	opcode = TX_ETHER_PKT;
> -	if ((adapter->netdev->features & (NETIF_F_TSO | NETIF_F_TSO6)) &&
> -	    skb_shinfo(skb)->gso_size > 0) {
> +	if (skb_is_gso(skb)) {
>  		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
>  		first_desc->mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
>  		first_desc->total_hdr_length = hdr_len;

Acked-by: Eric Dumazet <edumazet@google.com>

But its a real bug fix, targeted for net tree I presume.
