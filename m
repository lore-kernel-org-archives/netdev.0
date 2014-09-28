From: Luwei Zhou <b45643@freescale.com>
Subject: [PATCH v2 3/4] ptp: Add PTP_PF_PPS enumeration to ptp_pin_function.
Date: Sun, 28 Sep 2014 12:20:10 +0800
Message-ID: <1411878011-21767-4-git-send-email-b45643@freescale.com>
References: <1411878011-21767-1-git-send-email-b45643@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <shawn.guo@linaro.org>,
	<bhutchings@solarflare.com>, <R49496@freescale.com>,
	<b38611@freescale.com>, <b20596@freescale.com>,
	<stephen@networkplumber.org>
To: <davem@davemloft.net>, <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bn0109.outbound.protection.outlook.com ([157.56.110.109]:27728
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750803AbaI1Fj5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Sep 2014 01:39:57 -0400
In-Reply-To: <1411878011-21767-1-git-send-email-b45643@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PTP_PIN_SET/GETFUNC interface can be used to specify the channel index
when multi-channel timer is used to ouput PPS. Need to add PPS corresponding
pin function enumeration in the ptp.

Signed-off-by: Luwei Zhou <b45643@freescale.com>
---
 drivers/ptp/ptp_chardev.c        | 8 ++++++++
 include/linux/ptp_clock_kernel.h | 2 ++
 include/uapi/linux/ptp_clock.h   | 1 +
 3 files changed, 11 insertions(+)

diff --git a/drivers/ptp/ptp_chardev.c b/drivers/ptp/ptp_chardev.c
index f8a7609..a746e5a 100644
--- a/drivers/ptp/ptp_chardev.c
+++ b/drivers/ptp/ptp_chardev.c
@@ -48,6 +48,10 @@ static int ptp_disable_pinfunc(struct ptp_clock_info *ops,
 		break;
 	case PTP_PF_PHYSYNC:
 		break;
+	case PTP_PF_PPS:
+		rq.type = PTP_CLK_REQ_PPS;
+		err = ops->enable(ops, &rq, 0);
+		break;
 	default:
 		return -EINVAL;
 	}
@@ -85,6 +89,10 @@ int ptp_set_pinfunc(struct ptp_clock *ptp, unsigned int pin,
 		if (chan >= info->n_per_out)
 			return -EINVAL;
 		break;
+	case PTP_PF_PPS:
+		if (chan >= info->n_pps_chan)
+			return -EINVAL;
+		break;
 	case PTP_PF_PHYSYNC:
 		if (chan != 0)
 			return -EINVAL;
diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
index 0d8ff3f..2a5ad1c 100644
--- a/include/linux/ptp_clock_kernel.h
+++ b/include/linux/ptp_clock_kernel.h
@@ -49,6 +49,7 @@ struct ptp_clock_request {
  * @n_alarm:   The number of programmable alarms.
  * @n_ext_ts:  The number of external time stamp channels.
  * @n_per_out: The number of programmable periodic signals.
+ * @n_pps_chan: The number of programmable channles for pps output.
  * @n_pins:    The number of programmable pins.
  * @pps:       Indicates whether the clock supports a PPS callback.
  * @pin_config: Array of length 'n_pins'. If the number of
@@ -99,6 +100,7 @@ struct ptp_clock_info {
 	int n_alarm;
 	int n_ext_ts;
 	int n_per_out;
+	int n_pps_chan;
 	int n_pins;
 	int pps;
 	struct ptp_pin_desc *pin_config;
diff --git a/include/uapi/linux/ptp_clock.h b/include/uapi/linux/ptp_clock.h
index f0b7bfe..57ba7e7 100644
--- a/include/uapi/linux/ptp_clock.h
+++ b/include/uapi/linux/ptp_clock.h
@@ -86,6 +86,7 @@ enum ptp_pin_function {
 	PTP_PF_EXTTS,
 	PTP_PF_PEROUT,
 	PTP_PF_PHYSYNC,
+	PTP_PF_PPS,
 };
 
 struct ptp_pin_desc {
-- 
1.9.1
