From: =?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>
Subject: [PATCH v2] dns_resolver: assure that dns_query() result is null-terminated
Date: Sat,  7 Jun 2014 21:01:21 +0200
Message-ID: <1402167681-24676-1-git-send-email-manuel.schoelling@gmx.de>
References: <CAHQdGtTtwS_DAXx-nhVjjO3D1wksuV+5br10gX0DheHzWDD+sw@mail.gmail.com>
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHQdGtTtwS_DAXx-nhVjjO3D1wksuV+5br10gX0DheHzWDD+sw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dns_query() credulously assumes that keys are null-terminated and
returns a copy of a memory block that is off by one.
---
 net/dns_resolver/dns_query.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/dns_resolver/dns_query.c b/net/dns_resolver/dns_query.c
index e7b6d53..84871a2 100644
--- a/net/dns_resolver/dns_query.c
+++ b/net/dns_resolver/dns_query.c
@@ -145,11 +145,11 @@ int dns_query(const char *type, const char *name, size_t namelen,
 	len = upayload->datalen;
 
 	ret = -ENOMEM;
-	*_result = kmalloc(len + 1, GFP_KERNEL);
+	*_result = kzalloc(len + 1, GFP_KERNEL);
 	if (!*_result)
 		goto put;
 
-	memcpy(*_result, upayload->data, len + 1);
+	memcpy(*_result, upayload->data, len);
 	if (_expiry)
 		*_expiry = rkey->expiry;
 
-- 
1.7.10.4
