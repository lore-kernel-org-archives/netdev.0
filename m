From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] netfilter: nf_conntrack_sctp: fix build warning
Date: Mon, 24 Nov 2008 09:17:27 +0800
Message-ID: <20081124011727.GA6462@localhost>
References: <20081123113315.GA16697@localhost> <20081123.135955.202482968.davem@davemloft.net> <20081124000652.GA5424@localhost> <4929FEA9.9090801@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:49850 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751107AbYKXBRj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Nov 2008 20:17:39 -0500
Content-Disposition: inline
In-Reply-To: <4929FEA9.9090801@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 24, 2008 at 03:08:57AM +0200, Wang Chen wrote:
> Wu Fengguang said the following on 2008-11-24 8:06:
> > On Sun, Nov 23, 2008 at 11:59:55PM +0200, David Miller wrote:
> >> From: Wu Fengguang <fengguang.wu@intel.com>
> >> Date: Sun, 23 Nov 2008 19:33:15 +0800
> >>
> >> linux-net is not the mailing list for network development
> >> discussion, it is for user questions.  Post patches and
> >> developer questions to netdev@vger.kernel.org instead.
> >=20
> > OK, thanks for the CC!
> >=20
> > Fengguang
> > ---
> >=20
> > net/netfilter/nf_conntrack_proto_sctp.c: In function =E2=80=98sctp_=
packet=E2=80=99:
> > net/netfilter/nf_conntrack_proto_sctp.c:376: warning: array subscri=
pt is above array bounds
> >=20
> > Signed-off-by: Wu Fengguang <wfg@linux.intel.com>
> > ---
> >=20
> > DISCLAIMER: I'm newbie to the code, and this fix could be wrong!
> >=20
> > diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilte=
r/nf_conntrack_proto_sctp.c
> > index ae8c260..d31ced4 100644
> > --- a/net/netfilter/nf_conntrack_proto_sctp.c
> > +++ b/net/netfilter/nf_conntrack_proto_sctp.c
> > @@ -373,6 +373,9 @@ static int sctp_packet(struct nf_conn *ct,
> >  	}
> >  	write_unlock_bh(&sctp_lock);
> > =20
> > +	if (new_state =3D=3D SCTP_CONNTRACK_MAX)
> > +		goto out;
> > +
>=20
> print some debug info would be better?

Like this one?
+		pr_debug("Empty sctp packet\n");

=46engguang
---
netfilter: nf_conntrack_sctp: fix build warning

net/netfilter/nf_conntrack_proto_sctp.c: In function =E2=80=98sctp_pack=
et=E2=80=99:
net/netfilter/nf_conntrack_proto_sctp.c:376: warning: array subscript i=
s above array bounds

Signed-off-by: Wu Fengguang <wfg@linux.intel.com>
---

DISCLAIMER: I'm newbie to the code, and this fix could be wrong!

diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf=
_conntrack_proto_sctp.c
index ae8c260..a0bc24b 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -373,6 +373,11 @@ static int sctp_packet(struct nf_conn *ct,
 	}
 	write_unlock_bh(&sctp_lock);
=20
+	if (new_state =3D=3D SCTP_CONNTRACK_MAX) {
+		pr_debug("Empty sctp packet\n");
+		goto out;
+	}
+
 	nf_ct_refresh_acct(ct, ctinfo, skb, sctp_timeouts[new_state]);
=20
 	if (old_state =3D=3D SCTP_CONNTRACK_COOKIE_ECHOED &&
