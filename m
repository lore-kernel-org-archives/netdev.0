From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH v2] Proportional Rate Reduction for TCP.
Date: Fri, 19 Aug 2011 13:25:24 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1108191312170.12780@wel-95.cs.helsinki.fi>
References: <1313134197-5082-1-git-send-email-nanditad@google.com> <1313739212-2315-1-git-send-email-nanditad@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Nandita Dukkipati <nanditad@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39018 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751976Ab1HSKZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 06:25:26 -0400
In-Reply-To: <1313739212-2315-1-git-send-email-nanditad@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Aug 2011, Nandita Dukkipati wrote:

> +static void tcp_update_cwnd_in_recovery(struct sock *sk, int newly_acked_sacked,
> +					int fast_rexmit, int flag)
> +{
> +	struct tcp_sock *tp = tcp_sk(sk);
> +	int sndcnt = 0;
> +	int delta = tp->snd_ssthresh - tcp_packets_in_flight(tp);
> +
> +	if (tcp_packets_in_flight(tp) > tp->snd_ssthresh) {
> +		if (WARN_ON(!tp->prior_cwnd))
> +			tp->prior_cwnd = 1;

This should still be made larger to avoid problems if it ever will be 
needed.

> +		sndcnt = DIV_ROUND_UP((u64)(tp->prr_delivered *
> +					    tp->snd_ssthresh),
> +				      (u64)tp->prior_cwnd) - tp->prr_out;

I think you should pick one from include/linux/math64.h instead of letting 
gcc to do / operand all by itself. ...Obviosly then the ROUND_UP part 
needs to be done manually (either using the remainder or pre-addition 
like DIV_ROUND_UP does).

-- 
 i.
