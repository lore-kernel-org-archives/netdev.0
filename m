From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 4/6] random32: move rnd_state to linux/random.h
Date: Mon, 11 Nov 2013 12:20:35 +0100
Message-ID: <33456dc3a929ef80a7fdfae0b26fe7a69b7dc63e.1384160397.git.dborkman@redhat.com>
References: <cover.1384160397.git.dborkman@redhat.com>
Cc: shemminger@networkplumber.org, fweimer@redhat.com,
	netdev@vger.kernel.org, Joe Eykholt <jeykholt@cisco.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30953 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753293Ab3KKLU7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Nov 2013 06:20:59 -0500
In-Reply-To: <cover.1384160397.git.dborkman@redhat.com>
In-Reply-To: <cover.1384160397.git.dborkman@redhat.com>
References: <cover.1384160397.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct rnd_state got mistakenly pulled into uapi header. It is not
used anywhere and does also not belong there!

Commit 5960164fde ("lib/random32: export pseudo-random number
generator for modules"), the last commit on rnd_state before it
got moved to uapi, says:

  This patch moves the definition of struct rnd_state and the inline
  __seed() function to linux/random.h.  It renames the static __random32()
  function to prandom32() and exports it for use in modules.

Hence, the structure was moved from lib/random32.c to linux/random.h
so that it can be used within modules (FCoE-related code in this
case), but not from user space. However, it seems to have been
mistakenly moved to uapi header through the uapi script. Since no-one
should make use of it from the linux headers, move the structure back
to the kernel for internal use, so that it can be modified on demand.

Joint work with Hannes Frederic Sowa.

Cc: Joe Eykholt <jeykholt@cisco.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/random.h      | 4 ++++
 include/uapi/linux/random.h | 7 -------
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/include/linux/random.h b/include/linux/random.h
index 5117ae3..8ef0b70 100644
--- a/include/linux/random.h
+++ b/include/linux/random.h
@@ -31,6 +31,10 @@ void prandom_bytes(void *buf, int nbytes);
 void prandom_seed(u32 seed);
 void prandom_reseed_late(void);
 
+struct rnd_state {
+	__u32 s1, s2, s3;
+};
+
 u32 prandom_u32_state(struct rnd_state *);
 void prandom_bytes_state(struct rnd_state *state, void *buf, int nbytes);
 
diff --git a/include/uapi/linux/random.h b/include/uapi/linux/random.h
index 7471b5b..fff3528 100644
--- a/include/uapi/linux/random.h
+++ b/include/uapi/linux/random.h
@@ -40,11 +40,4 @@ struct rand_pool_info {
 	__u32	buf[0];
 };
 
-struct rnd_state {
-	__u32 s1, s2, s3;
-};
-
-/* Exported functions */
-
-
 #endif /* _UAPI_LINUX_RANDOM_H */
-- 
1.8.3.1
