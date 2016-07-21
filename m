From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH V2] Add flow control to the portmapper
Date: Thu, 21 Jul 2016 20:29:42 +0300
Message-ID: <20160721172942.GW20674@leon.nu>
References: <1468869810-64420-1-git-send-email-shiraz.saleem@intel.com>
 <20160719054006.GF20674@leon.nu>
 <20160719145024.GA69464@ssaleem-MOBL4.amr.corp.intel.com>
 <20160719173253.GL20674@leon.nu>
 <20160721024750.GA52712@ssaleem-MOBL4.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="cjVziHhGDpplWqiR"
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mustafa Ismail <mustafa.ismail-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Shiraz Saleem <shiraz.saleem-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160721024750.GA52712-GOXS9JX10wfOxmVO0tvppfooFf0ArEBIu+b9c/7xato@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--cjVziHhGDpplWqiR
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 20, 2016 at 09:47:50PM -0500, Shiraz Saleem wrote:
> On Tue, Jul 19, 2016 at 08:32:53PM +0300, Leon Romanovsky wrote:
> > On Tue, Jul 19, 2016 at 09:50:24AM -0500, Shiraz Saleem wrote:
> > > On Tue, Jul 19, 2016 at 08:40:06AM +0300, Leon Romanovsky wrote:
> > > >=20
> > > > You are the one user of this new inline function.
> > > > Why don't you directly call to netlink_unicast() in your ibnl_unica=
st()
> > > > without messing with widely visible header file?
> > >=20
> > > Since there is a non-blocking version of nlmsg_unicast(), the idea is=
=20
> > > to make a blocking version available to others as well as maintain=20
> > > consistency of existing code.
> > >=20
> >=20
> > In such way, please provide patch series which will convert all other
> > users to this new call.
> >=20
> > =E2=9E=9C  linux-rdma git:(master) grep -rI netlink_unicast * | grep -I=
 0
> > kernel/audit.c: err =3D netlink_unicast(audit_sock, skb, audit_nlk_port=
id, 0);
> > kernel/audit.c:         netlink_unicast(aunet->nlsk, skb, dest->portid,=
 0);
> > kernel/audit.c: netlink_unicast(aunet->nlsk , reply->skb, reply->portid=
, 0);
> > kernel/audit.c: return netlink_unicast(audit_sock, skb, audit_nlk_porti=
d, 0);
> > samples/connector/cn_test.c:    netlink_unicast(nls, skb, 0, 0);
>=20
> These usages of netlink_unicast() with blocking are not the same as the n=
ew
> nlmsg_unicast_block() function.=20

Really?
Did you look in the code?
Let's take first function from that grep output

414         err =3D netlink_unicast(audit_sock, skb, audit_nlk_portid, 0);
415         if (err < 0) {
			... do something ...
437         } else
			... do something else ...

which fits nicely with your proposal.

+static inline int nlmsg_unicast_block(struct sock *sk, struct sk_buff *skb=
, u32 portid)
+{
+       int err;
+
+       err =3D netlink_unicast(sk, skb, portid, 0);
+       if (err > 0)
+               err =3D 0;
+
+       return err;
+}


> You can't drop in nlmsg_unicast_block() in=20
> place of netlink_unicast() in these places. I'm not going to introduce co=
de=20
> which modifies old behavior.

Again, you aren't changing any behaviour.
Anyway we are not adding general function to common include file just
because one caller wants it.

>=20

--cjVziHhGDpplWqiR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXkQaGAAoJEORje4g2clinnVQP/jeWyWrh7lkSPitLxceV/2tc
nFszwvKqVMOY+aDVOPLq8kPHUPNxuWcbjcidTKSZd6KRXwUfKddsh+UD7Xh6xWUC
7RgjhcxYSCTSN41AdkUViJ7cABPocb3wOp9fpuwBrvbZuUzp3kNRlouivcUSaewS
65aBBE5Swo8Xgp0Lgf9cTO/dzzyN92lqzjwryLzKqW724dJBx5phBsDmrDTyE1KO
4E+vR3dQ3drfdkxtpsmxLdmzTFiEvY6lbQEGmn0qJnwqhWF1ETR1yMSTwJPY2yvw
++N3mIBhqnvOaANCDkXaecEHfwRdAIP5lX6tZegXs2KfasHb/G3DO0pmLJhoscDq
CqcRsuqvMjG5uy6S3vOM8Rx+CjI8KREtjgA1XfgFTbBM5qCpKhMxzV9MiHXoIwkU
oCAUtfayvX0jwKyG1CgQa5+SJCn9zCf9VVwxBv2L20kZQSNS/GKfqz3KO1gdBnOv
kibiwvjuxBu1CDuAETRFnEvNjTpk0Y8zZMGl9Gmw4mvtCwHRp3tOxOnpx75aVrmm
kiaqnfYd/ivzDZsclpY4K8+fdIqEXAp/PpuVFAEd32BrOtvXDq28aklkhu0dSiIf
aoNKUso3wor26XtmP3j0mF8pFiuX65d0OUHXYlQWCYcH5ivS4j5/EkDUcIiHyUBw
dwjD2L6Y2mAeEHMNnKG0
=B2jU
-----END PGP SIGNATURE-----

--cjVziHhGDpplWqiR--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
