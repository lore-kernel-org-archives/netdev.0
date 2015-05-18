From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: add rfc3168, section 6.1.1.1. fallback
Date: Sun, 17 May 2015 17:59:56 -0700
Message-ID: <1431910796.621.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <3f31d31107081ed4755ed9731c63a60798c41703.1431892289.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Mirja =?ISO-8859-1?Q?K=FChlewind?=
	<mirja.kuehlewind@tik.ee.ethz.ch>,
	Brian Trammell <trammell@tik.ee.ethz.ch>,
	Eric Dumazet <edumazet@google.com>,
	Dave That <dave.taht@gmail.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:35651 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459AbbERA77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 20:59:59 -0400
Received: by igbyr2 with SMTP id yr2so35714523igb.0
        for <netdev@vger.kernel.org>; Sun, 17 May 2015 17:59:58 -0700 (PDT)
In-Reply-To: <3f31d31107081ed4755ed9731c63a60798c41703.1431892289.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-05-17 at 22:11 +0200, Daniel Borkmann wrote:

>  
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 7386d32..b05d6df 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -350,6 +350,16 @@ static void tcp_ecn_send_syn(struct sock *sk, struct sk_buff *skb)
>  	}
>  }
>  
> +static void tcp_ecn_clear_syn(struct sock *sk, struct sk_buff *skb)
> +{
> +	struct tcp_sock *tp = tcp_sk(sk);
> +
> +	if (sock_net(sk)->ipv4.sysctl_tcp_ecn_fallback) {
> +		TCP_SKB_CB(skb)->tcp_flags &= ~(TCPHDR_ECE | TCPHDR_CWR);
> +		tp->ecn_flags = 0;
> +	}
> +}
> +

Hi Daniel

If first SYNACK ECE was delayed (our SYN rtx was spurious), maybe we can
still keep ECN enabled ?

So maybe do not clear tp->ecn_flags here, as it should be ultimately
cleared in tcp_ecn_rcv_synack().
