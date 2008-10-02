From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [PATCH 2.6.27-rc8 0/1] e1000e nvm fix
Date: Wed, 01 Oct 2008 17:18:30 -0700
Message-ID: <20081002001830.5951.3123.stgit@jbrandeb-bw.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	arjan@linux.intel.com
To: torvalds@linux-foundation.org, jeff@garzik.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:3768 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751706AbYJBASb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2008 20:18:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please apply to 2.6.27

This is related to regression bugzilla:
http://bugzilla.kernel.org/show_bug.cgi?id=11382

This patch is meant to prevent all future corruptions of the
e1000e NVM (non volatile memory) after the driver is loaded.  The
registers stay locked until the machine is power cycled.

This should allow us to move forward with debugging without
allowing any other bad element or the e1000e driver, to write to
the NVM area unexpectedly.

Currently we (Intel Ethernet) are reproducing the issue on
multiple machines in house, we are working on the issue with the
other core Linux teams here at Intel and within the community. No
resolution yet but we are much closer now.

Later we will post patches to help users who have had this
problem restore their eeprom from either a saved image from
ethtool -e or from another identical system.

There is a set of patches to help clean up the driver's use of
the hardware/software semaphore, but those are un-necessary to be
immediately applied once we're locking the NVM.  We will push
those for inclusion within the merge window for 2.6.28.

---

Bruce Allan (1):
      e1000e: write protect ICHx NVM to prevent malicious write/erase


 drivers/net/e1000e/e1000.h   |    2 +
 drivers/net/e1000e/ethtool.c |    3 ++
 drivers/net/e1000e/ich8lan.c |   58 ++++++++++++++++++++++++++++++++++++++++++
 drivers/net/e1000e/netdev.c  |   10 +++++--
 drivers/net/e1000e/param.c   |   30 ++++++++++++++++++++++
 5 files changed, 100 insertions(+), 3 deletions(-)

--
Jesse Brandeburg
