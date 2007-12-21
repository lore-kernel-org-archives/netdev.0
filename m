From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [TCP] tcp_write_timeout.c cleanup
Date: Fri, 21 Dec 2007 10:23:16 -0200
Message-ID: <20071221122316.GU6264@ghostprotocols.net>
References: <476B5581.6040603@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58078 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752313AbXLUMXq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 07:23:46 -0500
Content-Disposition: inline
In-Reply-To: <476B5581.6040603@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Fri, Dec 21, 2007 at 06:56:17AM +0100, Eric Dumazet escreveu:
> Before submiting a patch to change a divide to a right shift, I felt
> necessary to create a helper function tcp_mtu_probing() to reduce length of 
> lines exceeding 100 chars in tcp_write_timeout().
>
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>

> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
> index d8970ec..8f14808 100644
> --- a/net/ipv4/tcp_timer.c
> +++ b/net/ipv4/tcp_timer.c
> @@ -114,13 +114,31 @@ static int tcp_orphan_retries(struct sock *sk, int alive)
>  	return retries;
>  }
>  
> +static void tcp_mtu_probing(struct inet_connection_sock *icsk, struct sock *sk)
> +{
> +	int mss;
-       int mss;
		
> +
> +	/* Black hole detection */
> +	if (sysctl_tcp_mtu_probing) {
> +		if (!icsk->icsk_mtup.enabled) {
> +			icsk->icsk_mtup.enabled = 1;
> +			tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
> +		} else {
> +			struct tcp_sock *tp = tcp_sk(sk);
+			int mss;
> +			mss = tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_low)/2;
> +			mss = min(sysctl_tcp_base_mss, mss);
> +			mss = max(mss, 68 - tp->tcp_header_len);
> +			icsk->icsk_mtup.search_low = tcp_mss_to_mtu(sk, mss);
> +			tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
> +		}
> +	}
> +}

:-)

- Arnaldo
