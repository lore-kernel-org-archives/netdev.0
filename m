From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH 1/2] rtnetlink: Warn when interface's information won't
 fit in our packet
Date: Wed, 23 Apr 2014 21:41:20 +1000
Message-ID: <20140423114120.GC31647@voom.fritz.box>
References: <1398237665-26980-1-git-send-email-david@gibson.dropbear.id.au>
 <1398237665-26980-2-git-send-email-david@gibson.dropbear.id.au>
 <20140423090905.GC2846@minipsycho.orion>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="kfjH4zxOES6UT95V"
Cc: netdev@vger.kernel.org, ssujith@cisco.com, neepatel@cisco.com,
	benve@cisco.com, davem@davemloft.net, ben@decadent.org.uk,
	govindarajulu90@gmail.com, gregory.v.rose@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:42858 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752156AbaDWLmg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 07:42:36 -0400
Content-Disposition: inline
In-Reply-To: <20140423090905.GC2846@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--kfjH4zxOES6UT95V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 23, 2014 at 11:09:05AM +0200, Jiri Pirko wrote:
> Wed, Apr 23, 2014 at 09:21:04AM CEST, david@gibson.dropbear.id.au wrote:
> >Without IFLA_EXT_MASK specified, the information reported for a single
> >interface in response to RTM_GETLINK is expected to fit within a netlink
> >packet of NLMSG_GOODSIZE.
> >
> >If it doesn't, however, things will go badly wrong,  When listing all
> >interfaces, netlink_dump() will incorrectly treat -EMSGSIZE on the first
> >message in a packet as the end of the listing and omit information for
> >that interface and all subsequent ones.  This can cause getifaddrs(3) to
> >enter an infinite loop.
> >
> >This patch won't fix the problem, but it will WARN_ON() making it easier=
 to
> >track down what's going wrong.
> >
> >Signed-off-by: David Gibson <david@gibson.dropbear.id.au>
> >---
> > net/core/rtnetlink.c | 16 +++++++++++-----
> > 1 file changed, 11 insertions(+), 5 deletions(-)
> >
> >diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> >index d4ff417..5331db2 100644
> >--- a/net/core/rtnetlink.c
> >+++ b/net/core/rtnetlink.c
> >@@ -1198,6 +1198,7 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, s=
truct netlink_callback *cb)
> > 	struct hlist_head *head;
> > 	struct nlattr *tb[IFLA_MAX+1];
> > 	u32 ext_filter_mask =3D 0;
> >+	int err;
> >=20
> > 	s_h =3D cb->args[0];
> > 	s_idx =3D cb->args[1];
> >@@ -1218,11 +1219,16 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb,=
 struct netlink_callback *cb)
> > 		hlist_for_each_entry_rcu(dev, head, index_hlist) {
> > 			if (idx < s_idx)
> > 				goto cont;
> >-			if (rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
> >-					     NETLINK_CB(cb->skb).portid,
> >-					     cb->nlh->nlmsg_seq, 0,
> >-					     NLM_F_MULTI,
> >-					     ext_filter_mask) <=3D 0)
> >+			err =3D rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
> >+					       NETLINK_CB(cb->skb).portid,
> >+					       cb->nlh->nlmsg_seq, 0,
> >+					       NLM_F_MULTI,
> >+					       ext_filter_mask);
> >+			/* If we ran out of room on the first message,
> >+			 * we're in trouble */
> >+			WARN_ON((err =3D=3D -EMSGSIZE) && (skb->len =3D=3D 0));
> >+
> >+			if (err <=3D 0)
> 			if (err)

<=3D 0 was what the original version had.  Why do you think it should be
changed to !=3D 0?

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--kfjH4zxOES6UT95V
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTV6bgAAoJEGw4ysog2bOSCfwQAMACZRZZLvCwoklc1tjsZONs
Awx42cXWSU1g+JztAmcspDfB1H/NKEw8q32BN1P4wc+vXg8Tsq64y6RH4BXMKcFs
zJyIaMHWK9S1vfL80XweCncJlfaKpZb4Jx59FE4jfzTTjNyniKnkf08Nz05bvq2V
QJpU4AZKI0NPJT7Z4k3lJxt71bLLICs9gbZ12upuUGNvCW5mLfSTF9+JURZmXMEG
fw+G20AvSL9DbERnvJmkrfBpxBURHSIs37vTKte8+Ry/5RXuaWRdWiJg2hiQtSAT
dolX7SZKeuRL1okcDB/NKjwrlPWha53JA8/j4ibwmGLwRaAfmdNW44dYQ792hFQd
bdBrnvezgre/Yw69mAMWpEPh4fglIsIxQ7SwoaLPxYaYF8/xyfFKdR0cKNnGHO5w
eaI3HRzKE+uqNR71aATljFsTdhosdGT9gBTx0a84aU4jG4dz+kTqAb7CmmP4aryV
zz2ULaC7enXA71DaDAoA8IcnUBo3eIlk9EVs2NG/C3e9MxQjBqemr7cEb75dDeXL
hcBIJMw082Ai+4N3celbY5uKyUdMCFvXl0OBwuee2MPDw135RoRU8+plyeQaryFC
J8g9GVz0DF5SvRKjL3XcKhBOSEc+d7JYYHRJmFQtlD2nrod3h4ccudQPR7Lztdc6
4rADB2AEOqedz4S3Cuxy
=JZmC
-----END PGP SIGNATURE-----

--kfjH4zxOES6UT95V--
