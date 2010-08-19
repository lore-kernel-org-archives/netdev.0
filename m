From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/2] e1000e: disable ASPM L1 on 82573
Date: Thu, 19 Aug 2010 15:43:46 -0700
Message-ID: <20100819224307.10079.89643.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Bruce Allan <bruce.w.allan@intel.com>, stable@kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:41629
	"EHLO qmta10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751267Ab0HSWoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 18:44:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

On the e1000-devel mailing list, Nils Faerber reported latency issues with
the 82573 LOM on a ThinkPad X60.  It was found to be caused by ASPM L1;
disabling it resolves the latency.  The issue is present in kernels back
to 2.6.34 and possibly 2.6.33.


Reported-by: Nils Faerber <nils.faerber@kernelconcepts.de>
Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Cc: stable@kernel.org
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/82571.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index a4a0d2b..f844e6c 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -1833,6 +1833,7 @@ struct e1000_info e1000_82573_info = {
 				  | FLAG_HAS_SMART_POWER_DOWN
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_SWSM_ON_LOAD,
+	.flags2			= FLAG2_DISABLE_ASPM_L1,
 	.pba			= 20,
 	.max_hw_frame_size	= ETH_FRAME_LEN + ETH_FCS_LEN,
 	.get_variants		= e1000_get_variants_82571,

