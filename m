From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v5 11/13] clocksource: export the clocks_calc_mult_shift to use by timestamp code
Date: Tue, 6 Dec 2016 18:00:43 -0600
Message-ID: <20161207000045.28333-12-grygorii.strashko@ti.com>
References: <20161207000045.28333-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, <devicetree@vger.kernel.org>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        John Stultz <john.stultz@linaro.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx210.ext.ti.com ([198.47.19.17]:22012 "EHLO
        fllnx210.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751617AbcLGABB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 19:01:01 -0500
In-Reply-To: <20161207000045.28333-1-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Murali Karicheri <m-karicheri2@ti.com>

The CPSW CPTS driver is capable of doing timestamping on tx/rx packets and
requires to know mult and shift factors for timestamp conversion from raw
value to nanoseconds (ptp clock). Now these mult and shift factors are
calculated manually and provided through DT, which makes very hard to
support of a lot number of platforms, especially if CPTS refclk is not the
same for some kind of boards and depends on efuse settings (Keystone 2
platforms). Hence, export clocks_calc_mult_shift() to allow drivers like
CPSW CPTS (and other ptp drivesr) to benefit from automaitc calculation of
mult and shift factors.

Cc: John Stultz <john.stultz@linaro.org>
Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Acked-by: Thomas Gleixner <tglx@linutronix.de>
---
 kernel/time/clocksource.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/time/clocksource.c b/kernel/time/clocksource.c
index 7e4fad7..150242c 100644
--- a/kernel/time/clocksource.c
+++ b/kernel/time/clocksource.c
@@ -89,6 +89,7 @@ clocks_calc_mult_shift(u32 *mult, u32 *shift, u32 from, u32 to, u32 maxsec)
 	*mult = tmp;
 	*shift = sft;
 }
+EXPORT_SYMBOL_GPL(clocks_calc_mult_shift);
 
 /*[Clocksource internal variables]---------
  * curr_clocksource:
-- 
2.10.1
