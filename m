From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [PATCH net RFC 0/2] net: BUG napi_disable sleep while atomic
Date: Wed, 18 Sep 2013 13:19:43 -0700
Message-ID: <20130918201541.8697.3548.stgit@jekeller-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:3385 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751627Ab3IRUTo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Sep 2013 16:19:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series implements a fix for a possible sleep while atomic bug in
the ixgbe driver, caused because napi_disable might sleep. The first patch adds
a might_sleep() call in order to make future sleep while atomic bugs easier to
discover, (as napi_disable does not always sleep!). The second patch is my best
guess at an actual fix for the bug. There is likely a similar bug in every
driver which implemented NET_RX_BUSY_POLL similar to ixgbe. The first patch
will likely cause BUG splats to appear in those drivers unless they are fixed.

---

Jacob Keller (2):
      netdevice: add might_sleep() call to napi_disable
      ixgbe: fix sleep bug caused by napi_disable inside local_bh_disable()d context


 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 ++--
 include/linux/netdevice.h                     |    2 ++
 2 files changed, 4 insertions(+), 2 deletions(-)

--
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
