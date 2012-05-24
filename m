From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 15/17] netfilter: cleanup sysctl for l4proto and l3proto
Date: Thu, 24 May 2012 11:56:18 +0200
Message-ID: <20120524095618.GB13091@1984>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1336985547-31960-16-git-send-email-gaofeng@cn.fujitsu.com>
 <20120523103810.GE2836@1984>
 <4FBD87E6.6000402@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48366 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755151Ab2EXJ40 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2012 05:56:26 -0400
Content-Disposition: inline
In-Reply-To: <4FBD87E6.6000402@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 24, 2012 at 08:59:18AM +0800, Gao feng wrote:
> Hi pablo:
>=20
> =E4=BA=8E 2012=E5=B9=B405=E6=9C=8823=E6=97=A5 18:38, Pablo Neira Ayus=
o =E5=86=99=E9=81=93:
> > On Mon, May 14, 2012 at 04:52:25PM +0800, Gao feng wrote:
> >> delete no useless sysctl data for l4proto and l3proto.
> >>
> >> Acked-by: Eric W. Biederman <ebiederm@xmission.com>
> >> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> >> ---
> >>  include/net/netfilter/nf_conntrack_l3proto.h   |    2 --
> >>  include/net/netfilter/nf_conntrack_l4proto.h   |   10 ----------
> >>  net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    1 -
> >>  net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    8 --------
> >>  net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    5 -----
> >>  net/netfilter/nf_conntrack_proto_generic.c     |    8 --------
> >>  net/netfilter/nf_conntrack_proto_sctp.c        |   15 -----------=
----
> >>  net/netfilter/nf_conntrack_proto_tcp.c         |   15 -----------=
----
> >>  net/netfilter/nf_conntrack_proto_udp.c         |   15 -----------=
----
> >>  net/netfilter/nf_conntrack_proto_udplite.c     |   12 -----------=
-
> >>  10 files changed, 0 insertions(+), 91 deletions(-)
> >>
> >> diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/includ=
e/net/netfilter/nf_conntrack_l3proto.h
> >> index d6df8c7..6f7c13f 100644
> >> --- a/include/net/netfilter/nf_conntrack_l3proto.h
> >> +++ b/include/net/netfilter/nf_conntrack_l3proto.h
> >> @@ -64,9 +64,7 @@ struct nf_conntrack_l3proto {
> >>  	size_t nla_size;
> >> =20
> >>  #ifdef CONFIG_SYSCTL
> >> -	struct ctl_table_header	*ctl_table_header;
> >>  	const char		*ctl_table_path;
> >> -	struct ctl_table	*ctl_table;
> >>  #endif /* CONFIG_SYSCTL */
> >> =20
> >>  	/* Init l3proto pernet data */
> >> diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/includ=
e/net/netfilter/nf_conntrack_l4proto.h
> >> index 0d329b9..4881df34 100644
> >> --- a/include/net/netfilter/nf_conntrack_l4proto.h
> >> +++ b/include/net/netfilter/nf_conntrack_l4proto.h
> >> @@ -95,16 +95,6 @@ struct nf_conntrack_l4proto {
> >>  		const struct nla_policy *nla_policy;
> >>  	} ctnl_timeout;
> >>  #endif
> >> -
> >> -#ifdef CONFIG_SYSCTL
> >> -	struct ctl_table_header	**ctl_table_header;
> >> -	struct ctl_table	*ctl_table;
> >> -	unsigned int		*ctl_table_users;
> >> -#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
> >> -	struct ctl_table_header	*ctl_compat_table_header;
> >> -	struct ctl_table	*ctl_compat_table;
> >> -#endif
> >> -#endif
> >=20
> > Interesting. This structure is added in patch 1/17, then it's remov=
e
> > in patch 15/17.
> >=20
> > Probably I'm missing anything, but why are you doing it like that?
>=20
> This structure means ctl_table_header,ctl_table and so on?
>=20
> I add this structure to struct nf_proto_net in patch 1/17,so those fi=
elds in
> struct nf_conntrack_l4proto are useless,this patch is just some clean=
up.
>=20
> the same with nf_conntrack_l3proto.

I see, then it's OK. Please, elaborate a bit more the patch
description to explain that this structure is not required anymore.
