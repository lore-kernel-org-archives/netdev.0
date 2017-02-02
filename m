From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: "TCP: eth0: Driver has suspect GRO implementation, TCP
 performance may be compromised." message with "ethtool -K eth0 gro off"
Date: Thu, 02 Feb 2017 05:59:24 -0800
Message-ID: <1486043964.13103.33.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170202115240.GH17590@x4>
         <1486038733.13103.21.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170202123427.GA7212@x4>
         <1486042270.13103.26.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33430 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750808AbdBBN70 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 08:59:26 -0500
Received: by mail-pg0-f67.google.com with SMTP id 194so1921461pgd.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 05:59:25 -0800 (PST)
In-Reply-To: <1486042270.13103.26.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-02-02 at 05:31 -0800, Eric Dumazet wrote:

> Anyway, I suspect the test is simply buggy ;)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 41dcbd568cbe2403f2a9e659669afe462a42e228..5394a39fcce964a7fe7075b1531a8a1e05550a54 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -164,7 +164,7 @@ static void tcp_measure_rcv_mss(struct sock *sk, const struct sk_buff *skb)
>  	if (len >= icsk->icsk_ack.rcv_mss) {
>  		icsk->icsk_ack.rcv_mss = min_t(unsigned int, len,
>  					       tcp_sk(sk)->advmss);
> -		if (unlikely(icsk->icsk_ack.rcv_mss != len))
> +		if (unlikely(icsk->icsk_ack.rcv_mss != len && skb_is_gso(skb)))
>  			tcp_gro_dev_warn(sk, skb);
>  	} else {
>  		/* Otherwise, we make more careful check taking into account,

This wont really help.

Our tcp_sk(sk)->advmss can be lower than the MSS used by the remote
peer.

ip ro add .... advmss 512

So the test is not universal.
