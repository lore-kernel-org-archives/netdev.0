From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net v2] ip_tunnel: Set network header properly for IP_ECN_decapsulate()
Date: Sun, 04 May 2014 19:13:12 +0400
Message-ID: <53665908.5080604@cogentembedded.com>
References: <CAL1qit8cy1GOfpdu+LxrFuvegSoC_GFvE67gnfFMBW224hhNAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Ying Cai <ycai@google.com>, netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:40078 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863AbaEDPNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 11:13:10 -0400
Received: by mail-la0-f42.google.com with SMTP id pn19so626776lab.15
        for <netdev@vger.kernel.org>; Sun, 04 May 2014 08:13:08 -0700 (PDT)
In-Reply-To: <CAL1qit8cy1GOfpdu+LxrFuvegSoC_GFvE67gnfFMBW224hhNAQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04-05-2014 9:40, Ying Cai wrote:

> In ip_tunnel_rcv(), set skb->network_header to inner IP header
> before IP_ECN_decapsulate().

> Without the fix, IP_ECN_decapsulate() takes outer IP header as
> inner IP header, possibly causing error messages or packet drops.

> Note that this skb_reset_network_header() call was in this spot when
> the original feature for checking consistency of ECN bits through
> tunnels was added in eccc1bb8d4b4 ("tunnel: drop packet if ECN present
> with not-ECT"). It was only removed from this spot in 3d7b46cd20e3
> ("ip_tunnel: push generic protocol handling to ip_tunnel module.").

> Fixes: 3d7b46cd20e3 ("ip_tunnel: push generic protocol handling to
> ip_tunnel module.")
> Reported-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Ying Cai <ycai@google.com>
> Acked-by: Neal Cardwell <ncardwell@google.com>
> ---
>   net/ipv4/ip_tunnel.c | 2 ++
>   1 file changed, 2 insertions(+)

> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index fa5b751..b3f8597 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -442,6 +442,8 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct
> sk_buff *skb,
>    tunnel->i_seqno = ntohl(tpi->seq) + 1;
>    }
>
> + skb_reset_network_header(skb);
> +
>    err = IP_ECN_decapsulate(iph, skb);
>    if (unlikely(err)) {
>    if (log_ecn_error)

    The path is seriously whitespace-damaged. See 
Documentation/email-clients.txt in the kernel tree.

WBR, Sergei
