From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v3 2/6] ktime: add ms_to_ktime() and ktime_add_ms() helpers
Date: Tue, 25 Jun 2013 18:17:26 +0200
Message-ID: <1372177050-17829-3-git-send-email-dborkman@redhat.com>
References: <1372177050-17829-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14073 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751591Ab3FYQRi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 12:17:38 -0400
In-Reply-To: <1372177050-17829-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add two ktime helper functions that i) convert a given msec value to
a ktime structure and ii) that adds a msec value to a ktime structure.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/linux/ktime.h | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/include/linux/ktime.h b/include/linux/ktime.h
index bbca128..b4fa5e4 100644
--- a/include/linux/ktime.h
+++ b/include/linux/ktime.h
@@ -323,6 +323,11 @@ static inline ktime_t ktime_add_us(const ktime_t kt, const u64 usec)
 	return ktime_add_ns(kt, usec * 1000);
 }
 
+static inline ktime_t ktime_add_ms(const ktime_t kt, const u64 msec)
+{
+	return ktime_add_ns(kt, msec * NSEC_PER_MSEC);
+}
+
 static inline ktime_t ktime_sub_us(const ktime_t kt, const u64 usec)
 {
 	return ktime_sub_ns(kt, usec * 1000);
@@ -366,7 +371,15 @@ extern void ktime_get_ts(struct timespec *ts);
 static inline ktime_t ns_to_ktime(u64 ns)
 {
 	static const ktime_t ktime_zero = { .tv64 = 0 };
+
 	return ktime_add_ns(ktime_zero, ns);
 }
 
+static inline ktime_t ms_to_ktime(u64 ms)
+{
+	static const ktime_t ktime_zero = { .tv64 = 0 };
+
+	return ktime_add_ms(ktime_zero, ms);
+}
+
 #endif
-- 
1.7.11.7
