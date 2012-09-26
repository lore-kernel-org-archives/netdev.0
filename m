From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [patch v2 04/11] nf_conntrack_netlink: pass nf_conntrack_netlink
 module to netlink_dump_start
Date: Wed, 26 Sep 2012 17:25:26 +0800
Message-ID: <5062CA06.5070408@cn.fujitsu.com>
References: <1348648888-24943-1-git-send-email-gaofeng@cn.fujitsu.com> <1348648888-24943-4-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	steffen.klassert@secunet.com, netfilter-devel@vger.kernel.org,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org, pablo@netfilter.org,
	stephen.hemminger@vyatta.com, jengelh@inai.de
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1348648888-24943-4-git-send-email-gaofeng@cn.fujitsu.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B409=E6=9C=8826=E6=97=A5 16:41, Gao feng =E5=86=99=
=E9=81=93:
> use proper netlink_dump_control.done and .module to avoid panic.
>=20
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  net/netfilter/nf_conntrack_netlink.c |    8 ++++++++
>  1 files changed, 8 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_=
conntrack_netlink.c
> index 9807f32..509a257 100644
> --- a/net/netfilter/nf_conntrack_netlink.c
> +++ b/net/netfilter/nf_conntrack_netlink.c
> @@ -706,6 +706,7 @@ static int ctnetlink_done(struct netlink_callback=
 *cb)
>  		nf_ct_put((struct nf_conn *)cb->args[1]);
>  	if (cb->data)
>  		kfree(cb->data);
> +	netlink_dump_done(cb);
>  	return 0;
>  }
> =20
> @@ -1022,6 +1023,7 @@ ctnetlink_get_conntrack(struct sock *ctnl, stru=
ct sk_buff *skb,
>  		struct netlink_dump_control c =3D {
>  			.dump =3D ctnetlink_dump_table,
>  			.done =3D ctnetlink_done,
> +			.module =3D THIS_MODULE,
>  		};
>  #ifdef CONFIG_NF_CONNTRACK_MARK
>  		if (cda[CTA_MARK] && cda[CTA_MARK_MASK]) {
> @@ -1706,6 +1708,8 @@ ctnetlink_stat_ct_cpu(struct sock *ctnl, struct=
 sk_buff *skb,
>  	if (nlh->nlmsg_flags & NLM_F_DUMP) {
>  		struct netlink_dump_control c =3D {
>  			.dump =3D ctnetlink_ct_stat_cpu_dump,
> +			.done =3D netlink_dump_done,
> +			.module =3D THIS_MODULE,
>  		};
>  		return netlink_dump_start(ctnl, skb, nlh, &c);
>  	}
> @@ -2141,6 +2145,7 @@ static int ctnetlink_exp_done(struct netlink_ca=
llback *cb)
>  {
>  	if (cb->args[1])
>  		nf_ct_expect_put((struct nf_conntrack_expect *)cb->args[1]);
> +	netlink_dump_done(cb);
>  	return 0;
>  }

I should do return netlink_dump_done here.
I will reset this patchset.
