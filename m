From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] tcp: measure rwnd-limited time
Date: Wed, 07 Sep 2016 17:27:42 -0700 (PDT)
Message-ID: <20160907.172742.1031784635164954011.davem@davemloft.net>
References: <1473211961-107223-1-git-send-email-francisyyan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, soheil@google.com,
        ncardwell@google.com, ycheng@google.com
To: francisyyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50360 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753107AbcIHA1q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 20:27:46 -0400
In-Reply-To: <1473211961-107223-1-git-send-email-francisyyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Francis Y. Yan" <francisyyan@gmail.com>
Date: Tue,  6 Sep 2016 18:32:40 -0700

> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index 7be9b12..f5b588e 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -176,6 +176,7 @@ struct tcp_sock {
>  				 * were acked.
>  				 */
>  	struct u64_stats_sync syncp; /* protects 64bit vars (cf tcp_get_info()) */
> +	seqcount_t seqcnt;	/* proctects rwnd-limited-related vars, etc. */
>  
>   	u32	snd_una;	/* First byte we want an ack for	*/
>   	u32	snd_sml;	/* Last byte of the most recently transmitted small packet */
> @@ -204,6 +205,8 @@ struct tcp_sock {
>  
>  	u32	window_clamp;	/* Maximal window to advertise		*/
>  	u32	rcv_ssthresh;	/* Current window clamp			*/
> +	struct skb_mstamp rwnd_limited_ts; /* Last timestamp limited by rwnd */
> +	u64	rwnd_limited;	/* Total time (us) limited by rwnd */
>  
>  	/* Information of the most recently (s)acked skb */
>  	struct tcp_rack {

I understand completely the usefulness of this change, but wow that is a lot of
new TCP socket space taken up just to export some time values in tcp_info for
debugging and statistics.
