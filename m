From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: remove improper preemption check in
 tcp_xmit_probe_skb()
Date: Mon, 19 Oct 2015 14:01:26 -0700
Message-ID: <1445288486.30896.25.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1445287894-2248-1-git-send-email-renatow@taghos.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Renato Westphal <renatow@taghos.com.br>
To: Renato Westphal <renatowestphal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34411 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754143AbbJSVB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 17:01:28 -0400
Received: by padhk11 with SMTP id hk11so40018248pad.1
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2015 14:01:28 -0700 (PDT)
In-Reply-To: <1445287894-2248-1-git-send-email-renatow@taghos.com.br>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-10-19 at 18:51 -0200, Renato Westphal wrote:
> Commit e520af48c7e5a introduced the following bug when setting the
> TCP_REPAIR sockoption:
> 

> 
> Since tcp_xmit_probe_skb() can be called from process context, use
> NET_INC_STATS() instead of NET_INC_STATS_BH().
> 
> Signed-off-by: Renato Westphal <renatow@taghos.com.br>
> ---
>  net/ipv4/tcp_output.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 19adedb..d4621c3 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -3416,7 +3416,7 @@ static int tcp_xmit_probe_skb(struct sock *sk, int urgent, int mib)
>  	 */
>  	tcp_init_nondata_skb(skb, tp->snd_una - !urgent, TCPHDR_ACK);
>  	skb_mstamp_get(&skb->skb_mstamp);
> -	NET_INC_STATS_BH(sock_net(sk), mib);
> +	NET_INC_STATS(sock_net(sk), mib);
>  	return tcp_transmit_skb(sk, skb, 0, GFP_ATOMIC);
>  }
>  

Patch looks good, although its title is a bit strange..

Fixes: e520af48c7e5 ("tcp: add TCPWinProbe and TCPKeepAlive SNMP counters")
