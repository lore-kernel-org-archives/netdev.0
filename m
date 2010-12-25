From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] Ceph: Fix use-after-free bug in ceph_messenger_destroy()
Date: Sat, 25 Dec 2010 19:11:41 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1012251908410.10759@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Sage Weil <sage@newdream.net>
To: ceph-devel@vger.kernel.org
Return-path: <ceph-devel-owner@vger.kernel.org>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

In net/ceph/messenger.c::ceph_messenger_destroy() the pointer 'msgr' is 
freed by kfree() and subsequently used in a call to dout() - use after 
free bug.
Easily fixed by simply moving the kfree() call after the dout() call.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 messenger.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
index b6ff4a1..26514a7 100644
--- a/net/ceph/messenger.c
+++ b/net/ceph/messenger.c
@@ -2131,8 +2131,8 @@ void ceph_messenger_destroy(struct ceph_messenger *msgr)
 	dout("destroy %p\n", msgr);
 	kunmap(msgr->zero_page);
 	__free_page(msgr->zero_page);
-	kfree(msgr);
 	dout("destroyed messenger %p\n", msgr);
+	kfree(msgr);
 }
 EXPORT_SYMBOL(ceph_messenger_destroy);
 

-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

