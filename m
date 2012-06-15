From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 02/10] netfilter: add parameter proto for l4proto.init_net
Date: Fri, 15 Jun 2012 18:49:51 +0800
Message-ID: <4FDB134F.1080104@cn.fujitsu.com>
References: <1339668445-23848-1-git-send-email-gaofeng@cn.fujitsu.com> <1339668445-23848-2-git-send-email-gaofeng@cn.fujitsu.com> <20120614175903.GB10633@1984> <4FDA921F.1020804@cn.fujitsu.com> <20120615101045.GC13867@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:10181 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756449Ab2FOKyt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2012 06:54:49 -0400
In-Reply-To: <20120615101045.GC13867@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B406=E6=9C=8815=E6=97=A5 18:10, Pablo Neira Ayuso =
=E5=86=99=E9=81=93:
> On Fri, Jun 15, 2012 at 09:38:39AM +0800, Gao feng wrote:
>> =E4=BA=8E 2012=E5=B9=B406=E6=9C=8815=E6=97=A5 01:59, Pablo Neira Ayu=
so =E5=86=99=E9=81=93:
>>> On Thu, Jun 14, 2012 at 06:07:17PM +0800, Gao feng wrote:
>>>> there are redundancy codes in l4proto's init_net functions.
>>>> we can use one init_net function and l3proto to impletment
>>>> the same thing.
>>>>
>>>> So we should add l3proto as a parameter for init_net function.
>>>>
>>>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>>>> ---
>>>>  include/net/netfilter/nf_conntrack_l4proto.h   |    2 +-
>>>>  net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    2 +-
>>>>  net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    2 +-
>>>>  net/netfilter/nf_conntrack_proto.c             |    6 ++++--
>>>>  net/netfilter/nf_conntrack_proto_dccp.c        |    2 +-
>>>>  net/netfilter/nf_conntrack_proto_generic.c     |    2 +-
>>>>  net/netfilter/nf_conntrack_proto_gre.c         |    2 +-
>>>>  net/netfilter/nf_conntrack_proto_sctp.c        |    4 ++--
>>>>  net/netfilter/nf_conntrack_proto_tcp.c         |    4 ++--
>>>>  net/netfilter/nf_conntrack_proto_udp.c         |    4 ++--
>>>>  net/netfilter/nf_conntrack_proto_udplite.c     |    2 +-
>>>>  11 files changed, 17 insertions(+), 15 deletions(-)
>>>>
>>>> diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/includ=
e/net/netfilter/nf_conntrack_l4proto.h
>>>> index 81c52b5..5dd60f2 100644
>>>> --- a/include/net/netfilter/nf_conntrack_l4proto.h
>>>> +++ b/include/net/netfilter/nf_conntrack_l4proto.h
>>>> @@ -97,7 +97,7 @@ struct nf_conntrack_l4proto {
>>>>  #endif
>>>>  	int	*net_id;
>>>>  	/* Init l4proto pernet data */
>>>> -	int (*init_net)(struct net *net);
>>>> +	int (*init_net)(struct net *net, u_int16_t proto);
>>>> =20
>>>>  	/* Protocol name */
>>>>  	const char *name;
>>>> diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ip=
v4/netfilter/nf_conntrack_proto_icmp.c
>>>> index 041923c..76f7a2f 100644
>>>> --- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
>>>> +++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
>>>> @@ -337,7 +337,7 @@ static struct ctl_table icmp_compat_sysctl_tab=
le[] =3D {
>>>>  #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
>>>>  #endif /* CONFIG_SYSCTL */
>>>> =20
>>>> -static int icmp_init_net(struct net *net)
>>>> +static int icmp_init_net(struct net *net, u_int16_t proto)
>>>>  {
>>>>  	struct nf_icmp_net *in =3D icmp_pernet(net);
>>>>  	struct nf_proto_net *pn =3D (struct nf_proto_net *)in;
>>>> diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/=
ipv6/netfilter/nf_conntrack_proto_icmpv6.c
>>>> index 63ed012..807ae09 100644
>>>> --- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
>>>> +++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
>>>> @@ -333,7 +333,7 @@ static struct ctl_table icmpv6_sysctl_table[] =
=3D {
>>>>  };
>>>>  #endif /* CONFIG_SYSCTL */
>>>> =20
>>>> -static int icmpv6_init_net(struct net *net)
>>>> +static int icmpv6_init_net(struct net *net, u_int16_t proto)
>>>>  {
>>>>  	struct nf_icmp_net *in =3D icmpv6_pernet(net);
>>>>  	struct nf_proto_net *pn =3D (struct nf_proto_net *)in;
>>>> diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf=
_conntrack_proto.c
>>>> index a434dd7..8fc0332 100644
>>>> --- a/net/netfilter/nf_conntrack_proto.c
>>>> +++ b/net/netfilter/nf_conntrack_proto.c
>>>> @@ -193,6 +193,7 @@ static int nf_ct_l3proto_register_sysctl(struc=
t net *net,
>>>>  					    l3proto->ctl_table_path,
>>>>  					    in->ctl_table,
>>>>  					    NULL);
>>>> +
>>>
>>> This entire patchset contains many extra new lines. If you want to
>>> provide some cleanup, it should come in some follow-up patch.
>>
>> Ok, I will make a follow-up patch to do some cleanup.
>=20
> I prefer if you wait a bit until I see how this looks like in the end=
=2E
> Then, we can apply this little comestical changes.

Ok, waiting for you ;)
