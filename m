From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 0/3] Replace wmb()/rmb() with dma_wmb()/dma_rmb()
 where appropriate
Date: Tue, 07 Apr 2015 16:55:08 -0700
Message-ID: <20150407235324.1574.63255.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51064 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752871AbbDGXzJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2015 19:55:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a start of a side project cleaning up the drivers that can make use
of the dma_wmb and dma_rmb calls.  The general idea is to start removing
the unnecessary wmb/rmb calls from a number of drivers and to make use of
the lighter weight dma_wmb/dma_rmb calls as this should allow for an
overall improvement in performance as each barrier can cost a significant
number of cycles and on architectures such as x86 this is unnecessary.

These changes are what I would consider low hanging fruit.  The likelihood
of the changes introducing an error should be low since the use of the
barriers in these cases are fairly obvious.

---

Alexander Duyck (3):
      sungem, sunhme, sunvnet: Update drivers to use dma_wmb/rmb
      s2io: Update driver to use dma_wmb
      e1000, e1000e: Use dma_rmb instead of rmb for descriptor read ordering


 drivers/net/ethernet/intel/e1000/e1000_main.c |    6 +++---
 drivers/net/ethernet/intel/e1000e/netdev.c    |    8 ++++----
 drivers/net/ethernet/neterion/s2io.c          |    8 ++++----
 drivers/net/ethernet/sun/sungem.c             |   14 +++++++-------
 drivers/net/ethernet/sun/sunhme.c             |   16 ++++++++--------
 drivers/net/ethernet/sun/sunvnet.c            |    6 +++---
 6 files changed, 29 insertions(+), 29 deletions(-)

--
