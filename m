From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 1/3] ptp: remember the adjusted frequency
Date: Fri, 21 Sep 2012 19:00:25 +0200
Message-ID: <4eb4f128a263639f2bfec631a379287b136eabcc.1348245523.git.richardcochran@gmail.com>
References: <cover.1348245523.git.richardcochran@gmail.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Matthew Vick <matthew.vick@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:53214 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754468Ab2IURAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 13:00:41 -0400
Received: by mail-we0-f174.google.com with SMTP id x8so2072211wey.19
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2012 10:00:41 -0700 (PDT)
In-Reply-To: <cover.1348245523.git.richardcochran@gmail.com>
In-Reply-To: <cover.1348245523.git.richardcochran@gmail.com>
References: <cover.1348245523.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a field to the representation of a PTP hardware clock in
order to remember the frequency adjustment value dialed by the user.

Adding this field will let us answer queries in the manner of adjtimex
in a follow on patch.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/ptp/ptp_clock.c   |    1 +
 drivers/ptp/ptp_private.h |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
index 1e528b5..fbd7104 100644
--- a/drivers/ptp/ptp_clock.c
+++ b/drivers/ptp/ptp_clock.c
@@ -147,6 +147,7 @@ static int ptp_clock_adjtime(struct posix_clock *pc, struct timex *tx)
 	} else if (tx->modes & ADJ_FREQUENCY) {
 
 		err = ops->adjfreq(ops, scaled_ppm_to_ppb(tx->freq));
+		ptp->dialed_frequency = tx->freq;
 	}
 
 	return err;
diff --git a/drivers/ptp/ptp_private.h b/drivers/ptp/ptp_private.h
index 4d5b508..69d3207 100644
--- a/drivers/ptp/ptp_private.h
+++ b/drivers/ptp/ptp_private.h
@@ -45,6 +45,7 @@ struct ptp_clock {
 	dev_t devid;
 	int index; /* index into clocks.map */
 	struct pps_device *pps_source;
+	long dialed_frequency; /* remembers the frequency adjustment */
 	struct timestamp_event_queue tsevq; /* simple fifo for time stamps */
 	struct mutex tsevq_mux; /* one process at a time reading the fifo */
 	wait_queue_head_t tsev_wq;
-- 
1.7.2.5
