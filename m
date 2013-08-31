From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [ovs-dev] [RFC PATCH net-next 1/4] iptunnels: remove net arg from iptunnel_xmit()
Date: Fri, 30 Aug 2013 23:09:41 -0700
Message-ID: <CALnjE+pKi=p0y2ot2qWG1w=pxEUcPUKY+_UUi0RXbnGqVk9poA@mail.gmail.com>
References: <1377703210-7021-1-git-send-email-nicolas.dichtel@6wind.com>
	<1377703210-7021-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	David Miller <davem@davemloft.net>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog136.obsmtp.com ([74.125.149.85]:50218 "HELO
	na3sys009aog136.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753553Ab3HaGJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Aug 2013 02:09:42 -0400
Received: by mail-qe0-f45.google.com with SMTP id 8so1398653qea.18
        for <netdev@vger.kernel.org>; Fri, 30 Aug 2013 23:09:41 -0700 (PDT)
In-Reply-To: <1377703210-7021-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 28, 2013 at 8:20 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> This argument is not used, let's remove it.
>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  drivers/net/vxlan.c         | 3 +--
>  include/net/ip_tunnels.h    | 3 +--
>  net/ipv4/ip_tunnel.c        | 3 +--
>  net/ipv4/ip_tunnel_core.c   | 3 +--
>  net/ipv6/sit.c              | 4 ++--
>  net/openvswitch/vport-gre.c | 2 +-
>  6 files changed, 7 insertions(+), 11 deletions(-)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 3b21aca0c0c2..3bc27c2ca569 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1171,8 +1171,7 @@ int vxlan_xmit_skb(struct net *net, struct vxlan_sock *vs,
>         if (err)
>                 return err;
>
> -       return iptunnel_xmit(net, rt, skb, src, dst,
> -                       IPPROTO_UDP, tos, ttl, df);
> +       return iptunnel_xmit(rt, skb, src, dst, IPPROTO_UDP, tos, ttl, df);

Can you remove argument `net` from vxlan_xmit_skb() also?

Thanks.
