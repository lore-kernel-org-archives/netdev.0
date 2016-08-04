From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Slow veth performance over ipoib interface on 4.7.0 (and
 earlier) (Was Re: [IPOIB] Excessive TX packet drops due to
 IPOIB_MAX_PATH_REC_QUEUE)
Date: Thu, 04 Aug 2016 10:08:28 -0400
Message-ID: <1470319708.18081.104.camel@redhat.com>
References: <5799E5E6.3060104@kyup.com>
	 <CAAk-MO83mJTq=E_MC=izqq8fEmVujY=5egVmKfFjxAz4jO3hHg@mail.gmail.com>
	 <579F065C.602@kyup.com>
	 <CAAk-MO9C7i0en5ZE=pufz6tMecUi23kL=5FR36JNfPzuO1G5-g@mail.gmail.com>
	 <57A34448.1040600@kyup.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-sPiCFsJznwRdSZtmbWtU"
Cc: "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>,
	Erez Shitrit <erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <57A34448.1040600-6AxghH7DbtA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-sPiCFsJznwRdSZtmbWtU
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-08-04 at 16:34 +0300, Nikolay Borisov wrote:
>=20
> On 08/01/2016 11:56 AM, Erez Shitrit wrote:
> >=20
> > The GID (9000:0:2800:0:bc00:7500:6e:d8a4) is not regular, not from
> > local subnet prefix.
> > why is that?
> >=20
>=20
> So I managed to debug this and it tuns out the problem lies between
> veth
> and ipoib interaction:
>=20
> I've discovered the following strange thing. If I have a vethpair
> where
> the 2 devices are in a different net namespaces as shown in the
> scripts
> I have attached then the performance of sending a file, originating
> from
> the veth interface inside the non-init netnamespace, going across the
> ipoib interface is very slow (100kb). For simple reproduction I'm
> attaching
> 2 scripts which have to be run on 2 machine and the respective ip
> addresses
> set on them. Then sending node woult initiate a simple file copy over
> NC.
> I've observed this behavior on upstream 4.4, 4.5.4 and 4.7.0 kernels
> both
> with ipv4 and ipv6 addresses. Here is what the debug log of the ipoib
> module shows:
>=20
> ib%d: max_srq_sge=3D128
> ib%d: max_cm_mtu =3D 0xfff0, num_frags=3D16
> ib0: enabling connected mode will cause multicast packet drops
> ib0: mtu > 4092 will cause multicast packet drops.
> ib0: bringing up interface
> ib0: starting multicast thread
> ib0: joining MGID ff12:401b:ffff:0000:0000:0000:ffff:ffff
> ib0: restarting multicast task
> ib0: adding multicast entry for mgid
> ff12:601b:ffff:0000:0000:0000:0000:0001
> ib0: restarting multicast task
> ib0: adding multicast entry for mgid
> ff12:401b:ffff:0000:0000:0000:0000:0001
> ib0: join completion for ff12:401b:ffff:0000:0000:0000:ffff:ffff
> (status 0)
> ib0: Created ah ffff88081063ea80
> ib0: MGID ff12:401b:ffff:0000:0000:0000:ffff:ffff AV
> ffff88081063ea80, LID 0xc000, SL 0
> ib0: joining MGID ff12:601b:ffff:0000:0000:0000:0000:0001
> ib0: joining MGID ff12:401b:ffff:0000:0000:0000:0000:0001
> ib0: successfully started all multicast joins
> ib0: join completion for ff12:601b:ffff:0000:0000:0000:0000:0001
> (status 0)
> ib0: Created ah ffff880839084680
> ib0: MGID ff12:601b:ffff:0000:0000:0000:0000:0001 AV
> ffff880839084680, LID 0xc002, SL 0
> ib0: join completion for ff12:401b:ffff:0000:0000:0000:0000:0001
> (status 0)
> ib0: Created ah ffff88081063e280
> ib0: MGID ff12:401b:ffff:0000:0000:0000:0000:0001 AV
> ffff88081063e280, LID 0xc004, SL 0
>=20
> When the transfer is initiated I can see the following errors
> on the sending node:
>=20
> ib0: PathRec status -22 for GID
> 0401:0000:1400:0000:a0a8:ffff:1c01:4d36
> ib0: neigh free for 000003 0401:0000:1400:0000:a0a8:ffff:1c01:4d36
> ib0: Start path record lookup for
> 0401:0000:1400:0000:a0a8:ffff:1c01:4d36
> ib0: PathRec status -22 for GID
> 0401:0000:1400:0000:a0a8:ffff:1c01:4d36
> ib0: neigh free for 000003 0401:0000:1400:0000:a0a8:ffff:1c01:4d36
> ib0: Start path record lookup for
> 0401:0000:1400:0000:a0a8:ffff:1c01:4d36
> ib0: PathRec status -22 for GID
> 0401:0000:1400:0000:a0a8:ffff:1c01:4d36
> ib0: neigh free for 000003 0401:0000:1400:0000:a0a8:ffff:1c01:4d36
> ib0: Start path record lookup for
> 0401:0000:1400:0000:a0a8:ffff:1c01:4d36
> ib0: PathRec status -22 for GID
> 0401:0000:1400:0000:a0a8:ffff:1c01:4d36
> ib0: Start path record lookup for
> 0401:0000:1400:0000:a0a8:ffff:1c01:4d36
> ib0: PathRec status -22 for GID
> 0401:0000:1400:0000:a0a8:ffff:1c01:4d36
> ib0: neigh free for 000003 0401:0000:1400:0000:a0a8:ffff:1c01:4d36
> ib0: neigh free for 000003 0401:0000:1400:0000:a0a8:ffff:1c01:4d36
>=20
> Here is the port guid of the sending node: 0x0011750000772664 and
> on the receiving one: 0x0011750000774d36
>=20
> Here is how the paths look like on the sending node,=C2=A0
> clearly the paths being requested from the veth interface
>=20
> cat /sys/kernel/debug/ipoib/ib0_path
> GID: 401:0:1400:0:a0a8:ffff:1c01:4d36
> complete: no
>=20
> GID: 401:0:1400:0:a410:ffff:1c01:4d36
> complete: no
>=20
> GID: fe80:0:0:0:11:7500:77:2a1a
> complete: yes
> DLID: 0x0004
> SL: 0
> rate: 40.0 Gb/sec
>=20
> GID: fe80:0:0:0:11:7500:77:4d36
> complete: yes
> DLID: 0x000a
> SL: 0
> rate: 40.0 Gb/sec
>=20
> Testing the same scenario but instead of using veth devices I create
> the device in the non-init netnamespace via the following commands
> I can achieve sensible speeds:
> ip link add link ib0 name ip1 type ipoib
> ip link set dev ip1 netns test-netnamespace
>=20
>=20
>=20
>=20
> =C2=A0
> [Snipped a lot of useless stuff]

The poor performance sounds a duplicate of the issue reported by Roland
and in the upstream kernel bugzilla 111921. =C2=A0That would be the IPoIB
routed packet performance issue.

--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
              GPG KeyID: 0E572FDD

--=-sPiCFsJznwRdSZtmbWtU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJXo0xcAAoJELgmozMOVy/duakP/iNOIDp8OWq8eEQR/UtyIfuL
hv3FCPJqRRPq8JglTmVuzBrCjMqCt5re7sKpsQW78Ew1AlqqVjDXRhJGHEMDc0+H
daE/5/0+AYHNMU+RrxU1ujT3HwXYy8Dync1NoG3tkmNOoh/txABF8R+AwJ+9xedt
r7nygC3NZWqC9hOe6j/VsfaEc9ITCm4gAtX0mZwbSvS4dTEz7Lctrwg6K6IXIoFj
PWr5SguSb8l8p+tp5QgwMDWSJrKRgGgC0CTQDuswOgI9NcDuRoB/GH0vg/G8BeN1
VStm1DWejs7P4KqwYTE0P/Z6rx4Ak9mrSdhAOwRuFW4kCw4KgSxfMO3zHN8NlLlr
dCMT2SJJv3ydsPPMU7xvH8YkO2gX3nOuy2adjlreb/DCrQuVBtqZ2c5OXK9bdmV7
r3kgV7tYdE32Y1suD/L2slExTyBhZmzEtvUAKh8I0VvTMz669c2+s1WQDKX6/Aah
4mtj8ZEFwg4dXMKsoIDi/pOQWLo8rkEZBQd9A3AKYHEdQ05UgTMtFRIqQkbaKLuq
oicpNMbQW3+lBTZ1GT1VXoldmpqf4X7la77b8PT/SlD2G1E3X4EDuquJz8fHmQfQ
+oel95Vl7CewwmM9FUDf6EZA8ofa69I6bcsyId1uAkeHvufK06uDFrSRhZ+3uOrx
PpX+r2z5duUaxCZP2s5o
=yX6W
-----END PGP SIGNATURE-----

--=-sPiCFsJznwRdSZtmbWtU--

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
