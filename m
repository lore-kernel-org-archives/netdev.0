From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 7/7] e1000: Use time_after() for time comparison
Date: Wed,  4 Jun 2014 00:05:00 -0700
Message-ID: <1401865500-18081-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401865500-18081-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:21709 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755305AbaFDHFH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2014 03:05:07 -0400
In-Reply-To: <1401865500-18081-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Manuel Sch=C3=B6lling <manuel.schoelling@gmx.de>

To be future-proof and for better readability the time comparisons are =
modified
to use time_after() instead of plain, error-prone math.

Signed-off-by: Manuel Sch=C3=B6lling <manuel.schoelling@gmx.de>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers=
/net/ethernet/intel/e1000/e1000_ethtool.c
index 341889a..08b207d 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
@@ -1460,7 +1460,8 @@ static int e1000_run_loopback_test(struct e1000_a=
dapter *adapter)
 			 * enough time to complete the receives, if it's
 			 * exceeded, break and error off
 			 */
-		} while (good_cnt < 64 && jiffies < (time + 20));
+		} while (good_cnt < 64 && time_after(time + 20, jiffies));
+
 		if (good_cnt !=3D 64) {
 			ret_val =3D 13; /* ret_val is the same as mis-compare */
 			break;
--=20
1.9.3
