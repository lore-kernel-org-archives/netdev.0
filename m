From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv2 net-next] openvswitch: Introduce ovs_tunnel_route_lookup
Date: Mon, 12 Jan 2015 21:52:38 -0800
Message-ID: <CALnjE+rELPHEMmjwnwk6w0CDx5L9s9oCx1v8y1rZrHRvyVcC3A@mail.gmail.com>
References: <1421054087-25632-1-git-send-email-fan.du@intel.com>
	<1421116883-26839-1-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, fengyuleidian0615@gmail.com
To: Fan Du <fan.du@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog123.obsmtp.com ([74.125.149.149]:35365 "HELO
	na3sys009aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751041AbbAMFwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 00:52:39 -0500
Received: by mail-ie0-f169.google.com with SMTP id y20so1089978ier.0
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 21:52:38 -0800 (PST)
In-Reply-To: <1421116883-26839-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2015 at 6:41 PM, Fan Du <fan.du@intel.com> wrote:
> Introduce ovs_tunnel_route_lookup to consolidate route lookup
> shared by vxlan, gre, and geneve ports.
>
> Signed-off-by: Fan Du <fan.du@intel.com>
> ---
> Chnage log:
> v2:
>   - Use inline instead of function call
>   - Rename vport_route_lookup to ovs_tunnel_route_lookup
> ---
>  net/openvswitch/vport-geneve.c |   11 +----------
>  net/openvswitch/vport-gre.c    |   10 +---------
>  net/openvswitch/vport-vxlan.c  |   10 +---------
>  net/openvswitch/vport.h        |   18 ++++++++++++++++++
>  4 files changed, 21 insertions(+), 28 deletions(-)
>
....

> +static inline struct rtable *ovs_tunnel_route_lookup(struct net *net,
> +                                                    struct ovs_key_ipv4_tunnel *key,
> +                                                    struct sk_buff *skb,
> +                                                    struct flowi4 *fl,
> +                                                    u8 protocol)
> +{
> +       struct rtable *rt;
> +
> +       memset(fl, 0, sizeof(*fl));
> +       fl->daddr = key->ipv4_dst;
> +       fl->saddr = key->ipv4_src;
> +       fl->flowi4_tos = RT_TOS(key->ipv4_tos);
> +       fl->flowi4_mark = skb->mark;
> +       fl->flowi4_proto = protocol;
> +
> +       rt = ip_route_output_key(net, fl);
> +       return rt;
> +}

ovs_tunnel_get_egress_info() is also directly calling ip_route_output_key()

>  #endif /* vport.h */
> --
> 1.7.1
>
