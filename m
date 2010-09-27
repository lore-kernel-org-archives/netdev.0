From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] fix TSO FACK loss marking in tcp_mark_head_lost
Date: Mon, 27 Sep 2010 15:22:09 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1009271520560.26447@wel-95.cs.helsinki.fi>
References: <1285370526-18279-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="8323329-972842323-1285590083=:26447"
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33630 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759087Ab0I0MWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 08:22:11 -0400
In-Reply-To: <1285370526-18279-1-git-send-email-ycheng@google.com>
Content-ID: <alpine.DEB.2.00.1009271522060.26447@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-972842323-1285590083=:26447
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.1009271522061.26447@wel-95.cs.helsinki.fi>

On Fri, 24 Sep 2010, Yuchung Cheng wrote:

> When TCP uses FACK algorithm to mark lost packets in
> tcp_mark_head_lost(), if the number of packets in the (TSO) skb is
> greater than the number of packets that should be marked lost, TCP
> incorrectly exits the loop and marks no packets lost in the skb. This
> underestimates tp->lost_out and affects the recovery/retransmission.
> This patch fargments the skb and marks the correct amount of packets
> lost.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
>  net/ipv4/tcp_input.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 1bc87a0..e4f472e 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -2532,7 +2532,8 @@ static void tcp_mark_head_lost(struct sock *sk, int packets)
>  			cnt += tcp_skb_pcount(skb);
>  
>  		if (cnt > packets) {
> -			if (tcp_is_sack(tp) || (oldcnt >= packets))
> +			if ((tcp_is_sack(tp) && !tcp_is_fack(tp)) ||
> +			    (oldcnt >= packets))
>  				break;
>  
>  			mss = skb_shinfo(skb)->gso_size;
> 

Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>

-- 
 i.
--8323329-972842323-1285590083=:26447--
