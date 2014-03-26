From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [patch net-next RFC v2 2/6] skbuff: add "missed_flow"
	flag
Date: Wed, 26 Mar 2014 09:59:12 -0700
Message-ID: <CAADnVQLJdNHx8bM2zy-cw5kKLK1GG3bLR=xZ=89AQA6fie4GxQ@mail.gmail.com>
References: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
 <1395851472-10524-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
 sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
 john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org
To: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1395851472-10524-3-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Wed, Mar 26, 2014 at 9:31 AM, Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org> wrote:
> This flag sets incoming switch device in order to let know that the flow
> which the skb is part of is missed. Listener may react to it
> appropriately,
>
> Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
> ---
>  include/linux/filter.h |  1 +
>  include/linux/skbuff.h | 13 +++++++++++++
>  net/core/filter.c      |  3 +++
>  3 files changed, 17 insertions(+)
>
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index e568c8e..38c7c04 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -154,6 +154,7 @@ enum {
>         BPF_S_ANC_VLAN_TAG,
>         BPF_S_ANC_VLAN_TAG_PRESENT,
>         BPF_S_ANC_PAY_OFFSET,
> +       BPF_S_ANC_MISSED_FLOW,

Interesting use case for bpf...
looks like it's not connected to userspace.
Are you trying to extend ovs with switchdev api and bpf at once?
How do you plan to use this bpf extension?

Thanks
Alexei

>  };
>
>  #endif /* __LINUX_FILTER_H__ */
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 03db95a..0100c2f 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -567,6 +567,7 @@ struct sk_buff {
>          * headers if needed
>          */
>         __u8                    encapsulation:1;
> +       __u8                    missed_flow:1;
>         /* 6/8 bit hole (depending on ndisc_nodetype presence) */
>         kmemcheck_bitfield_end(flags2);
>
> @@ -2993,5 +2994,17 @@ static inline unsigned int skb_gso_network_seglen(const struct sk_buff *skb)
>                                skb_network_header(skb);
>         return hdr_len + skb_gso_transport_seglen(skb);
>  }
> +
> +/**
> + * skb_mark_missed_flow - marks skb as a part of missed flow
> + * @skb: buffer
> + *
> + * Marks skb as a part of missed flow.
> + */
> +static inline void skb_mark_missed_flow(struct sk_buff *skb)
> +{
> +       skb->missed_flow = 1;
> +}
> +
>  #endif /* __KERNEL__ */
>  #endif /* _LINUX_SKBUFF_H */
> diff --git a/net/core/filter.c b/net/core/filter.c
> index ad30d62..048f11a 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -350,6 +350,9 @@ load_b:
>                 case BPF_S_ANC_PAY_OFFSET:
>                         A = __skb_get_poff(skb);
>                         continue;
> +               case BPF_S_ANC_MISSED_FLOW:
> +                       A = !!skb->missed_flow;
> +                       continue;
>                 case BPF_S_ANC_NLATTR: {
>                         struct nlattr *nla;
>
> --
> 1.8.5.3
>
> _______________________________________________
> dev mailing list
> dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
> http://openvswitch.org/mailman/listinfo/dev
