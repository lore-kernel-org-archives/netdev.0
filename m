From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: [PATCH v2 00/10] Low-level Ethernet debugging features.
Date: Thu, 09 Feb 2012 20:31:44 -0800
Message-ID: <4F349DB0.1010903@gmail.com>
References: <1328730885-10941-1-git-send-email-greearb@candelatech.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig6C823CAEA2DD06456C7D7D0F"
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:38090 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754800Ab2BJEby (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Feb 2012 23:31:54 -0500
In-Reply-To: <1328730885-10941-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig6C823CAEA2DD06456C7D7D0F
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 02/08/2012 11:54 AM, greearb@candelatech.com wrote:
> From: Ben Greear <greearb@candelatech.com>
>
> This patch series enables some features designed to make
> testing ethernet devices and debugging link-level errors
> easier.
>
> First, support is added for receiving the Ethernet FCS.  This
> allows stock wireshark to show you the actual Ethernet FCS.
>
> Second, allow sending packets with user-specified Ethernet
> FCS.  The user can specify bad FCS in order to test network
> equipments' handling of FCS errors, or, in strange cases,
> users might want to implement their own FCS scheme.
>
> Third, allow configuring a NIC to receive errored (and possibly
> other types of packets not normally passed up the stack).  This
> allows sniffers to show packets with bad FCS, for instance.
>
> These features have been tested on e100 and e1000e.  The
> e1000 patch has not been tested yet.
>
> Changes from first posting:
>
> *  Ensure nic reset when changing the rx-fcs and rx-all
>    logic in e100 (e1000e already did this).
>
> *  Use priv-flag for the 'send customized CRC' logic and
>    make it non configurable (if NIC supports it, feature is
>    enabled)  Please note that this will only be used when the
>    SKB is specifically flagged as wanting this behaviour.
>
> *  Use EPROTONOSUPPORT error to indicate the packet-socket's bound
>    NIC does not support the 'send customized CRC' feature.
>
> *  Some general cleanup, and patch re-ordering.
>
>
> There was a suggestion to throw away packets flagged as bad by
> the NIC.  I did not add any additional logic to do this.  I think
> it is not needed, but I am open to other opinions.
>
>
> Ben Greear (10):
>   net: Support RXFCS feature flag.
>   e100: Support RXFCS feature flag.
>   e1000e:  Support RXFCS feature flag.
>   net: Add framework to allow sending packets with customized CRC.
>   e100: Support sending custom Ethernet CRC
>   e1000e:  Support sending custom Ethernet CRC.
>   net:  Support RX-ALL feature flag.
>   e1000e:  Support RXALL feature flag.
>   e100:  Support RXALL feature flag.
>   e1000: Support sending custom Ethernet CRC.
>
>  Documentation/networking/netdev-features.txt  |   13 ++++
>  arch/alpha/include/asm/socket.h               |    3 +
>  arch/arm/include/asm/socket.h                 |    3 +
>  arch/avr32/include/asm/socket.h               |    3 +
>  arch/cris/include/asm/socket.h                |    3 +
>  arch/frv/include/asm/socket.h                 |    3 +
>  arch/h8300/include/asm/socket.h               |    3 +
>  arch/ia64/include/asm/socket.h                |    3 +
>  arch/m32r/include/asm/socket.h                |    3 +
>  arch/m68k/include/asm/socket.h                |    3 +
>  arch/mips/include/asm/socket.h                |    3 +
>  arch/mn10300/include/asm/socket.h             |    3 +
>  arch/parisc/include/asm/socket.h              |    4 +
>  arch/powerpc/include/asm/socket.h             |    3 +
>  arch/s390/include/asm/socket.h                |    3 +
>  arch/sparc/include/asm/socket.h               |    4 +
>  arch/xtensa/include/asm/socket.h              |    3 +
>  drivers/net/ethernet/intel/e100.c             |   66 +++++++++++++++++=
++-
>  drivers/net/ethernet/intel/e1000/e1000_main.c |   13 ++++
>  drivers/net/ethernet/intel/e1000e/defines.h   |    1 +
>  drivers/net/ethernet/intel/e1000e/e1000.h     |    1 +
>  drivers/net/ethernet/intel/e1000e/netdev.c    |   80 +++++++++++++++++=
++++---
>  drivers/net/ethernet/intel/e1000e/param.c     |    5 +-
>  include/asm-generic/socket.h                  |    4 +
>  include/linux/if.h                            |    2 +
>  include/linux/netdev_features.h               |    4 +
>  include/linux/netdevice.h                     |    8 ++-
>  include/linux/skbuff.h                        |    4 +-
>  include/net/sock.h                            |    4 +
>  net/core/ethtool.c                            |    2 +
>  net/core/skbuff.c                             |    1 +
>  net/core/sock.c                               |    4 +
>  net/packet/af_packet.c                        |   32 +++++++++-
>  33 files changed, 273 insertions(+), 21 deletions(-)
>
Thanks Ben!

I have applied the series of 10 patches to my queue.  I would like to
have our validation team validate the e100, e1000 and e1000e patches
(and in-directly the net patches).

Cheers,
Jeff


--------------enig6C823CAEA2DD06456C7D7D0F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQIcBAEBCgAGBQJPNJ25AAoJEOVv75VaS+3OpswP/iwO3TBCr2eLc2PS71xgUpU6
bhcjInSYt0u3SnY9jUiY0mSBfEtgW2v9WPFma8uiSv4+E9q8NWv+W4Ju2U2e9IqB
j8n2IHC+eS7M++YSm/12kmzN4ICp0vukon3j87FhHaTgtX+W0QpS5NsOAsNoTApJ
1UYDW2luF9nAaAA322es4xpg9ykzSpacgezFekgLNvxUxzJXVvKJ/0vNhNWVEHAB
W/NIAtGspWKW9ZFm/leKsDqTLRlapJ1KD7lYL4miR6alpmLdLQYhEglFBn7pQ3Zc
9L9b2r05GwNeCHS9CUmqFJ7bTe4JEzaJVrl0x7j64rnSBczSA76UBeIhNb0RLSrQ
StRLltLfbzuYaV9VXajZe0+XKUpX7S0qUPZvLC0UyQCXJH9Dde6EXEvLDg2lfVDK
x1i1AH8kqCj84sp2nH8GAtzKo8C+IYQigSrNN8XGqGa2VQpmv4MFK3TxIkrUt8Ij
nMfH/boDZYeaisfcsY7AHNZAacfrLNdl3Zv/oDxpOHj+MJiGAwbwPzZbzy0b+LgU
PXFv6YxAyh4PgLKG9ts90iPy2gbJkV+j+1k1rKWAC3sE/8XXnsIYfCSzjcfTx0nc
0rRjy8MYslsU6+vV/oUPZzOHnn9lb3e1IBPgrF8Ymq6ZlODKTF6ls5LhRRKbbHbb
RPAoInCoBhNwm8kuHUJ9
=ZUCa
-----END PGP SIGNATURE-----

--------------enig6C823CAEA2DD06456C7D7D0F--
