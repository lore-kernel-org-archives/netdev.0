From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 2/2] tcp: Fix tcp_prequeue() to get correct rto_min value
Date: Sat, 2 May 2009 13:20:02 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0905021312070.8517@wrl-59.cs.helsinki.fi>
References: <20090502075133.GC13165@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Satoru SATOH <satoru.satoh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47541 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752628AbZEBKUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2009 06:20:03 -0400
In-Reply-To: <20090502075133.GC13165@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2 May 2009, Satoru SATOH wrote:

> This patch depends on the previous patch, makes tcp_prequeue() uses the
> correct tcp rto_min value returns from tcp_rto_min().
> 
> Signed-off-by: Satoru SATOH <satoru.satoh@gmail.com>
> 
> ---
>  include/net/tcp.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 284cc68..a54d139 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -920,7 +920,7 @@ static inline int tcp_prequeue(struct sock *sk, struct sk_buff *skb)
>  			wake_up_interruptible(sk->sk_sleep);
>  			if (!inet_csk_ack_scheduled(sk))
>  				inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
> -						          (3 * TCP_RTO_MIN) / 4,
> +						          (3 * tcp_rto_min(sk)) / 4,
>  							  TCP_RTO_MAX);
>  		}
>  		return 1;
> 

I'm not fully sure we really want this... I wonder did you run into some 
real problem with the TCP_RTO_MIN based version as it's not setting RTO 
timer but delayed ACK timer...? The change could have nasty effects to 
interactivity of a flow if somebody is hit by nagle delay and the peer
has tuned their minimum RTO. Not that I in anyway believe it should be 
that useful to set that minimum RTO because of frto that is nowadays
enabled.

In any case, I see very little point in putting them into a separate 
patches due to non-complex nature of the actual change (with complex 
changes it might help though).


-- 
 i.
