From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 3/5] sfc: Reset derived rx_bad_bytes statistic when EF10
 MC is rebooted
Date: Tue, 17 Sep 2013 01:12:27 +0100
Message-ID: <1379376747.1945.14.camel@bwh-desktop.uk.level5networks.com>
References: <1379376611.1945.11.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:21862 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352Ab3IQAMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 20:12:31 -0400
In-Reply-To: <1379376611.1945.11.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the MC reboots then the stats it reports to us will have been
reset.  We need to reset ours to get efx_update_diff_stat() working
properly.

(This is a re-run of commit 876be083b669 'sfc: Reset driver's
MAC stats after MC reboot seen'.)

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 357a6e5..80a6eea 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -708,6 +708,11 @@ static int efx_ef10_mcdi_poll_reboot(struct efx_nic *efx)
 	nic_data->must_restore_filters = true;
 	nic_data->rx_rss_context = EFX_EF10_RSS_CONTEXT_INVALID;
 
+	/* MAC statistics have been cleared on the NIC; clear the local
+	 * statistic that we update with efx_update_diff_stat().
+	 */
+	nic_data->stats[EF10_STAT_rx_bad_bytes] = 0;
+
 	return -EIO;
 }
 


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
