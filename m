From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 03/10] netfilter: add nf_ct_kfree_compat_sysctl_table
 to make codes clear
Date: Fri, 15 Jun 2012 09:36:06 +0800
Message-ID: <4FDA9186.408@cn.fujitsu.com>
References: <1339668445-23848-1-git-send-email-gaofeng@cn.fujitsu.com> <1339668445-23848-3-git-send-email-gaofeng@cn.fujitsu.com> <20120614180632.GD10633@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120614180632.GD10633@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pablo:

=E4=BA=8E 2012=E5=B9=B406=E6=9C=8815=E6=97=A5 02:06, Pablo Neira Ayuso =
=E5=86=99=E9=81=93:
> On Thu, Jun 14, 2012 at 06:07:18PM +0800, Gao feng wrote:
>> add function nf_ct_kfree_compat_sysctl_table to kfree l4proto's
>> compat sysctl table and set the sysctl table point to NULL.
>>
>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>> ---
>>  include/net/netfilter/nf_conntrack_l4proto.h |    8 ++++++++
>>  net/netfilter/nf_conntrack_proto.c           |    4 +---
>>  2 files changed, 9 insertions(+), 3 deletions(-)
>>
>> diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/=
net/netfilter/nf_conntrack_l4proto.h
>> index 5dd60f2..889b717 100644
>> --- a/include/net/netfilter/nf_conntrack_l4proto.h
>> +++ b/include/net/netfilter/nf_conntrack_l4proto.h
>> @@ -132,6 +132,14 @@ extern int nf_ct_port_nlattr_to_tuple(struct nl=
attr *tb[],
>>  extern int nf_ct_port_nlattr_tuple_size(void);
>>  extern const struct nla_policy nf_ct_port_nla_policy[];
>> =20
>> +static inline void nf_ct_kfree_compat_sysctl_table(struct nf_proto_=
net *pn)
>> +{
>> +#if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMP=
AT)
>> +	kfree(pn->ctl_compat_table);
>> +	pn->ctl_compat_table =3D NULL;
>> +#endif
>> +}
>> +
>>  #ifdef CONFIG_SYSCTL
>>  #ifdef DEBUG_INVALID_PACKETS
>>  #define LOG_INVALID(net, proto)				\
>> diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_c=
onntrack_proto.c
>> index 8fc0332..c9df1b4 100644
>> --- a/net/netfilter/nf_conntrack_proto.c
>> +++ b/net/netfilter/nf_conntrack_proto.c
>> @@ -361,9 +361,7 @@ int nf_ct_l4proto_register_sysctl(struct net *ne=
t,
>>  					    NULL);
>>  		if (err =3D=3D 0)
>>  			goto out;
>> -
>> -		kfree(pn->ctl_compat_table);
>> -		pn->ctl_compat_table =3D NULL;
>> +		nf_ct_kfree_compat_sysctl_table(pn);
>=20
> if this is the only client of this function, then make it static and
> define it inside nf_conntrack_proto.c
>=20

tcp_init_net,udp_init_net use this function too.

Thanks
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
