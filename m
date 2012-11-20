From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH] ixgbe: fix broken PPTP handling
Date: Tue, 20 Nov 2012 16:32:34 +0000
Message-ID: <20121120163227.11935.57062.stgit@bob.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:60936 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752041Ab2KTQaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 11:30:17 -0500
Received: from bob.linux.org.uk (earthlight.etchedpixels.co.uk [81.2.110.250])
	by lxorguk.ukuu.org.uk (8.14.5/8.14.1) with ESMTP id qAKH1sNc002844
	for <netdev@vger.kernel.org>; Tue, 20 Nov 2012 17:01:59 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@linux.intel.com>

Reported to the maintain 3 weeks ago so now sending a patch rather
than waiting. ixgbe passes a random event type to the pptp code

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c |    1 +
 1 file changed, 1 insertion(+)


diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 01d99af..73291fe 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -398,6 +398,7 @@ void ixgbe_ptp_check_pps_event(struct ixgbe_adapter *adapter, u32 eicr)
 
 	switch (hw->mac.type) {
 	case ixgbe_mac_X540:
+		event.type = PTP_CLOCK_PPS;
 		ptp_clock_event(adapter->ptp_clock, &event);
 		break;
 	default:
