From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: [PATCH v2 01/16] reset: add non CONFIG_RESET_CONTROLLER routines
Date: Fri, 10 Jan 2014 15:00:02 +0800
Message-ID: <1389337217-29032-2-git-send-email-wens@csie.org>
References: <1389337217-29032-1-git-send-email-wens@csie.org>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>,
	Emilio Lopez <emilio-0Z03zUJReD5OxF6Tv1QG9Q@public.gmane.org>,
	Mike Turquette <mturquette-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: Srinivas Kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>,
	Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Philipp Zabel <p.zabel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <linux-sunxi+bncBCMILY6JWQBBBBNVX2LAKGQEJDFSV7Q-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1389337217-29032-1-git-send-email-wens-jdAy2FN1RRM@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

Some drivers are shared between platforms that may or may not
have RESET_CONTROLLER selected for them. Add dummy functions
when RESET_CONTROLLER is not selected, thereby eliminating the
need for drivers to enclose reset_control_*() calls within
#ifdef CONFIG_RESET_CONTROLLER, #endif

Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
---
 include/linux/reset.h | 39 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

diff --git a/include/linux/reset.h b/include/linux/reset.h
index 6082247..38aa616 100644
--- a/include/linux/reset.h
+++ b/include/linux/reset.h
@@ -4,6 +4,8 @@
 struct device;
 struct reset_control;
 
+#ifdef CONFIG_RESET_CONTROLLER
+
 int reset_control_reset(struct reset_control *rstc);
 int reset_control_assert(struct reset_control *rstc);
 int reset_control_deassert(struct reset_control *rstc);
@@ -14,4 +16,41 @@ struct reset_control *devm_reset_control_get(struct device *dev, const char *id)
 
 int device_reset(struct device *dev);
 
+#else /* !CONFIG_RESET_CONTROLLER */
+
+static inline int reset_control_reset(struct reset_control *rstc)
+{
+	return 0;
+}
+
+static inline int reset_control_assert(struct reset_control *rstc)
+{
+	return 0;
+}
+
+static inline int reset_control_deassert(struct reset_control *rstc)
+{
+	return 0;
+}
+
+static inline struct reset_control *reset_control_get(struct device *dev,
+		const char *id)
+{
+	return NULL;
+}
+static inline void reset_control_put(struct reset_control *rstc) {}
+
+static inline struct reset_control *devm_reset_control_get(struct device *dev,
+		const char *id)
+{
+	return NULL;
+}
+
+static inline int device_reset(struct device *dev)
+{
+	return 0;
+}
+
+#endif
+
 #endif
-- 
1.8.5.2
