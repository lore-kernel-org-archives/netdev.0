From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] (2/4) support large number of network devices -- name
 hash
Date: Mon, 19 Jan 2004 11:28:50 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040119112850.3b3575a7.shemminger@osdl.org>
References: <20040116154652.04dd3324.shemminger@osdl.org>
	<20040116154814.7c7f31ac.shemminger@osdl.org>
	<20040117.112244.90941296.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?ISO-8859-1?B?X19fX19fX19fX19f?=
 <yoshfuji@linux-ipv6.org>,
        davem@redhat.com
In-Reply-To: <20040117.112244.90941296.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use strnlen, great idea, thanks.

diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	Mon Jan 19 11:30:20 2004
+++ b/net/core/dev.c	Mon Jan 19 11:30:20 2004
@@ -192,8 +192,8 @@
 
 static inline struct hlist_head *dev_name_hash(const char *name)
 {
-	size_t len = min(strlen(name),(size_t)(IFNAMSIZ-1));
-	unsigned hash = full_name_hash(name, len);
+	unsigned hash = full_name_hash(name, 
+				       strnlen(name, IFNAMSIZ-1));
 	return &dev_name_head[hash & ((1<<NETDEV_HASHBITS)-1)];
 }
 
