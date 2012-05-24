From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 03/17] netfilter: add namespace support for l3proto
Date: Thu, 24 May 2012 12:04:12 +0200
Message-ID: <20120524100412.GE13091@1984>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1336985547-31960-4-git-send-email-gaofeng@cn.fujitsu.com>
 <20120523102910.GC2836@1984>
 <4FBD95AA.8070301@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:50004 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753788Ab2EXKEQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2012 06:04:16 -0400
Content-Disposition: inline
In-Reply-To: <4FBD95AA.8070301@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 24, 2012 at 09:58:02AM +0800, Gao feng wrote:
> =E4=BA=8E 2012=E5=B9=B405=E6=9C=8823=E6=97=A5 18:29, Pablo Neira Ayus=
o =E5=86=99=E9=81=93:
> > On Mon, May 14, 2012 at 04:52:13PM +0800, Gao feng wrote:
[...]
> >> diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf=
_conntrack_proto.c
> >> index 6d68727..7ee6653 100644
> >> --- a/net/netfilter/nf_conntrack_proto.c
> >> +++ b/net/netfilter/nf_conntrack_proto.c
> >> @@ -170,85 +170,116 @@ static int kill_l4proto(struct nf_conn *i, =
void *data)
> >>  	       nf_ct_l3num(i) =3D=3D l4proto->l3proto;
> >>  }
> >> =20
> >> -static int nf_ct_l3proto_register_sysctl(struct nf_conntrack_l3pr=
oto *l3proto)
> >> +static struct nf_ip_net *nf_ct_l3proto_net(struct net *net,
> >> +					   struct nf_conntrack_l3proto *l3proto)
> >> +{
> >> +	if (l3proto->l3proto =3D=3D PF_INET)
> >> +		return &net->ct.proto;
> >> +	else
> >> +		return NULL;
> >> +}
> >> +
> >> +static int nf_ct_l3proto_register_sysctl(struct net *net,
> >> +					 struct nf_conntrack_l3proto *l3proto)
> >>  {
> >>  	int err =3D 0;
> >> +	struct nf_ip_net *in =3D nf_ct_l3proto_net(net, l3proto);
> >> =20
> >> -#ifdef CONFIG_SYSCTL
> >> -	if (l3proto->ctl_table !=3D NULL) {
> >> -		err =3D nf_ct_register_sysctl(&init_net,
> >> -					    &l3proto->ctl_table_header,
> >> +	if (in =3D=3D NULL)
> >> +		return 0;
> >=20
> > Under what circunstances that in be NULL?
>=20
> Because l3proto_ipv6 doesn't need sysctl,so l3proto_ipv6's nf_ip_net =
is NULL,
> please see function nf_ct_l3proto_net above.

Then, please add a comment there to explain that some per-net protocol
information may missing since no sysctl is supported.
