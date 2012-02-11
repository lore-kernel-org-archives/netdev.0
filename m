From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: [PATCH v3 00/16] Low-level Ethernet debugging features.
Date: Fri, 10 Feb 2012 23:56:27 -0800
Message-ID: <4F361F2B.9030908@gmail.com>
References: <1328922274-23993-1-git-send-email-greearb@candelatech.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig71EFE652AA5DE6C0D9797579"
Cc: netdev <netdev@vger.kernel.org>
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:60304 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753448Ab2BKH42 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Feb 2012 02:56:28 -0500
In-Reply-To: <1328922274-23993-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig71EFE652AA5DE6C0D9797579
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 02/10/2012 05:04 PM, greearb@candelatech.com wrote:
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
> Changes from V2:
>
> *  Fix e100 to properly not count the FCS in the rx-bytes counter.
>
> *  Add rx-fcs and rx-all support for e1000 driver (tested with bad FCS =
pkts).
>
> *  Add realtek 8139too and r8169 support for rx-all and rx-fcs features=
=2E
>    It appears these drivers cannot do per-packet FCS tx config, so I
>    have no plans to implement the 'send custom fcs' logic in them.
>
> Ben Greear (16):
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
>   e1000:  Support RX-ALL flag.
>   e1000:  Support RX-FCS flag.
>   8139too:  Support RX-ALL logic.
>   8139too:  Support RX-FCS flag.
>   r8169:  Support RX-ALL flag.
>   r8169:  Support RX-FCS flag.
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
>  drivers/net/ethernet/intel/e100.c             |   68 +++++++++++++++++=
++--
>  drivers/net/ethernet/intel/e1000/e1000_main.c |   59 +++++++++++++++--=
--
>  drivers/net/ethernet/intel/e1000e/defines.h   |    1 +
>  drivers/net/ethernet/intel/e1000e/e1000.h     |    1 +
>  drivers/net/ethernet/intel/e1000e/netdev.c    |   80 +++++++++++++++++=
++++---
>  drivers/net/ethernet/intel/e1000e/param.c     |    5 +-
>  drivers/net/ethernet/realtek/8139too.c        |   58 +++++++++++++++++=
+-
>  drivers/net/ethernet/realtek/r8169.c          |   55 +++++++++++++----=

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
>  35 files changed, 408 insertions(+), 47 deletions(-)
>

Thanks Ben, I have dropped the previous series for this latest version.=20
I cannot promise to validate the changes to the r8169 and r8139too
drivers.  But if the Realtek maintainer is fine with the changes, I will
push the entire series through my tree after we validate the e100, e1000
and e1000e changes.


--------------enig71EFE652AA5DE6C0D9797579
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQIcBAEBCgAGBQJPNh8rAAoJEOVv75VaS+3OnvIP/jkeyvCMXM7hoiuT4nEe0tHR
zGqZXn+MGUxgcgkR4GiPB1dLkqqJ+H+vJMRm4CrvFIIVe33Xb1kIJvE520BSCFDv
x46Xk7tuarvzwxIDwTqmmWAZF/Rqth3+huqzzcLYQtDS2HsiL2uGRbzLoPd1GnuU
AgvkKpl8qlaeOCN7/waTwTvyT7LzCfmQ0nfRlckOl+CGTTmsX1IBd1ho9tTCpDdA
3n/u7tiLGWnYkF3rNd2jTGZYOxLqOyMPVJK5GfjQ9+8H3bEwECr94J4wq8QDmaCS
8VR1580pmumWEO9EGyVLvNMYoSy09jPysOEMfGpyCgP247eYK+kY3kP6zhC7NEQQ
NjkKfWSIKTJB1/hiXRLhK5eRlghG8LulLQaU4OuxtnXGuhL6u2MfEC0Bi7X/G6AP
DOL1nLS8Zny07UuRphuBuQS9fOE1vhmCRMQrKjfzf8VFPBk2j++A87JYSOSdh9WO
mIFK/XUMiVBqQcL3Xr+UbYZnIW74BVCu0Ei7B+x/hRezUWEDFclQUch47IoomQgp
148CZ5Gg/Ppkc3z2LeenIzACZuWPAu6D3e+86XbaLZeJmdjswNwwJEYOu1loDXiQ
sCLsgAc9SbZgNXkB2WnRbydDHWiHP7mg0AKcSqcCVblMadJHkDvtj32qjHR39ze2
2YswK1defFczvLma8qpG
=4PZ0
-----END PGP SIGNATURE-----

--------------enig71EFE652AA5DE6C0D9797579--
