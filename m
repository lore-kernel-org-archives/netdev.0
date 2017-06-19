From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH v2 1/2] ip_tunnel: fix ip tunnel lookup in collect_md mode
Date: Sun, 18 Jun 2017 22:43:49 -0700
Message-ID: <CAOrHB_AFrCiYGyLdYpeYf7UJPgWuA-VFObGt13tAqoC56+x4=g@mail.gmail.com>
References: <1497670031-2971-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Paolo Abeni <pabeni@redhat.com>,
        Alexei Starovoitov <ast@fb.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1497670031-2971-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 16, 2017 at 8:27 PM, Haishuang Yan
<yanhaishuang@cmss.chinamobile.com> wrote:
> In collect_md mode, if the tun dev is down, it still can call
> ip_tunnel_rcv to receive on packets, and the rx statistics increase
> improperly.
>
> Fixes: 2e15ea390e6f ("ip_gre: Add support to collect tunnel metadata.")
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
>
> ---
> Change since v2:
>   * Fix wrong recipient addresss
> ---
>  net/ipv4/ip_tunnel.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index 0f1d876..a3caba1 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -176,7 +176,7 @@ struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
>                 return cand;
>
>         t = rcu_dereference(itn->collect_md_tun);
> -       if (t)
> +       if (t && (t->dev->flags & IFF_UP))
>                 return t;
>
It would be nice if we could increment drop count if tunnel device is not up.
