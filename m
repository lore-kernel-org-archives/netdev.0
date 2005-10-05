From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [ANNOUNCE] iproute2 version (050929)
Date: Wed, 5 Oct 2005 11:34:58 -0700
Message-ID: <20051005113458.46f0892d@dxpl.pdx.osdl.net>
References: <20050930150406.2e2221fd@dxpl.pdx.osdl.net>
	<Pine.LNX.4.62.0510012332580.14848@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
Return-path: <lartc-bounces@mailman.ds9a.nl>
To: Krzysztof Oledzki <olel@ans.pl>
In-Reply-To: <Pine.LNX.4.62.0510012332580.14848@bizon.gios.gov.pl>
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

On Sat, 1 Oct 2005 23:34:25 +0200 (CEST)
Krzysztof Oledzki <olel@ans.pl> wrote:

>=20
>=20
> On Fri, 30 Sep 2005, Stephen Hemminger wrote:
>=20
> > There is an new minor update to iproute2 utilities available:
> > 	http://developer.osdl.org/dev/iproute2/download/iproute2-050929.tar.=
gz
>=20
>=20
> It hangs on "ip rule flush". Tested on 2.6.13.2.
>=20
>=20
> Best regards,
>=20
>=20
>  			Krzysztof Ol=C4=99dzki

Fixed by this patch (in next release)

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

When assigning an ip address to an ethernet adapter, the newest=20
(050929) version of 'ip addr' hangs while older versions worked.=20
The problem was traced to be a removed initialisation. The patch=20
below corrects this problem.

Regards,
Jerome Borsboom

--- iproute2-050929/lib/libnetlink.c    2005-09-21 21:33:18.000000000 +02=
00
+++ iproute2-050929/lib/libnetlink.c    2005-10-04 13:42:30.000000000 +02=
00
@@ -235,7 +235,10 @@
        unsigned seq;
        struct nlmsghdr *h;
        struct sockaddr_nl nladdr;
-       struct iovec iov;
+       struct iovec iov =3D {
+               .iov_base =3D (void*)n,
+               .iov_len =3D n->nlmsg_len
+       };
        struct msghdr msg =3D {
                .msg_name =3D &nladdr,
                .msg_namelen =3D sizeof(nladdr),

--=20
Stephen Hemminger <shemminger@osdl.org>
OSDL http://developer.osdl.org/~shemminger
