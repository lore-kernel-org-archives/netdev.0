From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: replace cnt & rtt with struct in
 pkts_acked()
Date: Tue, 10 May 2016 15:00:47 -0400 (EDT)
Message-ID: <20160510.150047.1472901479981953800.davem@davemloft.net>
References: <1462830372-3563095-1-git-send-email-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, ncardwell@google.com,
	eric.dumazet@gmail.com, ycheng@google.com
To: brakmo@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42334 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751608AbcEJTAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 15:00:50 -0400
In-Reply-To: <1462830372-3563095-1-git-send-email-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lawrence Brakmo <brakmo@fb.com>
Date: Mon, 9 May 2016 14:46:12 -0700

> @@ -197,15 +197,15 @@ static void bictcp_state(struct sock *sk, u8 new_state)
>  /* Track delayed acknowledgment ratio using sliding window
>   * ratio = (15*ratio + sample) / 16
>   */
> -static void bictcp_acked(struct sock *sk, u32 cnt, s32 rtt)
> +static void bictcp_acked(struct sock *sk, const struct ack_sample *sample)
>  {
>  	const struct inet_connection_sock *icsk = inet_csk(sk);
>  
>  	if (icsk->icsk_ca_state == TCP_CA_Open) {
>  		struct bictcp *ca = inet_csk_ca(sk);
>  
> -		cnt -= ca->delayed_ack >> ACK_RATIO_SHIFT;
> -		ca->delayed_ack += cnt;
> +		ca->delayed_ack += sample->pkts_acked - 

^^ Trailing whitespace on that line.

> +		struct ack_sample sample = {.pkts_acked = pkts_acked,
> +					    .rtt_us = ca_rtt_us};

Please put a space after the openning parenthesis and before the closing parenthesis.
