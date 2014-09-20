From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH v1.1 0/2] PTP related changes for fm10k
Date: Sat, 20 Sep 2014 13:14:03 -0400
Message-ID: <20140920170138.25490.40273.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:31712 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753961AbaITRWq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Sep 2014 13:22:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm looking for feedback on what will be the v2 of PTP patches I will be
submitting for the fm10k driver.  I thought I would spare the list the job
of reviewing the other 27 patches since any changes there are trivial.

I believe I have addressed most of the original concerns with it.  The only
thing I wasn't able to specifically address is the fact that we cannot
change what the actual hardware clock value is.  If I hadn't made it clear
before the problem is the hardware clock is shared between all PCIe
functions on the switch so stopping it or drastically altering the value
would significantly throw off any attempt at keeping the clock sane across
the 585 PCIe functions (9 PF, and 9x64 VFs) that this switch can support,
all of which share the same SYSTIME clock reference.

---

Alexander Duyck (2):
      fm10k: Add support for ptp to hw specific files
      fm10k: Add support for PTP


 drivers/net/ethernet/intel/fm10k/Makefile        |    2 
 drivers/net/ethernet/intel/fm10k/fm10k.h         |   37 ++
 drivers/net/ethernet/intel/fm10k/fm10k_common.h  |    8 
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c |   30 +
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    |   20 +
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c  |   20 +
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     |  112 +++++
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c      |   99 +++++
 drivers/net/ethernet/intel/fm10k/fm10k_ptp.c     |  463 ++++++++++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_type.h    |   14 +
 drivers/net/ethernet/intel/fm10k/fm10k_vf.c      |   55 +++
 drivers/net/ethernet/intel/fm10k/fm10k_vf.h      |   10 
 12 files changed, 869 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_ptp.c

-- 
