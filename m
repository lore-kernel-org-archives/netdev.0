From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH RFC] netfilter: iptables target SYNPROXY
Date: Tue, 25 May 2010 19:26:50 +0800
Message-ID: <AANLkTim2DrXuBPUBK0TseqVJ5lxPRQjK0P_QJVsbtYRC@mail.gmail.com>
References: <1274771218-3204-1-git-send-email-xiaosuo@gmail.com>
	<alpine.LSU.2.01.1005251207450.1725@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1005251207450.1725@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 25, 2010 at 6:36 PM, Jan Engelhardt <jengelh@medozas.de> wr=
ote:
>
> On Tuesday 2010-05-25 09:06, Changli Gao wrote:
>> net/ipv4/netfilter/Kconfig =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0| =C2=A0 12
>> net/ipv4/netfilter/Makefile =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 | =C2=A0 =C2=A01
>> net/ipv4/netfilter/ipt_SYNPROXY.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 | =C2=A0658 ++++++++++++++++++++++++++++
>> net/ipv4/syncookies.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 21
>> net/ipv4/tcp_ipv4.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A05
>> net/netfilter/nf_conntrack_core.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 | =C2=A0 44 +
>
> Please make this an Xtables extension.
> There is excellent documentation ("Writing Netfilter Modules" to goog=
le)
> on the details if needed.

Hmm. I don't know IPv6 well. So I leave it as an iptables extension,
and hope sb. comes on with IPv6 support after it gets merged.

>
>>--- a/include/net/netfilter/nf_conntrack_core.h
>>+++ b/include/net/netfilter/nf_conntrack_core.h
>>@@ -63,8 +63,21 @@ static inline int nf_conntrack_confirm(struct sk_b=
uff *skb)
>> =C2=A0 =C2=A0 =C2=A0 if (ct && ct !=3D &nf_conntrack_untracked) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!nf_ct_is_confi=
rmed(ct) && !nf_ct_is_dying(ct))
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 ret =3D __nf_conntrack_confirm(skb);
>>- =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (likely(ret =3D=3D=
 NF_ACCEPT))
>>+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (likely(ret =3D=3D=
 NF_ACCEPT)) {
>>+#if defined(CONFIG_IP_NF_TARGET_SYNPROXY) || \
>>+ =C2=A0 =C2=A0defined(CONFIG_IP_NF_TARGET_SYNPROXY_MODULE)
>>+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0int (*syn_proxy)(struct sk_buff *, struct nf_conn *,
>>+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 enum ip=
_conntrack_info);
>>+#endif
>>+
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 nf_ct_deliver_cached_events(ct);
>>+#if defined(CONFIG_IP_NF_TARGET_SYNPROXY) || \
>>+ =C2=A0 =C2=A0defined(CONFIG_IP_NF_TARGET_SYNPROXY_MODULE)
>>+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0syn_proxy =3D rcu_dereference(syn_proxy_post_hook);
>>+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0if (syn_proxy)
>>+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D syn_proxy(skb, ct, skb->nfct=
info);
>>+#endif
>>+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 return ret;
>> }
>
> I'm sure this is possible with lesser macro intrusion - use a separat=
e
> function. Same in nf_conntrack_core.c

I'm thinking about adding two helper functions into structure
nf_conntrack_l4proto. Then the l4 protocol sepcific code won't be in
nf_conntrack_core.c but in nf_conntrack_proto_tcp.c.

>
>>--- a/include/net/tcp.h
>>+++ b/include/net/tcp.h
>>@@ -460,8 +460,18 @@ extern int =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0tcp_disconnect(struct sock=
 *sk, int flags);
>> extern __u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
>> extern struct sock *cookie_v4_check(struct sock *sk, struct sk_buff =
*skb,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct ip_options *op=
t);
>>-extern __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff=
 *skb,
>>- =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __u16 *mss);
>>+extern __u32 __cookie_v4_init_sequence(__be32 saddr, __be32 daddr,
>>+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __be16 sport, =
__be16 dport, __u32 seq,
>>+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __u16 *mssp);
>>+static inline __u32 cookie_v4_init_sequence(const struct iphdr *iph,
>>+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0const struct tcphdr *th,
>>+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0__u16 *mssp)
>>+{
>>+ =C2=A0 =C2=A0 =C2=A0return __cookie_v4_init_sequence(iph->saddr, ip=
h->daddr, th->source,
>>+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 th->des=
t, ntohl(th->seq), mssp);
>>+}
>
> Since there is only one cookie_v4_init_sequence user AFAICS,
> moving the function there seems to make best sense.

OK. I wanted to keep cookie_v4_init_sequence() and
cookie_v4_check_sequence() symmetric.

>
>>+static int get_mss(u8 *data, int len)
>
> unsigned

I am afraid that I can't do that. As get_mss() may return a negative
value, if there is some invalid TCP option.

>
>>+ =C2=A0 =C2=A0 =C2=A0/* only support IPv4 now */
>
> Please fix :)

The same reasion as above.

>
>>+ =C2=A0 =C2=A0 =C2=A0th =3D skb_header_pointer(skb, iph->ihl * 4, si=
zeof(_th), &_th);
>>+ =C2=A0 =C2=A0 =C2=A0BUG_ON(th =3D=3D NULL);
>
> I wouldn't call that a bug. I think that can happen on an evil TCP ti=
nygram
> (with proper IPV4 header).

I copied the code from file nf_conntrack_proto_tcp.c. In fact, BUG_ON
isn't useful at all, as tcp_error is called before this function
is called.

>
>>+static int syn_proxy_mangle_pkt(struct sk_buff *skb, struct iphdr *i=
ph,
>>+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct tcphdr *th, u32 seq_diff)
>>+{
>>+ =C2=A0 =C2=A0 =C2=A0__be32 new;
>>+ =C2=A0 =C2=A0 =C2=A0int olen;
>>+
>>+ =C2=A0 =C2=A0 =C2=A0if (skb->len < (iph->ihl + th->doff) * 4)
>>+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return NF_DROP;
>
> Verdicts are unsigned too. (Also in other functions.)

OK. Thanks.

>
>>+static struct xt_target synproxy_tg_reg __read_mostly =3D {
>>+ =C2=A0 =C2=A0 =C2=A0.name =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D "S=
YNPROXY",
>>+ =C2=A0 =C2=A0 =C2=A0.family =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D NFPROTO=
_IPV4,
>>+ =C2=A0 =C2=A0 =C2=A0.target =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D synprox=
y_tg,
>>+ =C2=A0 =C2=A0 =C2=A0.table =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=3D "r=
aw",
>>+ =C2=A0 =C2=A0 =C2=A0.hooks =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=3D (1=
 << NF_INET_PRE_ROUTING),
>
> No need for (),

Yea. Thanks.

>
>>+ =C2=A0 =C2=A0 =C2=A0.proto =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=3D IP=
PROTO_TCP,
>>+ =C2=A0 =C2=A0 =C2=A0.me =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D=
 THIS_MODULE,
>>+};
>>+
>>+static int __init synproxy_tg_init(void)
>>+{
>>+ =C2=A0 =C2=A0 =C2=A0int err, cpu;
>>+
>>+ =C2=A0 =C2=A0 =C2=A0for_each_possible_cpu(cpu)
>>+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0per_cpu(syn_proxy_s=
tate, cpu).seq_inited =3D 0;
>
> Static data starts out zeroed. That also applies to percpu data, does=
n't it?
>

Yea, Eric has mentioned that.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
