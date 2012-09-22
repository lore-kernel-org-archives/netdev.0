From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 net-next 2/4] ptp: provide the clock's adjusted frequency
Date: Sat, 22 Sep 2012 09:42:54 +0200
Message-ID: <ec433b80b10270c3b0698998df57290599408a9b.1348299094.git.richardcochran@gmail.com>
References: <cover.1348299094.git.richardcochran@gmail.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Matthew Vick <matthew.vick@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:53102 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754400Ab2IVHnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 03:43:12 -0400
Received: by wibhr14 with SMTP id hr14so2886744wib.1
        for <netdev@vger.kernel.org>; Sat, 22 Sep 2012 00:43:11 -0700 (PDT)
In-Reply-To: <cover.1348299094.git.richardcochran@gmail.com>
In-Reply-To: <cover.1348299094.git.richardcochran@gmail.com>
References: <cover.1348299094.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the timex.mode field indicates a query, then we provide the value of
the current frequency adjustment.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/ptp/ptp_clock.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
index 67e628e..6f7009a 100644
--- a/drivers/ptp/ptp_clock.c
+++ b/drivers/ptp/ptp_clock.c
@@ -148,6 +148,11 @@ static int ptp_clock_adjtime(struct posix_clock *pc, struct timex *tx)
 
 		err = ops->adjfreq(ops, scaled_ppm_to_ppb(tx->freq));
 		ptp->dialed_frequency = tx->freq;
+
+	} else if (tx->modes == 0) {
+
+		tx->freq = ptp->dialed_frequency;
+		err = 0;
 	}
 
 	return err;
-- 
1.7.2.5
