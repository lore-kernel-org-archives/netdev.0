From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH 2/2] isdn: i4l: move active-isdn drivers to staging
Date: Sat, 5 Mar 2016 14:08:39 +0100
Message-ID: <56DADA57.9010200@imap.cc>
References: <1456945629-1793533-1-git-send-email-arnd@arndb.de>
 <1456945629-1793533-2-git-send-email-arnd@arndb.de>
 <56D7F62E.6050502@linux-pingi.de> <1659125.tHp8H942OG@wuerfel>
 <1457108303.2651.112.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="TPombKunUf2LlQ17vRhQAjrOOhqUNqDmp"
Cc: Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>,
	linux-arm-kernel@lists.infradead.org, isdn@linux-pingi.de,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	devel@driverdev.osuosl.org, linux-doc@vger.kernel.org,
	netdev@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Paul Bolle <pebolle@tiscali.nl>, Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1457108303.2651.112.camel@tiscali.nl>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--TPombKunUf2LlQ17vRhQAjrOOhqUNqDmp
Content-Type: multipart/mixed; boundary="jQjtboV0iNHOkb2UJg1efg6hCD8IECoxp"
From: Tilman Schmidt <tilman@imap.cc>
To: Paul Bolle <pebolle@tiscali.nl>, Arnd Bergmann <arnd@arndb.de>
Cc: Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>,
 linux-arm-kernel@lists.infradead.org, isdn@linux-pingi.de,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org,
 linux-doc@vger.kernel.org, netdev@vger.kernel.org,
 Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org,
 "David S. Miller" <davem@davemloft.net>
Message-ID: <56DADA57.9010200@imap.cc>
Subject: Re: [PATCH 2/2] isdn: i4l: move active-isdn drivers to staging
References: <1456945629-1793533-1-git-send-email-arnd@arndb.de>
 <1456945629-1793533-2-git-send-email-arnd@arndb.de>
 <56D7F62E.6050502@linux-pingi.de> <1659125.tHp8H942OG@wuerfel>
 <1457108303.2651.112.camel@tiscali.nl>
In-Reply-To: <1457108303.2651.112.camel@tiscali.nl>

--jQjtboV0iNHOkb2UJg1efg6hCD8IECoxp
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Am 04.03.2016 um 17:18 schrieb Paul Bolle:
> [Added Tilman and Christoph.]
>=20
> On vr, 2016-03-04 at 16:24 +0100, Arnd Bergmann wrote:
>> I actually did more patches that I ended up not submitting:
>>
>> * move hisax to staging
>> * remove i4l support from gigaset
>=20
> For the record: I have no reason to object a patch that does that. (I'm=

> not aware anyone complained when gigaset switched its default from i4l
> to capi. By now all relevant distributions should use our capi driver.)=


No objection from me either. When the Gigaset driver is built for CAPI
it can still be used from i4l applications via capidrv with no loss of
functionality. That was a primary goal of the CAPI port.

>> * move i4l core to staging

That's a different story. Removing i4l support will actually remove a
userspace visible feature.

> On a local tree I have two (draft) patches that do some related
> preliminary work:
> - isdnhdlc: move into separate directory
> - mISDN: NETJet: stop selecting ISDN_I4L
>=20
> These trivial patches untangle mISDN and i4l.

That would be a good thing regardless of any decision on the future of
the i4l userspace interface.

> For my part I'm surprised that anyone is still using it. But apparently=

> the hardware that required commit 19cebbcb04c8 and 3460baa62068  (which=

> I'm unfamiliar with) is still operational. And since there never has
> been, as far as I know, a global i4l to capi migration nor a global i4l=

> (and capi) to mISDN migration it might be that some people are stuck on=

> i4l drivers for their hardware. Perhaps that explains Cristoph's
> commits.

The trouble is that mISDN never cared about migration or backward
compatibility. So while users of i4l applications have no problem with
i4l drivers being ported to CAPI and dropping native i4l support, they
do have a problem with drivers making that move to mISDN.

That is the situation of the hisax driver today. mISDN started as a
project to migrate hisax to CAPI but regrettably dropped that goal in
favor of a newly invented API leaving old i4l based applications behind.
As a consequence, owners of HiSAX type adapters are in fact stuck with
the old hisax driver if they want to continue using i4l userspace tools.

In my opinion, i4l, capidrv and hisax need to stay in the supported part
for the time being as they are still actively used. Native i4l support
can and should be dropped for hardware with CAPI drivers (ie. gigaset)
but not for hardware with only mISDN drivers (ie. hisax). And finally,
ISDN_CAPI_CAPIDRV should be enabled automatically if both ISDN_I4L and
ISDN_CAPI are enabled, ie. something like:

--- a/drivers/isdn/capi/Kconfig
+++ b/drivers/isdn/capi/Kconfig
@@ -27,8 +27,8 @@ config ISDN_CAPI_MIDDLEWARE
          your ISP, say Y here.

 config ISDN_CAPI_CAPIDRV
-       tristate "CAPI2.0 capidrv interface support"
-       depends on ISDN_I4L
+       tristate
+       default ISDN_I4L
        help
          This option provides the glue code to hook up CAPI driven cards=
 to
          the legacy isdn4linux link layer.  If you have a card which is


Jm2c,
Tilman

--=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Nous, on a des fleurs et des bougies pour nous prot=C3=A9ger.


--jQjtboV0iNHOkb2UJg1efg6hCD8IECoxp--

--TPombKunUf2LlQ17vRhQAjrOOhqUNqDmp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJW2tphAAoJEFPuqx0v+F+qLa8H/RFVmhuICb6y4yAcRcpL3dpr
YTo1eKbv2Yjpk0z9OJTN/XhjypFovglCGMG8RghtviGchTrceyMXRIDXlT506uQS
2mVUMJ2IQoGhAr4ax0AfdpIWLv3gqqVpjS11HpC0Q+A8LIgGE+I+kGzrhNnIr/Oe
+VuS7H6VtyENqAmRajYiDhO2qRLzup4rT76iVrGcJemNzf/o+HwExDJGflvpJDo/
Tp43YdNQIs9JvuuCLA+d4NanTL9maszxUMGlBDNQPM4ZzYI1G/r3pSdpIImG33Cf
sUTAOOs5Yi8sE1wHFY9/jcpvluXcNJIrUgZChriZdpTYUDOaXySSX+l5lKfDpik=
=RzUn
-----END PGP SIGNATURE-----

--TPombKunUf2LlQ17vRhQAjrOOhqUNqDmp--
