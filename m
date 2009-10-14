From: Gregory Haskins <ghaskins@novell.com>
Subject: [NET PATCH 0/9] ZC/L4RO enhancements to alacrityvm::vbus-enet driver
Date: Wed, 14 Oct 2009 11:58:45 -0400
Message-ID: <20091014154457.18864.28382.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: alacrityvm-devel@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934678AbZJNP7d@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following series applies to the "linux-next" branch in the
alacrityvm tree:

git://git.kernel.org/pub/scm/linux/kernel/git/ghaskins/alacrityvm/linux-2.6.git

These patches add support for zero-copy, and reassembly-offloading to the
venet driver.  This means we can transmit a guest GSO packet directly into
the host hardware, and receive fully reassembled LRO frames without
artificially segmenting them.

Unofficial testing against a ZC/L4RO capable backend show that we are
supporting about 6.6Gb/s in throughput (vs 7.3Gb/s for native) which is
up from the prior result of 5.7Gb/s without affecting our latency numbers.
I will officially re-run my tests and update the graphs asap.

http://developer.novell.com/wiki/index.php/AlacrityVM

Kind Regards,
-Greg

---

Gregory Haskins (9):
      venet: add Layer-4 Reassembler Offload (L4RO) support
      venet: add a tx-complete event for out-of-order support
      venet: use an skblist for outstanding descriptors
      venet: add eventq protocol
      venet: cache the ringlen values at init
      venet: report actual used descriptor size
      venet: add pre-mapped tx descriptor feature
      venet: fix gso.hdr_len to report correct length
      venet: Update maintainer


 MAINTAINERS             |    7 
 drivers/net/vbus-enet.c |  770 +++++++++++++++++++++++++++++++++++++++++++----
 include/linux/venet.h   |   61 +++-
 3 files changed, 764 insertions(+), 74 deletions(-)
