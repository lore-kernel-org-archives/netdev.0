From: =?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>
Subject: [PATCH] dns_resolver: assure that dns_query() result is null-terminated
Date: Sat,  7 Jun 2014 19:56:51 +0200
Message-ID: <1402163811-21604-1-git-send-email-manuel.schoelling@gmx.de>
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dns_query() credulously assumes that keys are null-terminated and
returns a copy of a memory block that is off by one.
---
 net/dns_resolver/dns_query.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/dns_resolver/dns_query.c b/net/dns_resolver/dns_query.c
index e7b6d53..53be635 100644
--- a/net/dns_resolver/dns_query.c
+++ b/net/dns_resolver/dns_query.c
@@ -149,7 +149,9 @@ int dns_query(const char *type, const char *name, size_t namelen,
 	if (!*_result)
 		goto put;
 
-	memcpy(*_result, upayload->data, len + 1);
+	memcpy(*_result, upayload->data, len);
+	*_result[len+1] = '\0';
+
 	if (_expiry)
 		*_expiry = rkey->expiry;
 
-- 
1.7.10.4
