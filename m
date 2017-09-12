From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH v2] geneve: Fix setting ttl value in collect metadata mode
Date: Tue, 12 Sep 2017 16:43:16 -0700
Message-ID: <CAOrHB_AWuWXw1fLvY2arKf0XO6GM0g379KDadwf=ymz47cTOMw@mail.gmail.com>
References: <1505199911-21153-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Girish Moodalbail <girish.moodalbail@oracle.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505199911-21153-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 12, 2017 at 12:05 AM, Haishuang Yan
<yanhaishuang@cmss.chinamobile.com> wrote:
> Similar to vxlan/ipip tunnel, if key->tos is zero in collect metadata
> mode, tos should also fallback to ip{4,6}_dst_hoplimit.
>
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
>
> ---
> Changes since v2:
>   * Make the commit message more clearer.
> ---
>  drivers/net/geneve.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index f640407..d52a65f 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> @@ -834,11 +834,10 @@ static int geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
>         sport = udp_flow_src_port(geneve->net, skb, 1, USHRT_MAX, true);
>         if (geneve->collect_md) {
>                 tos = ip_tunnel_ecn_encap(key->tos, ip_hdr(skb), skb);
> -               ttl = key->ttl;
>         } else {
>                 tos = ip_tunnel_ecn_encap(fl4.flowi4_tos, ip_hdr(skb), skb);
> -               ttl = key->ttl ? : ip4_dst_hoplimit(&rt->dst);
>         }
> +       ttl = key->ttl ? : ip4_dst_hoplimit(&rt->dst);
>         df = key->tun_flags & TUNNEL_DONT_FRAGMENT ? htons(IP_DF) : 0;
>
This changes user API of Geneve collect-metadata mode. I do not see
good reason for this. Why user can not set right TTL for the flow?
