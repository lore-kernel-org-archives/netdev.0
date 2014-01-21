From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH] ip_tunnel: clear IPCB in ip_tunnel_xmit() in case
 dst_link_failure() is called
Date: Tue, 21 Jan 2014 10:33:36 -0800
Message-ID: <CALnjE+qFPoK_0EnZ_TWe1sx4s166iSjAH_+1r2uENeS4aRBckQ@mail.gmail.com>
References: <52DE1F60.2060109@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Daniel Petre <daniel.petre@rcs-rds.ro>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog123.obsmtp.com ([74.125.149.149]:36152 "HELO
	na3sys009aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755124AbaAUSdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 13:33:38 -0500
Received: by mail-vb0-f46.google.com with SMTP id o19so3755232vbm.33
        for <netdev@vger.kernel.org>; Tue, 21 Jan 2014 10:33:37 -0800 (PST)
In-Reply-To: <52DE1F60.2060109@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 20, 2014 at 11:18 PM, Duan Jiong <duanj.fnst@cn.fujitsu.com> wrote:
>
> commit a622260254ee48("ip_tunnel: fix kernel panic with icmp_dest_unreach")
> clear IPCB in ip_tunnel_xmit()  , or else skb->cb[] may contain garbage from
> GSO segmentation layer.
>
> But commit 0e6fbc5b6c621("ip_tunnels: extend iptunnel_xmit()") refactor codes,
> and it clear IPCB behind the dst_link_failure().
>
ok.

> So clear IPCB in ip_tunnel_xmit() just like commti a622260254ee48("ip_tunnel:
> fix kernel panic with icmp_dest_unreach").
>
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> ---
>  net/ipv4/ip_tunnel.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index 90ff957..dda1e9a 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -535,6 +535,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
>
>         inner_iph = (const struct iphdr *)skb_inner_network_header(skb);
>
> +       memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
>         dst = tnl_params->daddr;
>         if (dst == 0) {
>                 /* NBMA tunnel */

Can you clear IPCB in error path for dst_link_failure(). So that we do
not clear it twice in fast path.
