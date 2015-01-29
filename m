From: Samuel Ortiz <sameo@linux.intel.com>
Subject: [GIT] [3.20] NFC update
Date: Thu, 29 Jan 2015 01:52:16 +0100
Message-ID: <20150129005216.GA1137@ribalta.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53459 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754189AbbA2BUh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jan 2015 20:20:37 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This is the first NFC pull request for 3.20.

With this one we have:

- Secure element support for the ST Micro st21nfca driver. This depends
  on a few HCI internal changes in order for example to support more
  than one secure element per controller.

- ACPI support for NXP's pn544 HCI driver. This controller is found on
  many x86 SoCs and is typically enumerated on the ACPI bus there.

- A few st21nfca and st21nfcb fixes. Since they're not critical fixes,
  I assumed it's too late for a 3.19 inclusion. Please let me know if
  you'd prefer to see them going through a net pull request instead.


The following changes since commit 7aee42c6764bae75d0eb2f674f0874193de90c05:

  cxgb3: re-use native hex2bin() (2015-01-25 00:09:41 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/sameo/nfc-next.git tags/nfc-next-3.20-1

for you to fetch changes up to 0a5942c8e1480db4b8ee7a8d643e4945ef2f8fed:

  NFC: Add ACPI support for NXP PN544 (2015-01-28 01:09:08 +0100)

----------------------------------------------------------------
Christophe Ricard (23):
      NFC: dts: st21nfca: Fix compatible string spelling to follow other drivers
      NFC: dts: st21nfcb: Fix compatible string spelling to follow other drivers
      NFC: st21nfcb: Fix "WARNING: invalid free of devm_ allocated data"
      NFC: st21nfca: Remove unreachable code
      NFC: st21nfcb: Avoid use of skb after free
      NFC: nfc_enable_se Remove useless blank line at beginning of function
      NFC: nfc_disable_se Remove useless blank line at beginning of function
      NFC: st21nfca: Remove skb_pipe_list and skb_pipe_info useless allocation
      NFC: st21nfca: Remove checkpatch.pl warning Possible unnecessary 'out of memory' message
      NFC: st21nfca: Fix some skb memory leaks
      NFC: st21nfcb: Fix "NULL pointer dereference" possible error
      NFC: st21nfcb: Remove useless include
      NFC: st21nfcb: Fix copy/paste error in comment
      NFC: hci: Change event_received handler gate parameter to pipe
      NFC: hci: Add pipes table to reference them with a tuple {gate, host}
      NFC: hci: Change nfc_hci_send_response gate parameter to pipe
      NFC: hci: Reference every pipe information according to notification
      NFC: hci: Add cmd_received handler
      NFC: pn544: Change event_received gate parameter to pipe
      NFC: microread: Change event_received gate parameter to pipe
      NFC: hci: Remove nfc_hci_pipe2gate function
      NFC: st21nfca: Adding support for secure element
      NFC: dts: st21nfca: Document ese-present & uicc-present DTS property

Robert Dolca (2):
      NFC: PN544: GPIO access that may sleep
      NFC: Add ACPI support for NXP PN544

 .../devicetree/bindings/net/nfc/st21nfca.txt       |  11 +-
 .../devicetree/bindings/net/nfc/st21nfcb.txt       |   4 +-
 drivers/nfc/microread/microread.c                  |   3 +-
 drivers/nfc/pn544/i2c.c                            | 133 ++++++-
 drivers/nfc/pn544/pn544.c                          |   3 +-
 drivers/nfc/st21nfca/Makefile                      |   2 +-
 drivers/nfc/st21nfca/i2c.c                         |  23 +-
 drivers/nfc/st21nfca/st21nfca.c                    | 186 +++++++---
 drivers/nfc/st21nfca/st21nfca.h                    |  21 +-
 drivers/nfc/st21nfca/st21nfca_se.c                 | 390 +++++++++++++++++++++
 drivers/nfc/st21nfca/st21nfca_se.h                 |  63 ++++
 drivers/nfc/st21nfcb/i2c.c                         |  19 +-
 drivers/nfc/st21nfcb/ndlc.c                        |   3 +-
 include/linux/platform_data/st21nfca.h             |   2 +
 include/linux/platform_data/st21nfcb.h             |   4 +-
 include/net/nfc/hci.h                              |  25 +-
 net/nfc/core.c                                     |   2 -
 net/nfc/hci/command.c                              |  23 +-
 net/nfc/hci/core.c                                 |  97 +++--
 net/nfc/hci/hci.h                                  |  10 +-
 net/nfc/hci/hcp.c                                  |  11 -
 21 files changed, 886 insertions(+), 149 deletions(-)
 create mode 100644 drivers/nfc/st21nfca/st21nfca_se.c
 create mode 100644 drivers/nfc/st21nfca/st21nfca_se.h
