From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Subject: [PATCH] net: dns_resolver: convert time_t to time64_t
Date: Wed, 18 Nov 2015 08:36:44 +0200
Message-ID: <20151118063643.GA16239@waves>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>,
	David Howells <dhowells@redhat.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changes the definition of the pointer _expiry from time_t to
time64_t. This is to handle the Y2038 problem where time_t
will overflow in the year 2038. The change is safe because
the kernel subsystems that call dns_query pass NULL.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
---
Changelog:
v1: The changes were originally made by Arnd Bergmann in
relation to time_t. I've broken down a patch sent to me
into two independent patches.

 include/linux/dns_resolver.h | 2 +-
 net/dns_resolver/dns_query.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/dns_resolver.h b/include/linux/dns_resolver.h
index cc92268..6ac3cad 100644
--- a/include/linux/dns_resolver.h
+++ b/include/linux/dns_resolver.h
@@ -27,7 +27,7 @@
 #ifdef __KERNEL__
 
 extern int dns_query(const char *type, const char *name, size_t namelen,
-		     const char *options, char **_result, time_t *_expiry);
+		     const char *options, char **_result, time64_t *_expiry);
 
 #endif /* KERNEL */
 
diff --git a/net/dns_resolver/dns_query.c b/net/dns_resolver/dns_query.c
index 4677b6f..ecc28cf 100644
--- a/net/dns_resolver/dns_query.c
+++ b/net/dns_resolver/dns_query.c
@@ -67,7 +67,7 @@
  * Returns the size of the result on success, -ve error code otherwise.
  */
 int dns_query(const char *type, const char *name, size_t namelen,
-	      const char *options, char **_result, time_t *_expiry)
+	      const char *options, char **_result, time64_t *_expiry)
 {
 	struct key *rkey;
 	const struct user_key_payload *upayload;
-- 
2.4.3


-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
