From: Samuel Ortiz <sameo@linux.intel.com>
Subject: [GIT] [3.20] 2nd NFC update
Date: Thu, 5 Feb 2015 18:47:57 +0100
Message-ID: <20150205174757.GA24523@ribalta.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:48126 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753124AbbBERsC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2015 12:48:02 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Here goes one last NFC pull request for 3.20.

It brings:

- NCI NFCEE (NFC Execution Environment, typically an embedded or
  external secure element) discovery and enabling/disabling support.
  In order to communicate with an NFCEE, we also added NCI's logical
  connections support to the NCI stack.

- HCI over NCI protocol support. Some secure elements only understand
  HCI and thus we need to send them HCI frames when they're part of
  an NCI chipset.

- NFC_EVT_TRANSACTION userspace API addition. Whenever an application
  running on a secure element needs to notify its host counterpart,
  we send an NFC_EVENT_SE_TRANSACTION event to userspace through the
  NFC netlink socket.

- Secure element and HCI transaction event support for the st21nfcb
  chipset.

Thanks in advance for pulling them in.

The following changes since commit 86b3bfe914f41c2d47d5882d06e1261cc58fb5e9:

  pkt_sched: fq: remove useless TIME_WAIT check (2015-01-28 23:23:57 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/sameo/nfc-next.git tags/nfc-next-3.20-2

for you to fetch changes up to fa00e8fed457841cb24219dbe3cfba7d56de6317:

  NFC: nci: Move NFCEE discovery logic (2015-02-04 09:15:18 +0100)

----------------------------------------------------------------
Christophe Ricard (17):
      NFC: nci: Add dynamic logical connections support
      NFC: nci: Add NCI NFCEE constants
      NFC: nci: Add NFCEE discover support
      NFC: nci: Add NFCEE enabling and disabling support
      NFC: nci: Support logical connections management
      NFC: nci: Add HCI over NCI protocol support
      NFC: st21nfcb: Add support for secure element
      NFC: Forward NFC_EVT_TRANSACTION to user space
      NFC: nci: Add RF NFCEE action notification support
      NFC: nci: Change NCI state machine to LISTEN_ACTIVE
      NFC: st21nfcb: Add HCI transaction event support
      NFC: st21nfca: Add HCI transaction event support
      NFC: nci: Add reference to the RF logical connection
      NFC: nci: Support all destinations type when creating a connection
      NFC: nci: Change credits field to credits_cnt
      NFC: nci: Move logical connection structure allocation
      NFC: nci: Move NFCEE discovery logic

 drivers/nfc/st21nfca/st21nfca_se.c |  21 ++
 drivers/nfc/st21nfcb/Makefile      |   2 +-
 drivers/nfc/st21nfcb/st21nfcb.c    |  11 +-
 drivers/nfc/st21nfcb/st21nfcb.h    |   2 +
 drivers/nfc/st21nfcb/st21nfcb_se.c | 707 +++++++++++++++++++++++++++++++++++++
 drivers/nfc/st21nfcb/st21nfcb_se.h |  61 ++++
 include/net/nfc/nci.h              |  97 +++++
 include/net/nfc/nci_core.h         | 137 ++++++-
 include/net/nfc/nfc.h              |  27 ++
 include/uapi/linux/nfc.h           |   1 +
 net/nfc/core.c                     |  21 ++
 net/nfc/nci/Makefile               |   2 +-
 net/nfc/nci/core.c                 | 169 ++++++++-
 net/nfc/nci/data.c                 |  56 ++-
 net/nfc/nci/hci.c                  | 694 ++++++++++++++++++++++++++++++++++++
 net/nfc/nci/ntf.c                  |  77 +++-
 net/nfc/nci/rsp.c                  | 120 ++++++-
 net/nfc/netlink.c                  |  47 +++
 net/nfc/nfc.h                      |   2 +
 19 files changed, 2203 insertions(+), 51 deletions(-)
 create mode 100644 drivers/nfc/st21nfcb/st21nfcb_se.c
 create mode 100644 drivers/nfc/st21nfcb/st21nfcb_se.h
 create mode 100644 net/nfc/nci/hci.c
