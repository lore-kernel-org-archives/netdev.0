From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [PATCH 2.6.27-rc8 1/6] e1000e: reset swflag after resetting hardware
Date: Thu, 02 Oct 2008 16:33:20 -0700
Message-ID: <20081002233319.12556.31820.stgit@jbrandeb-bw.jf.intel.com>
References: <20081002233314.12556.49143.stgit@jbrandeb-bw.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	tglx@linutronix.de, arjan@linux.intel.com, airlied@gmail.com,
	davem@davemloft.net, jeff@garzik.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:30429 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753915AbYJBXdU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2008 19:33:20 -0400
In-Reply-To: <20081002233314.12556.49143.stgit@jbrandeb-bw.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in the process of debugging things, noticed that the swflag is not reset
by the driver after reset, and the swflag is probably not reset unless
management firmware clears it after 100ms.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---

 drivers/net/e1000e/ich8lan.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index d8efba8..f4b6744 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -1778,6 +1778,9 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 	ew32(CTRL, (ctrl | E1000_CTRL_RST));
 	msleep(20);
 
+	/* release the swflag because it is not reset by hardware reset */
+	e1000_release_swflag_ich8lan(hw);
+
 	ret_val = e1000e_get_auto_rd_done(hw);
 	if (ret_val) {
 		/*

