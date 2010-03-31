From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH] netfilter: ctnetlink: compute message
 size properly
Date: Wed, 31 Mar 2010 20:35:43 +0200
Message-ID: <1270060543.1931.20.camel@edumazet-laptop>
References: <20100331151102.GB8043@psychotron.lab.eng.brq.redhat.com>
	 <4BB38A8A.9050501@trash.net>  <20100331182116.GB2822@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	davem@davemloft.net, Krzysztof Oledzki <ole@ans.pl>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <20100331182116.GB2822@psychotron.redhat.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 31 mars 2010 =C3=A0 20:21 +0200, Jiri Pirko a =C3=A9crit :
> Okay, I see your point. How about this:
>=20
> Subject: [net-next-2.6 PATCH] netfilter: ctnetlink: compute message s=
ize properly V2
>=20
> Message size should be dependent on net->ct.sysctl_acct, not on
> CONFIG_NF_CT_ACCT definition.
>=20

Then Changelog is not updated with the actual test :)

> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>=20
> diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_=
conntrack_netlink.c
> index 569410a..44487d8 100644
> --- a/net/netfilter/nf_conntrack_netlink.c
> +++ b/net/netfilter/nf_conntrack_netlink.c
> @@ -426,6 +426,17 @@ ctnetlink_proto_size(const struct nf_conn *ct)
>  }
> =20
>  static inline size_t
> +ctnetlink_counters_size(const struct nf_conn *ct)
> +{
> +	if (!nf_ct_ext_exist(ct, NF_CT_EXT_ACCT))
> +		return 0;
> +	return 2 * nla_total_size(0) /* CTA_COUNTERS_ORIG|REPL */
> +	       + 2 * nla_total_size(sizeof(uint64_t)) /* CTA_COUNTERS_PACKE=
TS */
> +	       + 2 * nla_total_size(sizeof(uint64_t)) /* CTA_COUNTERS_BYTES=
 */
> +	       ;
> +}
> +
> +static inline size_t
>  ctnetlink_nlmsg_size(const struct nf_conn *ct)
>  {
>  	return NLMSG_ALIGN(sizeof(struct nfgenmsg))
> @@ -435,11 +446,7 @@ ctnetlink_nlmsg_size(const struct nf_conn *ct)
>  	       + 3 * nla_total_size(sizeof(u_int8_t)) /* CTA_PROTO_NUM */
>  	       + nla_total_size(sizeof(u_int32_t)) /* CTA_ID */
>  	       + nla_total_size(sizeof(u_int32_t)) /* CTA_STATUS */
> -#ifdef CONFIG_NF_CT_ACCT
> -	       + 2 * nla_total_size(0) /* CTA_COUNTERS_ORIG|REPL */
> -	       + 2 * nla_total_size(sizeof(uint64_t)) /* CTA_COUNTERS_PACKE=
TS */
> -	       + 2 * nla_total_size(sizeof(uint64_t)) /* CTA_COUNTERS_BYTES=
 */
> -#endif
> +	       + ctnetlink_counters_size(ct)
>  	       + nla_total_size(sizeof(u_int32_t)) /* CTA_TIMEOUT */
>  	       + nla_total_size(0) /* CTA_PROTOINFO */
>  	       + nla_total_size(0) /* CTA_HELP */
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


