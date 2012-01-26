From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/12] e1000e: 82574/82583 Tx hang workaround
Date: Wed, 25 Jan 2012 23:21:55 -0800
Message-ID: <1327562515-29664-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1327562515-29664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:54466 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751710Ab2AZHWD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 02:22:03 -0500
In-Reply-To: <1327562515-29664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

On 82574/82583, there is a hardware bug which might cause a Tx hang when
the internal buffer is full.  Setting this bit enables a hardware fix to
work around the issue.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/82571.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index a3e65fd..0609ac6 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -1227,6 +1227,10 @@ static void e1000_initialize_hw_bits_82571(struct e1000_hw *hw)
 	case e1000_82572:
 		reg |= (1 << 23) | (1 << 24) | (1 << 25) | (1 << 26);
 		break;
+	case e1000_82574:
+	case e1000_82583:
+		reg |= (1 << 26);
+		break;
 	default:
 		break;
 	}
-- 
1.7.7.6
