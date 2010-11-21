From: Joe Perches <joe@perches.com>
Subject: [PATCH 32/62] ni52: Use static const
Date: Sat, 20 Nov 2010 18:38:33 -0800
Message-ID: <e4a77d76882c7d1d0be1a8132bbbbb885ebf4aad.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  13787	     89	   3576	  17452	   442c	drivers/net/ni52.o.old
  13811	     65	   3576	  17452	   442c	drivers/net/ni52.o.new

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ni52.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ni52.c b/drivers/net/ni52.c
index 33618edc..d973fc6 100644
--- a/drivers/net/ni52.c
+++ b/drivers/net/ni52.c
@@ -388,9 +388,9 @@ static long memend;	/* e.g 0xd4000 */
 struct net_device * __init ni52_probe(int unit)
 {
 	struct net_device *dev = alloc_etherdev(sizeof(struct priv));
-	static int ports[] = {0x300, 0x280, 0x360 , 0x320 , 0x340, 0};
+	static const int ports[] = {0x300, 0x280, 0x360, 0x320, 0x340, 0};
+	const int *port;
 	struct priv *p;
-	int *port;
 	int err = 0;
 
 	if (!dev)
-- 
1.7.3.2.245.g03276.dirty
