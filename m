From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net v2] ip_tunnel: Set network header properly for IP_ECN_decapsulate()
Date: Mon, 5 May 2014 16:46:10 -0700
Message-ID: <CALnjE+qFnqsnrRzuBA83z+CYM165+fqs39=-xxbgMHctN6NbZw@mail.gmail.com>
References: <CAL1qit8cy1GOfpdu+LxrFuvegSoC_GFvE67gnfFMBW224hhNAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Ying Cai <ycai@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog117.obsmtp.com ([74.125.149.242]:36725 "HELO
	na3sys009aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756995AbaEEXv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 19:51:56 -0400
Received: by mail-ve0-f171.google.com with SMTP id oz11so1985811veb.16
        for <netdev@vger.kernel.org>; Mon, 05 May 2014 16:51:55 -0700 (PDT)
In-Reply-To: <CAL1qit8cy1GOfpdu+LxrFuvegSoC_GFvE67gnfFMBW224hhNAQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 3, 2014 at 10:40 PM, Ying Cai <ycai@google.com> wrote:
> In ip_tunnel_rcv(), set skb->network_header to inner IP header
> before IP_ECN_decapsulate().
>
> Without the fix, IP_ECN_decapsulate() takes outer IP header as
> inner IP header, possibly causing error messages or packet drops.
>
> Note that this skb_reset_network_header() call was in this spot when
> the original feature for checking consistency of ECN bits through
> tunnels was added in eccc1bb8d4b4 ("tunnel: drop packet if ECN present
> with not-ECT"). It was only removed from this spot in 3d7b46cd20e3
> ("ip_tunnel: push generic protocol handling to ip_tunnel module.").
>
> Fixes: 3d7b46cd20e3 ("ip_tunnel: push generic protocol handling to
> ip_tunnel module.")
> Reported-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Ying Cai <ycai@google.com>
> Acked-by: Neal Cardwell <ncardwell@google.com>
Acked-by: Pravin B Shelar <pshelar@nicira.com>

Looks good. Thanks.
> ---
>  net/ipv4/ip_tunnel.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index fa5b751..b3f8597 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -442,6 +442,8 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct
> sk_buff *skb,
>   tunnel->i_seqno = ntohl(tpi->seq) + 1;
>   }
>
> + skb_reset_network_header(skb);
> +
>   err = IP_ECN_decapsulate(iph, skb);
>   if (unlikely(err)) {
>   if (log_ecn_error)
> --
> 1.9.1.423.g4596e3a
