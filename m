From: Baolin Wang <baolin.wang@linaro.org>
Subject: [PATCH 01/11] linux/time64.h:Introduce the 'struct itimerspec64' for 64bit
Date: Mon, 20 Apr 2015 13:57:29 +0800
Message-ID: <1429509459-17068-2-git-send-email-baolin.wang@linaro.org>
References: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org>
Cc: arnd@arndb.de, john.stultz@linaro.org, heenasirwani@gmail.com,
	pang.xunlei@linaro.org, peterz@infradead.org,
	rafael.j.wysocki@intel.com, gregkh@linuxfoundation.org,
	richardcochran@gmail.com, benh@kernel.crashing.org,
	paulus@samba.org, mpe@ellerman.id.au, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, linux390@de.ibm.com, rth@twiddle.net,
	riel@redhat.com, cl@linux.com, tj@kernel.org, fweisbec@gmail.com,
	ahh@google.com, pjt@google.com, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	baolin.wang@linaro.org, y2038@lists.linaro.org
To: tglx@linutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces the 'struct itimerspec64' for 64bit to replace itimerspec,
and also introduces the conversion methods: itimerspec64_to_itimerspec() and
itimerspec_to_itimerspec64(), that makes itimerspec to ready for 2038 year.

Signed-off-by: Baolin Wang <baolin.wang@linaro.org>
---
 include/linux/time64.h |   13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/include/linux/time64.h b/include/linux/time64.h
index a383147..3647bdd 100644
--- a/include/linux/time64.h
+++ b/include/linux/time64.h
@@ -18,6 +18,11 @@ struct timespec64 {
 };
 #endif
 
+struct itimerspec64 {
+	struct timespec64 it_interval;  /* timer period */
+	struct timespec64 it_value;     /* timer expiration */
+};
+
 /* Parameters used to convert the timespec values: */
 #define MSEC_PER_SEC	1000L
 #define USEC_PER_MSEC	1000L
@@ -187,4 +192,12 @@ static __always_inline void timespec64_add_ns(struct timespec64 *a, u64 ns)
 
 #endif
 
+#define itimerspec64_to_itimerspec(its64) \
+	({ (struct itimerspec){ .it_interval = timespec64_to_timespec((its64).it_interval), \
+				.it_value = timespec64_to_timespec((its64).it_value) }; })
+
+#define itimerspec_to_itimerspec64(its) \
+	({ (struct itimerspec64){ .it_interval = timespec_to_timespec64((its).it_interval), \
+				  .it_value = timespec_to_timespec64((its).it_value) }; })
+
 #endif /* _LINUX_TIME64_H */
-- 
1.7.9.5
