From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: only take RTT from timestamps if new data is
 acked
Date: Thu, 24 Oct 2013 12:55:37 -0700
Message-ID: <1382644537.7572.60.camel@edumazet-glaptop.roam.corp.google.com>
References: <1382630125-21416-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ncardwell@google.com, edumazet@google.com,
	netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:47468 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753940Ab3JXTzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 15:55:41 -0400
Received: by mail-wi0-f176.google.com with SMTP id l12so78472wiv.9
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 12:55:40 -0700 (PDT)
In-Reply-To: <1382630125-21416-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-24 at 08:55 -0700, Yuchung Cheng wrote:
> Patch ed08495c3 "tcp: use RTT from SACK for RTO" has a bug that
> it does not check if the ACK acknowledge new data before taking
> the RTT sample from TCP timestamps. This patch adds the check
> back as required by the RFC.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
>  net/ipv4/tcp_input.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 305cd05..6ffe41a 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -2856,7 +2856,8 @@ static inline bool tcp_ack_update_rtt(struct sock *sk, const int flag,
>  	 * left edge of the send window.
>  	 * See draft-ietf-tcplw-high-performance-00, section 3.3.
>  	 */
> -	if (seq_rtt < 0 && tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr)
> +	if (seq_rtt < 0 && tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr &&
> +	    flag & FLAG_ACKED)
>  		seq_rtt = tcp_time_stamp - tp->rx_opt.rcv_tsecr;
>  
>  	if (seq_rtt < 0)

Acked-by: Eric Dumazet <edumazet@google.com>
