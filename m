From: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: [GIT] [4.8] NFC update
Date: Thu, 21 Jul 2016 00:37:48 +0200
Message-ID: <20160720223748.GA3313@zurbaran.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux NFC <linux-nfc-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org>,
	Linux Wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi David,

This is the first NFC pull request for 4.8. We have:

- A fairly large NFC digital stack patchset:
  * RTOX fixes.
  * Proper DEP RWT support.
  * ACK and NACK PDUs handling fixes, in both initiator
    and target modes.
  * A few memory leak fixes.

- A conversion of the nfcsim driver to use the digital stack.
  The driver supports the DEP protocol in both NFC-A and NFC-F.

- Error injection through debugfs for the nfcsim driver.

- Improvements to the port100 driver for the Sony USB chipset, in
  particular to the command abort and cancellation code paths.

- A few minor fixes for the pn533, trf7970a and fdp drivers.

The following changes since commit 8186f6e382d8719d0a4bc0ef218c4dd7cf55b496:

  net-next: mediatek: fix compile error inside mtk_poll_controller() (2016-07-02 15:22:29 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/sameo/nfc-next.git tags/nfc-next-4.8-1

for you to fetch changes up to 2a0fe4fe5bf2a6e2277354e7e8f369a20d881891:

  NFC: nfcsim: Simulate lost frames through debugfs entry (2016-07-19 23:24:49 +0200)

----------------------------------------------------------------
Colin Ian King (1):
      NFC: set info->ram_patch to NULL when it is released

Dan Carpenter (1):
      NFC: pn533: double free on error in probe()

Denys Vlasenko (1):
      NFC: hci: delete unused nfc_llc_get_rx_head_tail_room()

Geert Uytterhoeven (1):
      NFC: fdp: Detect errors from fdp_nci_create_conn()

Geoff Lansberry (1):
      NFC: trf7970a: add TI recommended write of zero to Register 0x18

Thierry Escande (26):
      NFC: port100: Explicitly set NFC-F framing for NFC-DEP
      NFC: digital: Add a delay between poll cycles
      NFC: llcp: Use dynamic debug for hex dump
      NFC: nfcsim: Make use of the Digital layer
      NFC: llcp: Fix usage of llcp_add_tlv()
      NFC: llcp: Fix 2 memory leaks
      NFC: port100: Don't send a new command if one is still pending
      NFC: port100: Fix the command cancellation process
      NFC: port100: Make port100_abort_cmd() synchronous
      NFC: port100: Abort current command before switching RF off
      NFC: nfcsim: Fix missing dependency on NFC_DIGITAL
      NFC: digital: Fix a memory leak in NFC-F listening mode
      NFC: digital: Rework error handling in DEP_RES response
      NFC: digital: Call pending command callbacks at device unregister
      NFC: digital: Set the command pending flag
      NFC: digital: Abort last command when dep link goes down
      NFC: digital: Fix handling of saved PDU sk_buff pointers
      NFC: digital: Remove useless call to skb_reserve()
      NFC: digital: Fix target DEP_REQ I-PDU handling after ATN PDU
      NFC: digital: Fix ACK & NACK PDUs handling in target mode
      NFC: digital: Rework ACK PDU handling in initiator mode
      NFC: digital: Free supervisor PDUs
      NFC: digital: Add support for NFC DEP Response Waiting Time
      NFC: digital: Fix RTOX supervisor PDU handling
      NFC: nfcsim: Add support for sysfs control entry
      NFC: nfcsim: Simulate lost frames through debugfs entry

 drivers/nfc/Kconfig          |   1 +
 drivers/nfc/fdp/fdp.c        |   6 +-
 drivers/nfc/nfcsim.c         | 643 ++++++++++++++++++++-----------------------
 drivers/nfc/pn533/usb.c      |   9 +-
 drivers/nfc/port100.c        |  82 +++++-
 drivers/nfc/trf7970a.c       |   4 +
 include/net/nfc/digital.h    |   4 +-
 include/net/nfc/llc.h        |   4 -
 net/nfc/digital_core.c       |  28 +-
 net/nfc/digital_dep.c        | 316 ++++++++++++++-------
 net/nfc/digital_technology.c |  11 +-
 net/nfc/hci/llc.c            |  17 +-
 net/nfc/llcp_commands.c      |  23 +-
 net/nfc/llcp_core.c          |   9 +-
 14 files changed, 648 insertions(+), 509 deletions(-)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
