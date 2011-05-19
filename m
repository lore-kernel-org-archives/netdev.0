From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Lower the initial RTO to 1s as per draft RFC
 2988bis-02.
Date: Thu, 19 May 2011 16:16:13 -0400 (EDT)
Message-ID: <20110519.161613.660024399062254005.davem@davemloft.net>
References: <20110519.014656.1735519603194773578.davem@davemloft.net>
	<1305787669-84634-1-git-send-email-tsunanet@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, hagen@jauu.net,
	eric.dumazet@gmail.com, alexander.zimmermann@comsys.rwth-aachen.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tsunanet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305787669-84634-1-git-send-email-tsunanet@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benoit Sigoure <tsunanet@gmail.com>
Date: Wed, 18 May 2011 23:47:49 -0700

> @@ -868,6 +868,11 @@ static void tcp_init_metrics(struct sock *sk)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);
>  	struct dst_entry *dst = __sk_dst_get(sk);
> +	/* If we had to retransmit anything during the 3WHS, use
> +	 * the initial fallback RTO as per draft RFC 2988bis-02.
> +	 */
> +	int init_rto = inet_csk(sk)->icsk_retransmits ?
> +		TCP_TIMEOUT_INIT_FALLBACK : TCP_TIMEOUT_INIT;

Please do not put comments in the middle of a set of function
local variable declarations.

Also, as mentioned already, icsk_retransmits is not where SYN
retransmissions are counted.

It is stored in the TCP minisocket ->retrans field.
