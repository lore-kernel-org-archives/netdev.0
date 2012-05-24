From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 03/17] netfilter: add namespace support for l3proto
Date: Thu, 24 May 2012 18:57:16 +0800
Message-ID: <4FBE140C.2030805@cn.fujitsu.com>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com> <1336985547-31960-4-git-send-email-gaofeng@cn.fujitsu.com> <20120523102910.GC2836@1984> <4FBD95AA.8070301@cn.fujitsu.com> <20120524100412.GE13091@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120524100412.GE13091@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B405=E6=9C=8824=E6=97=A5 18:04, Pablo Neira Ayuso =
=E5=86=99=E9=81=93:
> On Thu, May 24, 2012 at 09:58:02AM +0800, Gao feng wrote:
>> =E4=BA=8E 2012=E5=B9=B405=E6=9C=8823=E6=97=A5 18:29, Pablo Neira Ayu=
so =E5=86=99=E9=81=93:
>>> On Mon, May 14, 2012 at 04:52:13PM +0800, Gao feng wrote:
> [...]
>>>> diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf=
_conntrack_proto.c
>>>> index 6d68727..7ee6653 100644
>>>> --- a/net/netfilter/nf_conntrack_proto.c
>>>> +++ b/net/netfilter/nf_conntrack_proto.c
>>>> @@ -170,85 +170,116 @@ static int kill_l4proto(struct nf_conn *i, =
void *data)
>>>>  	       nf_ct_l3num(i) =3D=3D l4proto->l3proto;
>>>>  }
>>>> =20
>>>> -static int nf_ct_l3proto_register_sysctl(struct nf_conntrack_l3pr=
oto *l3proto)
>>>> +static struct nf_ip_net *nf_ct_l3proto_net(struct net *net,
>>>> +					   struct nf_conntrack_l3proto *l3proto)
>>>> +{
>>>> +	if (l3proto->l3proto =3D=3D PF_INET)
>>>> +		return &net->ct.proto;
>>>> +	else
>>>> +		return NULL;
>>>> +}
>>>> +
>>>> +static int nf_ct_l3proto_register_sysctl(struct net *net,
>>>> +					 struct nf_conntrack_l3proto *l3proto)
>>>>  {
>>>>  	int err =3D 0;
>>>> +	struct nf_ip_net *in =3D nf_ct_l3proto_net(net, l3proto);
>>>> =20
>>>> -#ifdef CONFIG_SYSCTL
>>>> -	if (l3proto->ctl_table !=3D NULL) {
>>>> -		err =3D nf_ct_register_sysctl(&init_net,
>>>> -					    &l3proto->ctl_table_header,
>>>> +	if (in =3D=3D NULL)
>>>> +		return 0;
>>>
>>> Under what circunstances that in be NULL?
>>
>> Because l3proto_ipv6 doesn't need sysctl,so l3proto_ipv6's nf_ip_net=
 is NULL,
>> please see function nf_ct_l3proto_net above.
>=20
> Then, please add a comment there to explain that some per-net protoco=
l
> information may missing since no sysctl is supported.

Yes, I will add a comment to make it more clearer ;)

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
