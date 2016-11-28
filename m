From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Subject: [PATCH  v2 11/13] clocksource: export the clocks_calc_mult_shift to use by timestamp code
Date: Mon, 28 Nov 2016 17:03:35 -0600
Message-ID: <20161128230337.6731-12-grygorii.strashko@ti.com>
References: <20161128230337.6731-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>,
        Wingman Kwok <w-kwok2-l0cyMroinI0@public.gmane.org>,
        John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
        Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
        Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161128230337.6731-1-grygorii.strashko-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>

The CPSW CPTS driver is capable of doing timestamping on tx/rx packets and
requires to know mult and shift factors for timestamp conversion from raw
value to nanoseconds (ptp clock). Now these mult and shift factors are
calculated manually and provided through DT, which makes very hard to
support of a lot number of platforms, especially if CPTS refclk is not the
same for some kind of boards and depends on efuse settings (Keystone 2
platforms). Hence, export clocks_calc_mult_shift() to allow drivers like
CPSW CPTS (and other ptp drivesr) to benefit from automaitc calculation of
mult and shift factors.

Cc: John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Cc: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Signed-off-by: Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>
Signed-off-by: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
