From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the driver-core tree with the net-next
 tree
Date: Mon, 4 Feb 2013 15:38:31 +1100
Message-ID: <20130204153831.083f30730888d66d4f83acd3@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__4_Feb_2013_15_38_31_+1100_B35XGCSYcm7h/yOr"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Kees Cook <keescook@chromium.org>
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__4_Feb_2013_15_38_31_+1100_B35XGCSYcm7h/yOr
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Greg,

Today's linux-next merge of the driver-core tree got a conflict in drivers/=
net/wan/Kconfig between commit a786a7c0ad44 ("wanrouter: completely decoupl=
e obsolete code from kernel") from the net-next tree and commit c9f1b39aee7=
4 ("drivers/net/wan: remove depends on CONFIG_EXPERIMENTAL") from the drive=
r-core tree.

The former removed part of the text changed by the latter, so I just did
that (see below) and can carry the fix as necessary (no action is
required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wan/Kconfig
index 0c077b0,c0cd88d..0000000
--- a/drivers/net/wan/Kconfig
+++ b/drivers/net/wan/Kconfig
@@@ -356,9 -356,63 +356,9 @@@ config SDL
  	  To compile this driver as a module, choose M here: the
  	  module will be called sdla.
 =20
 -# Wan router core.
 -config WAN_ROUTER_DRIVERS
 -	tristate "WAN router drivers"
 -	depends on WAN_ROUTER
 -	---help---
 -	  Connect LAN to WAN via Linux box.
 -
 -	  Select driver your card and remember to say Y to "Wan Router."
 -	  You will need the wan-tools package which is available from
 -	  <ftp://ftp.sangoma.com/>.
 -
 -	  Note that the answer to this question won't directly affect the
 -	  kernel except for how subordinate drivers may be built:
 -	  saying N will just cause the configurator to skip all
 -	  the questions about WAN router drivers.
 -
 -	  If unsure, say N.
 -
 -config CYCLADES_SYNC
 -	tristate "Cyclom 2X(tm) cards"
 -	depends on WAN_ROUTER_DRIVERS && (PCI || ISA)
 -	---help---
 -	  Cyclom 2X from Cyclades Corporation <http://www.avocent.com/> is an
 -	  intelligent multiprotocol WAN adapter with data transfer rates up to
 -	  512 Kbps. These cards support the X.25 and SNA related protocols.
 -
 -	  While no documentation is available at this time please grab the
 -	  wanconfig tarball in
 -	  <http://www.conectiva.com.br/~acme/cycsyn-devel/> (with minor changes
 -	  to make it compile with the current wanrouter include files; efforts
 -	  are being made to use the original package available at
 -	  <ftp://ftp.sangoma.com/>).
 -
 -	  Feel free to contact me or the cycsyn-devel mailing list at
 -	  <acme@conectiva.com.br> and <cycsyn-devel@bazar.conectiva.com.br> for
 -	  additional details, I hope to have documentation available as soon as
 -	  possible. (Cyclades Brazil is writing the Documentation).
 -
 -	  The next questions will ask you about the protocols you want the
 -	  driver to support (for now only X.25 is supported).
 -
 -	  If you have one or more of these cards, say Y to this option.
 -
 -	  To compile this driver as a module, choose M here: the
 -	  module will be called cyclomx.
 -
 -config CYCLOMX_X25
 -	bool "Cyclom 2X X.25 support"
 -	depends on CYCLADES_SYNC
 -	help
 -	  Connect a Cyclom 2X card to an X.25 network.
 -
 -	  Enabling X.25 support will enlarge your kernel by about 11 kB.
 -
  # X.25 network drivers
  config LAPBETHER
- 	tristate "LAPB over Ethernet driver (EXPERIMENTAL)"
+ 	tristate "LAPB over Ethernet driver"
  	depends on LAPB && X25
  	---help---
  	  Driver for a pseudo device (typically called /dev/lapb0) which allows

--Signature=_Mon__4_Feb_2013_15_38_31_+1100_B35XGCSYcm7h/yOr
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRDztHAAoJEECxmPOUX5FE07QP/iqOaxPaDb/dr6BVA2VNTeqN
/huW3Y7+UljY2ZlWQc8g4s1nONH7x6JbSAhA5017Zn95f4uy5kmR3eBTPpJ5O5pA
4gZBKhqWz7gnzHMDiVwwMZdrPz3EyrnLgzkaeOmu0SUvhZHKA5Zgc6NqzSkC7ybs
UoEXI4XNeg9M7DQQSg8/AQJMN8Uh5oVw42S4yO7F2aUyIXwASBR4qftjmxtkIXBv
6C1rB0ZbblhCjN/Hj29eT5BjcFjb9HRqmE+nkMXlmcR++vTGnQ3JvqnsXPcAiCdV
OVWfwO5SssuCzOF5H2h5mImhx32mED/8VxMb/09vzkDIWxQdS6kYrbHRBL94sneN
kriRJ/OV16oyGAO9yC6LgjCHHYcdv5xquLhUmxOYp03CZ7g5GVwPvlFFAt2kVUMN
ZzFgSZJ/iircMXT/tkrKviXr2XVbAZ3pXI/CZSpWcEkLAzl4tpOIZkdKBFub2nWl
ZFdxRst7h2uJp9z2LlMpkYrLH1HwMIZSy1+DEYGCeeITgDrZbLfXI/h/l9P8t0iK
ssxa7CMH5CSqhWbkgYD0SA3DgnBrt6UGqXvV9r8IkmJhxLqj/0mJSEjeAKBxL/tF
pdeYTsWAx6LopdT2644RsMU3oPmSr4pqyvd1G03nwHpH2X/BPWJWgS9i77X0DVYS
e2S3EBuckTp2Mq5qtlQv
=KB4L
-----END PGP SIGNATURE-----

--Signature=_Mon__4_Feb_2013_15_38_31_+1100_B35XGCSYcm7h/yOr--
