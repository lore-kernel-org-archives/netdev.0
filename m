From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 6/9] rxrpc: Add ktime_sub_ms()
Date: Thu, 22 Sep 2016 01:39:50 +0100
Message-ID: <147450479045.14691.9878291038872962775.stgit@warthog.procyon.org.uk>
References: <147450474784.14691.229861132515739820.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36874 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751635AbcIVArO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Sep 2016 20:47:14 -0400
In-Reply-To: <147450474784.14691.229861132515739820.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a ktime_sub_ms() to go with ktime_add_ms() and co. for use in AF_RXRPC
RTT determination.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/ktime.h |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/ktime.h b/include/linux/ktime.h
index 2b6a204bd8d4..aa118bad1407 100644
--- a/include/linux/ktime.h
+++ b/include/linux/ktime.h
@@ -231,6 +231,11 @@ static inline ktime_t ktime_sub_us(const ktime_t kt, const u64 usec)
 	return ktime_sub_ns(kt, usec * NSEC_PER_USEC);
 }
 
+static inline ktime_t ktime_sub_ms(const ktime_t kt, const u64 msec)
+{
+	return ktime_sub_ns(kt, msec * NSEC_PER_MSEC);
+}
+
 extern ktime_t ktime_add_safe(const ktime_t lhs, const ktime_t rhs);
 
 /**
