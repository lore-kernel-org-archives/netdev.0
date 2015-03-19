From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2015-03-19
Date: Thu, 19 Mar 2015 16:56:26 +0200
Message-ID: <20150319145626.GA19462@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ibTvN161/egqYuK8"
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:33337 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751394AbbCSO4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 10:56:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

This wont the last 4.1 bluetooth-next pull request, but we've piled up
enough patches in less than a week that I wanted to save you from a
single huge "last-minute" pull somewhere closer to the merge window.

The main changes are:

 - Simultaneous LE & BR/EDR discovery support for HW that can do it
 - Complete LE OOB pairing support
 - More fine-grained mgmt-command access control (normal user can now do
   harmless read-only operations).
 - Added RF power amplifier support in cc2520 ieee802154 driver
 - Some cleanups/fixes in ieee802154 code

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 96026d057a1fb7da1e314a24e3a1c528321ed45e:

  net: dsa: do not use slave MII bus for fixed PHYs (2015-03-14 19:16:44 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to ea6edfbcefec1fcfdb826a1d5a054f402dfbfb24:

  mac802154: fix typo in header guard (2015-03-19 15:32:22 +0100)

----------------------------------------------------------------
Alexander Aring (1):
      at86rf230: fix at86rf230_read_subreg succeed handling

Brad Campbell (2):
      cc2520: Do not store platform_data in spi_device
      cc2520: Add support for CC2591 amplifier.

Jakub Pawlowski (6):
      Bluetooth: Introduce HCI_QUIRK_SIMULTANEOUS_DISCOVERY
      Bluetooth: Refactor BR/EDR inquiry and LE scan triggering.
      Bluetooth: Add simultaneous dual mode scan
      Bluetooth: Set HCI_QUIRK_SIMULTANEOUS_DISCOVERY for BTUSB_ATH3012
      Bluetooth: Set HCI_QUIRK_SIMULTANEOUS_DISCOVERY for BTUSB_INTEL
      Bluetooth: Set HCI_QUIRK_SIMULTANEOUS_DISCOVERY for BTUSB_CSR

Johan Hedberg (12):
      Bluetooth: Fix local OOB data handling for SMP
      Bluetooth: Track local vs remote OOB data availability
      Bluetooth: Set local OOB data flag if remote has our OOB data
      Bluetooth: Fix verifying confirm value when lacking remote OOB data
      Bluetooth: Don't send public key if OOB data verification fails
      Bluetooth: Add clarifying comment when setting local OOB flag
      Bluetooth: Add helper to get HCI channel of a socket
      Bluetooth: Add channel parameter to mgmt_pending_find() API
      Bluetooth: Add generic mgmt helper API
      Bluetooth: Add hdev_init callback for HCI channels
      Bluetooth: Move generic mgmt command dispatcher to hci_sock.c
      Bluetooth: Add workaround for broken OS X legacy SMP pairing

Marcel Holtmann (37):
      Bluetooth: Add flags field and setting function for HCI sockets
      Bluetooth: Provide hci_send_to_flagged_channel helper function
      Bluetooth: Use special function to send filter management index events
      Bluetooth: Add support for extended index management events
      Bluetooth: Add support for extended index management command
      Bluetooth: Introduce trusted flag for management control sockets
      Bluetooth: Consolidate socket channel sending function back into one
      Bluetooth: Add hci_sock_test_flag helper function
      Bluetooth: Add support for untrusted access to management commands
      Bluetooth: Remove unneeded initializer for management command table
      Bluetooth: Add support for trust verification of management commands
      Bluetooth: Open management interface for untrusted users
      Bluetooth: Send global configuration updates to all management users
      Bluetooth: Use BIT(n) macro instead of manually encoding (1 << n)
      Bluetooth: Add simple version of Read Advertising Features command
      Bluetooth: Move eir_append_data function to a different location
      Bluetooth: Add defines for LE Bluetooth Device Address and LE Role
      Bluetooth: Add simple version of Read Local OOB Extended Data command
      Bluetooth: Fix BR/EDR out-of-band pairing with only initiator data
      Bluetooth: Remove unneeded HCI_CONN_REMOTE_OOB connection flag
      Bluetooth: Use kzfree instead of kfree in security manager
      Bluetooth: Create SMP device structure for local crypto context
      Bluetooth: Add constants for LE SC Confirmation and Random values
      Bluetooth: Add support for AES-CMAC hash for security manager device
      Bluetooth: Add function for generating LE SC out-of-band data
      Bluetooth: Return LE SC confirm and random values for out-of-band data
      Bluetooth: Use OOB key pair for LE SC pairing with OOB method
      Bluetooth: Use smp->local_pk + 32 instead of &smp->local_pk[32]
      Bluetooth: Use smp->remote_pk + 32 instead of &smp->remote_pk[32]
      Bluetooth: Add extra SMP_DBG statement for remote OOB data
      Bluetooth: Rename smp->local_rr into smp->local_rand
      Bluetooth: The P-256 randomizer is 16 octets long and not 19 octets
      Bluetooth: Do not include LE SC out-of-band data if not enabled
      Bluetooth: Fix length for Read Local OOB Extended Data respone packet
      Bluetooth: Add support for Local OOB Extended Data Update events
      Bluetooth: btusb: Fix minor whitespace issue in QCA ROME device entries
      Bluetooth: Fix potential NULL dereference in SMP channel setup

Nicolas Iooss (1):
      mac802154: fix typo in header guard

 .../devicetree/bindings/net/ieee802154/cc2520.txt  |    4 +
 drivers/bluetooth/btusb.c                          |    8 +-
 drivers/net/ieee802154/at86rf230.c                 |    2 +-
 drivers/net/ieee802154/cc2520.c                    |  150 ++-
 include/linux/spi/cc2520.h                         |    1 +
 include/net/bluetooth/bluetooth.h                  |    5 +
 include/net/bluetooth/hci.h                        |   22 +
 include/net/bluetooth/hci_core.h                   |   14 +-
 include/net/bluetooth/mgmt.h                       |   50 +
 net/bluetooth/Makefile                             |    2 +-
 net/bluetooth/hci_core.c                           |   24 +-
 net/bluetooth/hci_debugfs.c                        |    2 +-
 net/bluetooth/hci_event.c                          |   78 +-
 net/bluetooth/hci_sock.c                           |  180 +++-
 net/bluetooth/mgmt.c                               | 1037 ++++++++++---------
 net/bluetooth/mgmt_util.c                          |  210 ++++
 net/bluetooth/mgmt_util.h                          |   53 +
 net/bluetooth/smp.c                                |  278 ++++-
 net/bluetooth/smp.h                                |    1 +
 net/mac802154/driver-ops.h                         |    4 +-
 20 files changed, 1485 insertions(+), 640 deletions(-)
 create mode 100644 net/bluetooth/mgmt_util.c
 create mode 100644 net/bluetooth/mgmt_util.h


--ibTvN161/egqYuK8
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVCuOZAAoJECQj9vv5qNQSXRQQAJ+AOqi2OBNxN8IRS7P9+/u/
qZp3UCFovTVQLp1bd4gHNCmqA4dIt+frupsRaJuSLNSH3r8Q6se4hJZTve6OoGZP
zxx2+PlF19HWf+ZPF6l6TOscKkbIklZrv3HYuzzKxbXB3y8MiMQscoRL6WVruSeN
xdH3ifwPRaDMCKRHIHzBc8+SgC9C1jyk5jJftLx4czOsO0Ppvgew391+hxNzmVXz
PBDyFno8A2fbH42x9HzCy8qUmfmIpPQf46pWrYSkk45g1G0VETW3rPA1LIXXHwc1
/PThzvgP6kLuq/efG7YT2/Yx89crypCPNPDIO9nW2PcXXtPnPLEQw3CfkPU2AjDs
gNqPgEZ7YnQ0LF1H7WIMCvfCAAPrA7vaTB79gALDl+wkBEGHNp1czhuwITtgJWu4
Zb8gxMQq0SpykgRzc7h4kEOIDTrp5nDnNsiifTQf3l1LpZHDXEC4EWtj16F2jiIY
Hf5poudREkv2COImTpxtQpXRyIGFaEHjuI8WLdmiuFAloGXE1MjdbAe8t2j/i9hL
r3/a9EqRCnIy1YXMF3u9H3HBL/2nnown1X3Hnmcy6gsw5N5aQwzIgCODMFUvcqit
dFETx/4Aey06gQ/QNg5NbmYhfeIJc18H7ZdcLNlHT1jWEoO2g1QQwPJrRwHR/pSD
ndG4NJ+EumJojuXniKfI
=19TA
-----END PGP SIGNATURE-----

--ibTvN161/egqYuK8--
