From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next] pch_gbe: minor: report the actual error on MTU change
Date: Tue, 16 Apr 2013 17:28:12 +0200
Message-ID: <1366126092-22683-1-git-send-email-vfalico@redhat.com>
Cc: vfalico@redhat.com, tshimizu818@gmail.com,
	richardcochran@gmail.com, andy.cress@us.kontron.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41351 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751841Ab3DPP15 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Apr 2013 11:27:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we can't _up() after changing the MTU, report the actual error instead
of -ENOMEM. It can be really misleading cause pch_gbe is usually used in
scenarios where the memory amount is really small, and thus hiding the
real cause.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 60eb890..0c1c65a 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -2263,7 +2263,7 @@ static int pch_gbe_change_mtu(struct net_device *netdev, int new_mtu)
 		if (err) {
 			adapter->rx_buffer_len = old_rx_buffer_len;
 			pch_gbe_up(adapter);
-			return -ENOMEM;
+			return err;
 		} else {
 			netdev->mtu = new_mtu;
 			adapter->hw.mac.max_frame_size = max_frame;
-- 
1.7.1
