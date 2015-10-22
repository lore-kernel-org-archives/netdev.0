From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2015-10-22
Date: Thu, 22 Oct 2015 13:54:55 +0300
Message-ID: <20151022105455.GA17775@t440s.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="UugvWAfsgieZRqgk"
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:35068 "EHLO
	mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756631AbbJVK4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 06:56:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--UugvWAfsgieZRqgk
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

Here's probably the last bluetooth-next pull request for 4.4. Among
several other changes it contains the rest of the fixes & cleanups from
the Bluetooth UnplugFest (that didn't need to be hurried to 4.3).

 - Refactoring & cleanups to 6lowpan code
 - New USB ids for two Atheros controllers and BCM43142A0 from Broadcom
 - Fix (quirk) for broken Broadcom BCM2045 controllers
 - Support for latest Apple controllers
 - Improvements to the vendor diagnostic message support

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 26440c835f8b1a491e2704118ac55bf87334366c:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-10-20=
 06:08:27 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.gi=
t for-upstream

for you to fetch changes up to 13972adc3240ea8b18b44906b819c622941a64b6:

  Bluetooth: Increase minor version of core module (2015-10-22 13:37:26 +03=
00)

----------------------------------------------------------------
Alexander Aring (13):
      mac802154: llsec: use kzfree
      bluetooth: 6lowpan: use lowpan dispatch helpers
      6lowpan: introduce LOWPAN_IPHC_MAX_HC_BUF_LEN
      6lowpan: cleanup lowpan_header_compress
      6lowpan: cleanup lowpan_header_decompress
      6lowpan: remove lowpan_fetch_skb_u8
      6lowpan: nhc: move iphc manipulation out of nhc
      6lowpan: move IPHC functionality defines
      6lowpan: remove lowpan_is_addr_broadcast
      6lowpan: iphc: change define values
      6lowpan: rework tc and flow label handling
      6lowpan: put mcast compression in an own function
      ieee802154: 6lowpan: fix memory leak

Arnd Bergmann (1):
      Bluetooth: bpa10x: fix BT_HCIUART dependency

Dan Carpenter (1):
      Bluetooth: hci_bcm: checking for ERR_PTR instead of NULL

David Herrmann (1):
      Bluetooth: hidp: fix device disconnect on idle timeout

Dean Jenkins (3):
      Bluetooth: Unwind l2cap_sock_shutdown()
      Bluetooth: Reorganize mutex lock in l2cap_sock_shutdown()
      Bluetooth: l2cap_disconnection_req priority over shutdown

Dmitry Tunin (2):
      Bluetooth: ath3k: Add new AR3012 0930:021c id
      Bluetooth: ath3k: Add support of AR3012 0cf3:817b device

Johan Hedberg (16):
      Bluetooth: Don't use remote address type to decide IRK persistency
      Bluetooth: Fix removing connection parameters when unpairing
      Bluetooth: Fix missing hdev locking for LE scan cleanup
      Bluetooth: Add le_addr_type() helper function
      Bluetooth: Add hci_conn_hash_lookup_le() helper function
      Bluetooth: Use hci_conn_hash_lookup_le() when possible
      Bluetooth: 6lowpan: Use hci_conn_hash_lookup_le() when possible
      Bluetooth: Remove unnecessary indentation in unpair_device()
      Bluetooth: Add hdev helper variable to hci_le_create_connection_cancel
      Bluetooth: Remove redundant (and possibly wrong) flag clearing
      Bluetooth: Remove unnecessary hci_explicit_connect_lookup function
      Bluetooth: Disable auto-connection parameters when unpairing
      Bluetooth: Fix crash in SMP when unpairing
      Bluetooth: Introduce hci_req helper to abort a connection
      Bluetooth: Take advantage of connection abort helpers
      Bluetooth: Make hci_disconnect() behave correctly for all states

Marcel Holtmann (21):
      Bluetooth: bpa10x: Fix missing BT_HCIUART dependency
      Bluetooth: btusb: Add support for Broadcom LM_DIAG interface
      Bluetooth: btintel: Add support for enabling tracing functionality
      Bluetooth: Remove quirk for HCI_VENDOR_PKT filter handling
      Bluetooth: Restrict valid packet types via HCI_CHANNEL_RAW
      Bluetooth: Queue diagnostic messages together with HCI packets
      Bluetooth: btusb: Print information of Intel SfP lock states
      Bluetooth: Add new quirk for non-persistent diagnostic settings
      Bluetooth: btintel: Set quirk for non-persistent diagnostic settings
      Bluetooth: btintel: Add diagnostic support for older controllers
      Bluetooth: btusb: Mark BCM2045 devices to have broken link key comman=
ds
      Bluetooth: btbcm: Fix firmware version number calculation
      Bluetooth: btbcm: Read USB product information for Apple devices
      Bluetooth: Add support setup stage internal notification event
      Bluetooth: btusb: Set early vendor info for Intel and Broadcom
      Bluetooth: btusb: Add support for latest Apple controllers
      Bluetooth: hci_uart: Provide initial manufacturer information
      Bluetooth: Introduce driver specific post init callback
      Bluetooth: btusb: Set manufacturer for Intel bootloader devices
      Bluetooth: btintel: Enable extra Intel vendor events
      Bluetooth: Increase minor version of core module

Santtu Rekil=E4 (1):
      Bluetooth: btusb: Add support for Foxconn/Lenovo BCM43142A0 (105b:e06=
5)

 drivers/bluetooth/Kconfig        |   2 +-
 drivers/bluetooth/ath3k.c        |   4 +
 drivers/bluetooth/btbcm.c        |  17 +-
 drivers/bluetooth/btintel.c      | 127 +++++++
 drivers/bluetooth/btintel.h      |  24 ++
 drivers/bluetooth/btusb.c        | 306 ++++++++++++++++-
 drivers/bluetooth/hci_ath.c      |   1 +
 drivers/bluetooth/hci_bcm.c      |   5 +-
 drivers/bluetooth/hci_intel.c    |   2 +
 drivers/bluetooth/hci_ldisc.c    |   7 +
 drivers/bluetooth/hci_qca.c      |   1 +
 drivers/bluetooth/hci_uart.h     |   1 +
 include/net/6lowpan.h            | 222 ++++---------
 include/net/bluetooth/hci.h      |  10 +
 include/net/bluetooth/hci_core.h |  31 +-
 include/net/mac802154.h          |  10 +
 net/6lowpan/iphc.c               | 677 ++++++++++++++++++++++++++---------=
---
 net/6lowpan/nhc.c                |  16 +-
 net/6lowpan/nhc.h                |  12 +-
 net/6lowpan/nhc_udp.c            |  22 +-
 net/bluetooth/6lowpan.c          |  82 ++---
 net/bluetooth/af_bluetooth.c     |   2 +-
 net/bluetooth/hci_conn.c         | 167 ++++------
 net/bluetooth/hci_core.c         |  52 +--
 net/bluetooth/hci_event.c        |   3 +-
 net/bluetooth/hci_request.c      |  93 ++++++
 net/bluetooth/hci_request.h      |   4 +
 net/bluetooth/hci_sock.c         |  40 ++-
 net/bluetooth/hidp/core.c        |  14 +
 net/bluetooth/l2cap_sock.c       |  71 ++--
 net/bluetooth/mgmt.c             | 178 ++++------
 net/bluetooth/smp.c              |  60 +++-
 net/bluetooth/smp.h              |   1 +
 net/ieee802154/6lowpan/rx.c      |  39 +--
 net/ieee802154/6lowpan/tx.c      |   7 +-
 net/mac802154/llsec.c            |  20 +-
 36 files changed, 1533 insertions(+), 797 deletions(-)

--UugvWAfsgieZRqgk
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJWKMB/AAoJECQj9vv5qNQSXRIQAKbW6Z+fSZcfNOdDRSXz/jfj
dam49zOX6nLD/4S0i8FBjRth+7p9gAIcA1aWdvDnO4HtcddMdOGuXRAICinvQRV8
JRAjKOiBL3VWQ6ijOLZdSooQE+Qsrzct0/wKCfjm7RGDQSYmEAExk8kEs3u5lsOz
J9Z9DuPAuRdYiNGdlyfvffRKSWFtXvA+9W2pXAqbI/areiVvFYG+xOsW/Iu3TM7B
bRm0mtMaydTWymYgixpKO1UIbLcB8nUFHyfG3a/JleqRY2I0S09p/Uhn2gj8kfW1
mnGa0ikeuEVYSxhxw9awjMOhCeIuoPz/U1yDj0q7AWPEt6OdP4fyEoGZXh0q4tpW
+vIFO70vtqEXSvYRJeDWVkrGPyE91D8BoQYeHaHaEYztCszJk+NN6ElcqF0qCZ9Z
cAmQ0l77qGdE4KEguqg2dVny+K10PMyudYkYdlQmM4/jXvk6HTf+j/iRp0Nz828c
g29HcdhRcPfYBY7214p8wzMNeY9OF3v+xl6GBVNdWXM+27pfzuW3PBBPIHLEh8hY
kcFYkqsvkuXciJm22sAe03kPxxrDfC5V7kYtYYXlutf49Qtl76hGYVAS6eMccNwZ
JRX7s2WGBePUd5GPlRQqDWbgLtO2v8S4quEs7Y7Jxel5mBYlReYsdMoBu11/Nj2A
WASZFSMZavol09lgM9zm
=6FrJ
-----END PGP SIGNATURE-----

--UugvWAfsgieZRqgk--
