From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2015-02-03
Date: Tue, 3 Feb 2015 10:21:23 +0200
Message-ID: <20150203082123.GA13130@t440s.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3V7upXqbjpZ4EhLz"
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:64852 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbbBCIVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 03:21:33 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's what's likely the last bluetooth-next pull request for 3.20.
Notable changes include:

 - xHCI workaround + a new id for the ath3k driver
 - Several new ids for the btusb driver
 - Support for new Intel Bluetooth controllers
 - Minor cleanups to ieee802154 code
 - Nested sleep warning fix in socket accept() code path
 - Fixes for Out of Band pairing handling
 - Support for LE scan restarting for HCI_QUIRK_STRICT_DUPLICATE_FILTER
 - Improvements to data we expose through debugfs
 - Proper handling of Hardware Error HCI events

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 0c49087462e8587c12ecfeaf1dd46fdc0ddc4532:

  Merge tag 'mac80211-next-for-davem-2015-01-19' of git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next (2015-01-19 16:22:19 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to 88d9077c27d0c1a7c022d9dc987640beecf23560:

  Bluetooth: Fix potential NULL dereference (2015-02-03 09:02:12 +0100)

----------------------------------------------------------------
Adam Lee (1):
      Bluetooth: ath3k: workaround the compatibility issue with xHCI controller

Dmitry Tunin (1):
      Bluetooth: ath3k: Add support of AR3012 bluetooth 13d3:3423 device

Jakub Pawlowski (4):
      Bluetooth: Set HCI_QUIRK_STRICT_DUPLICATE_FILTER for BTUSB_ATH3012
      Bluetooth: Set HCI_QUIRK_STRICT_DUPLICATE_FILTER for BTUSB_INTEL
      Bluetooth: Add le_scan_restart work for LE scan restarting
      Bluetooth: Add restarting to service discovery

Johan Hedberg (12):
      Bluetooth: Check for valid bdaddr in add_remote_oob_data
      Bluetooth: Remove incorrect check for BDADDR_BREDR address type
      Bluetooth: Convert Set SC to use HCI Request
      Bluetooth: Enforce zero-valued hash/rand192 for LE OOB
      Bluetooth: btusb: Remove redundant call to btusb_free_frags()
      Bluetooth: Fix check for SSP when enabling SC
      Bluetooth: Fix notifying discovery state upon reset
      Bluetooth: Fix notifying discovery state when powering off
      Bluetooth: btusb: Fix race when waiting for BTUSB_DOWNLOADING
      Bluetooth: btusb: Use wait_on_bit_timeout() for BTUSB_BOOTING
      Bluetooth: Remove mgmt_rp_read_local_oob_ext_data struct
      Bluetooth: Fix potential NULL dereference

Marcel Holtmann (28):
      Bluetooth: Fix dependency for BR/EDR Secure Connections mode on SSP
      Bluetooth: Limit BR/EDR switching for LE only with secure connections
      Bluetooth: Require SSP enabling before BR/EDR Secure Connections
      Bluetooth: btusb: Add support for Dynex/Insignia USB dongles
      Bluetooth: btusb: Add firmware loading for Intel Snowfield Peak devices
      Bluetooth: Clear P-192 values for OOB when in Secure Connections Only mode
      Bluetooth: Use helper function to determine BR/EDR OOB data present
      Bluetooth: Check for P-256 OOB values in Secure Connections Only mode
      Bluetooth: btusb: Handle out of order firmware loading complete event
      Bluetooth: Introduce hci_dev_do_reset helper function
      Bluetooth: Perform a power cycle when receiving hardware error event
      Bluetooth: btusb: Provide hardware error handler for Intel devices
      Bluetooth: Move smp_unregister() into hci_dev_do_close() function
      Bluetooth: btusb: Sort USB_DEVICE entries for Marvell by vendor id
      Bluetooth: btusb: Ignore unknown Intel devices with generic descriptor
      Bluetooth: btusb: Add support for USB based AMP controllers
      Bluetooth: btusb: Limit hardware error handling to Intel Snowfield Peak
      Bluetooth: Store OOB data present value for each set of remote OOB data
      Bluetooth: Fix OOB data present value for BR/EDR Secure Connections
      Bluetooth: Fix OOB data present value for SMP pairing
      Bluetooth: Allow remote OOB data to only provide P-192 or P-256 values
      Bluetooth: Expose Secure Simple Pairing debug mode setting in debugfs
      Bluetooth: Track changes from HCI Write Simple Pairing Debug Mode command
      Bluetooth: Expose debug keys usage setting via debugfs
      Bluetooth: Expose hardware error code as debugfs entry
      Bluetooth: Expose remote OOB information as debugfs entry
      Bluetooth: Fix OOB data present for BR/EDR Secure Connections Only mode
      Bluetooth: Set HCI_QUIRK_STRICT_DUPLICATE_FILTER for BTUSB_INTEL_NEW

Matej Dubovy (1):
      Bluetooth: btusb: Add support for Lite-On (04ca) Broadcom based, BCM43142

Mohammad Jamal (2):
      ieee802154: cc2520: Replace shift operations by BIT macro
      ieee802154: cc2520: Fix space before , coding style issue

Peter Hurley (1):
      Bluetooth: Fix nested sleeps

Rick Dunn (1):
      Bluetooth: btusb: Add Broadcom patchram support for ASUSTek devices

Szymon Janc (2):
      Bluetooth: Fix reporting invalid RSSI for LE devices
      Bluetooth: Fix sending Read Remote Extended Features command

 drivers/bluetooth/ath3k.c        |  10 +
 drivers/bluetooth/btusb.c        | 671 +++++++++++++++++++++++++++++++++++++-
 drivers/net/ieee802154/cc2520.c  |  10 +-
 include/net/bluetooth/hci_core.h |  11 +-
 include/net/bluetooth/mgmt.h     |   4 -
 net/bluetooth/bnep/core.c        |   7 +-
 net/bluetooth/hci_core.c         | 169 ++++++++--
 net/bluetooth/hci_debugfs.c      |  79 ++++-
 net/bluetooth/hci_event.c        | 135 ++++++--
 net/bluetooth/l2cap_sock.c       |   9 +-
 net/bluetooth/mgmt.c             | 279 +++++++++++-----
 net/bluetooth/rfcomm/sock.c      |   9 +-
 net/bluetooth/sco.c              |   8 +-
 net/bluetooth/smp.c              |   2 +-
 14 files changed, 1214 insertions(+), 189 deletions(-)


--3V7upXqbjpZ4EhLz
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJU0IUDAAoJECQj9vv5qNQS6jAP/2k89+yWyCJCUArPhhbkv/+x
bg48hXGOX78ejgSFgPhUSFM1rhwDtOnTx8/d3L4s6FF/tJeOB85qeHOeuDtkusAf
11OUb4lroQLgGoxv4wYsiGsDWbUyH/bMK9Y0T+9pUVsv9Lj00vaT0QvqJMjL6AJQ
LxKMqkAqnYlKfJxfVttMmRWe2Y8UI8UNE4UbCliRWYILcf6tk0uoa7Apu+wVyXvo
1w8sqidIS2q2AJxdn12yKaytRGVnkvX8Az7hc3Vf3MRBZzd8txt1CPSqV5nPhLD2
5ykudxmbuiRzo3rtEXsZ9MaFNi/NfXPHseIcHQln1V3Pkqljzob6A9O3iGexUO0G
nX2FU8oBhDJX5zWQv4RVzzeYIsPSP00A2tb9yXQb4P6x7j/FjzYbl5O0vkzA5wK9
gATA5KlYlUqDft0YeK9BjaapItE5xZoEpCraHsrQuLPOD2A1l/fLs0pDYrT8bQBu
PxFN5RMDktoCw81oxwsVgzH7ZUQO72qg2ewJw4CEEdfwgYOsjS5JJ10v7Z9ozTJ7
CH5qt80GC0ofF7biP1sUu6+sW4IOccPNTKkH4yqOieOFHvKxd+JQe/vJrL7KY8Xr
r9TR9A7gKjtCvIUAiT0U06UnzT3hZFKd3jmnhL7YbDEbjXwY4DCCLrkYTo8PszAl
ygz4v8aCz62hdWywLeCd
=+TMI
-----END PGP SIGNATURE-----

--3V7upXqbjpZ4EhLz--
