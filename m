From: Ed Tomlinson <edt@aei.ca>
Subject: Re: [GIT] Networking
Date: Sun, 17 Jul 2011 10:36:17 -0400
Message-ID: <201107171036.18470.edt@aei.ca>
References: <20110716.104325.1217042780857481057.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail001.aei.ca ([206.123.6.130]:55975 "EHLO mail001.aei.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752866Ab1GQOg0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2011 10:36:26 -0400
In-Reply-To: <20110716.104325.1217042780857481057.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 16 July 2011 13:43:25 David Miller wrote:
>=20
> A small batch of fixes:
>=20
> 1) Fix two regressions in checksum offload handling.
>    a) Do not set SCTP packets to CHECKSUM_UNNECESSARY, we don't
>       have software fallbacks in the TX path for SCTP checksumming
>       and therefore won't be able to handle a divert of a packet
>       from a device that can do SCTP checksums to one that cannot.
>    b) We propagate certain hardware offloads transparently through
>       "software" devices (like vlan and bonding) but we cannot do
>       that when we lack software fallbacks in the TX path and this
>       is relevant for SCTP and FCoE checksumming.  Get rid of the
>       NETIF_F_ALL_TX_OFFLOADS macro since it's misuse is what
>       introduced this regression.
>=20
> 2) L2CAP bluetooth connection procedure regression fix from
>    Gustavo F. Padovan.
>=20
> 3) L2CAP incomming connections can crash with defer_setup enabled
>    because ->parent isn't setup yet, handle that properly.  Also
>    from Gustavo.
>=20
> 4) gianfar driver need to be more selective of when the RX parser
>    of the chip is enabled, from Sebastian Poehn.
>=20
> 5) r6040 NAPI logic has a bug that can disabled interrupts forever,
>    fix from Michael Thalmeier.
>=20
> Please pull, thanks a lot!
>=20
> The following changes since commit 1765a367a3b5d5e9692949b0c5ec933eff=
2c0701:
>=20
>   Merge branch 'gpio/merge' of git://git.secretlab.ca/git/linux-2.6 (=
2011-07-15 18:03:30 -0700)
>=20
> are available in the git repository at:
>=20
>   master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git maste=
r
>=20
> Gustavo F. Padovan (1):
>       Bluetooth: Fix regression in L2CAP connection procedure
>=20
> Ilia Kolomisnky (1):
>       Bluetooth: Fix crash with incoming L2CAP connections
>=20
> Michael Thalmeier (1):
>       r6040: only disable RX interrupt if napi_schedule_prep is succe=
ssful
>=20
> Micha=C5=82 Miros=C5=82aw (2):
>       net: sctp: fix checksum marking for outgoing packets
>       net: remove NETIF_F_ALL_TX_OFFLOADS
>=20
> Sebastian P=C3=B6hn (1):
>       gianfar: rx parser
>=20
>  drivers/net/bonding/bond_main.c |    6 +++---
>  drivers/net/gianfar.c           |   24 +++++++++++++++++++-----
>  drivers/net/gianfar.h           |    3 ++-
>  drivers/net/r6040.c             |    8 +++++---
>  include/linux/netdevice.h       |    6 ------
>  net/8021q/vlan_dev.c            |    6 +++++-
>  net/bluetooth/l2cap_core.c      |    9 +++++----
>  net/sctp/output.c               |   19 ++++++++-----------
>  8 files changed, 47 insertions(+), 34 deletions(-)

This just to confirm that Gustavo's fixes correct the problems reported=
 in thread: "[BUG] Bluetooth broken post rc7"

Ed=20
