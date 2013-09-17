From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [PATCH net RFC 0/2] Series short description
Date: Mon, 16 Sep 2013 17:59:16 -0700
Message-ID: <20130917005703.13357.70276.stgit@jekeller-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:56628 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751525Ab3IQA7R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Sep 2013 20:59:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains patches which help resolve a 'sleeping function called
from invalid context' bug introduced by the busy polling code. The first patch
simply adds a might_sleep() call to napi_disable. The second patch provides the
actual fix for the sleeping during a local_bh_disable()d section of code. I
tried to Cc everyone that might be interested in the solution, as I am unsure
if my solution of moving the local_bh_disable() call is correct.

---

Jacob Keller (2):
      netdevice: add might_sleep() call to napi_disable
      ixgbe: fix sleep bug caused by napi_disable inside local_bh_disable()d context


 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 ++--
 include/linux/netdevice.h                     |    2 ++
 2 files changed, 4 insertions(+), 2 deletions(-)

--
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
