From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net v2] fix return of iptunnel_xmit
Date: Thu, 8 Oct 2015 17:39:14 +0200
Message-ID: <20151008173914.16150fd0@griffin>
References: <1444299114-21345-1-git-send-email-aschultz@tpip.net>
	<20151008170849.22bc8632@griffin>
	<56168CE2.6060208@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35652 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933855AbbJHPjR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 11:39:17 -0400
In-Reply-To: <56168CE2.6060208@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 8 Oct 2015 17:33:54 +0200, Andreas Schultz wrote:
> --- a/net/ipv4/ip_tunnel_core.c
> +++ b/net/ipv4/ip_tunnel_core.c
> @@ -80,9 +80,12 @@ int iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
>                            skb_shinfo(skb)->gso_segs ?: 1);
> 
>          err = ip_local_out_sk(sk, skb);
> -       if (unlikely(net_xmit_eval(err)))
> -               pkt_len = 0;
> -       return pkt_len;
> +       if (likely(net_xmit_eval(err) == 0))
> +               return pkt_len;
> +       if (err < 0)
> +               return err;
> +
> +       return 0;
>   }

That looks better :-)

Thanks,

 Jiri

-- 
Jiri Benc
