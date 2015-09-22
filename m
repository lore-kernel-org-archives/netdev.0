From: Guillaume Gomez <guillaume1.gomez@gmail.com>
Subject: [PATCH] kernel: Remove unneeded return from void functions
Date: Wed, 23 Sep 2015 00:21:57 +0200
Message-ID: <CAAOQCfQE-eAGYPeKfVnOg8txOVjoTmaK1BANXoarB+cyaFw0gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: tglx@linutronix.de, davem@davemloft.net, tj@kernel.org,
	cl@linux-foundation.org, john.stultz@linaro.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Guillaume Gomez <guillaume1.gomez@gmail.com>
---
 include/linux/clockchips.h      | 2 +-
 include/linux/crypto.h          | 2 +-
 include/linux/device.h          | 2 +-
 include/linux/netdevice.h       | 2 +-
 include/linux/percpu-refcount.h | 2 +-
 include/linux/timekeeping.h     | 2 +-
 kernel/time/clocksource.c       | 4 ++--
 7 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/clockchips.h b/include/linux/clockchips.h
index bdcf358..4dd0437 100644
--- a/include/linux/clockchips.h
+++ b/include/linux/clockchips.h
@@ -192,7 +192,7 @@ extern int clockevents_update_freq(struct
clock_event_device *ce, u32 freq);
 static inline void
 clockevents_calc_mult_shift(struct clock_event_device *ce, u32 freq,
u32 minsec)
 {
-    return clocks_calc_mult_shift(&ce->mult, &ce->shift,
NSEC_PER_SEC, freq, minsec);
+    clocks_calc_mult_shift(&ce->mult, &ce->shift, NSEC_PER_SEC, freq, minsec);
 }

 extern void clockevents_suspend(void);
diff --git a/include/linux/crypto.h b/include/linux/crypto.h
index e71cb70..7d19b4f 100644
--- a/include/linux/crypto.h
+++ b/include/linux/crypto.h
@@ -620,7 +620,7 @@ void crypto_destroy_tfm(void *mem, struct crypto_tfm *tfm);

 static inline void crypto_free_tfm(struct crypto_tfm *tfm)
 {
-    return crypto_destroy_tfm(tfm, tfm);
+    crypto_destroy_tfm(tfm, tfm);
 }

 int alg_test(const char *driver, const char *alg, u32 type, u32 mask);
diff --git a/include/linux/device.h b/include/linux/device.h
index 5d7bc63..d0823c2 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -477,7 +477,7 @@ static inline int __must_check
class_create_file(struct class *class,
 static inline void class_remove_file(struct class *class,
                      const struct class_attribute *attr)
 {
-    return class_remove_file_ns(class, attr, NULL);
+    class_remove_file_ns(class, attr, NULL);
 }

 /* Simple class attribute that is just a static string */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 88a0069..4a444a1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -457,7 +457,7 @@ void napi_complete_done(struct napi_struct *n, int
work_done);
  */
 static inline void napi_complete(struct napi_struct *n)
 {
-    return napi_complete_done(n, 0);
+    napi_complete_done(n, 0);
 }

 /**
diff --git a/include/linux/percpu-refcount.h b/include/linux/percpu-refcount.h
index 12c9b48..84f542d 100644
--- a/include/linux/percpu-refcount.h
+++ b/include/linux/percpu-refcount.h
@@ -116,7 +116,7 @@ void percpu_ref_reinit(struct percpu_ref *ref);
  */
 static inline void percpu_ref_kill(struct percpu_ref *ref)
 {
-    return percpu_ref_kill_and_confirm(ref, NULL);
+    percpu_ref_kill_and_confirm(ref, NULL);
 }

 /*
diff --git a/include/linux/timekeeping.h b/include/linux/timekeeping.h
index ba0ae09..8f776cc 100644
--- a/include/linux/timekeeping.h
+++ b/include/linux/timekeeping.h
@@ -83,7 +83,7 @@ static inline struct timespec get_monotonic_coarse(void)

 static inline void getboottime(struct timespec *ts)
 {
-    return getboottime64(ts);
+    getboottime64(ts);
 }
 #else
 /**
diff --git a/kernel/time/clocksource.c b/kernel/time/clocksource.c
index 841b72f..5e83c38 100644
--- a/kernel/time/clocksource.c
+++ b/kernel/time/clocksource.c
@@ -595,12 +595,12 @@ static void __clocksource_select(bool skipcur)
  */
 static void clocksource_select(void)
 {
-    return __clocksource_select(false);
+    __clocksource_select(false);
 }

 static void clocksource_select_fallback(void)
 {
-    return __clocksource_select(true);
+    __clocksource_select(true);
 }

 #else /* !CONFIG_ARCH_USES_GETTIMEOFFSET */
-- 
1.9.1
