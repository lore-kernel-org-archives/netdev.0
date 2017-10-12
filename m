From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 08/10] staging/irda/net: Use common error handling code in
 irias_new_object()
Date: Thu, 12 Oct 2017 12:48:03 +0200
Message-ID: <c7db5b0d-2bd4-367c-bd29-4c33155bb22d@users.sourceforge.net>
References: <8152401b-d68d-c4fe-2619-82a09e0c52ec@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
        Al Viro <viro@zeniv.linux.org.uk>,
        Corentin Labbe <clabbe.montjoie@gmail.com>,
        David Howells <dhowells@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Georgiana Chelu <georgiana.chelu93@gmail.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Johannes Berg <johannes.berg@intel.com>,
        Julia Lawall <julia.lawall@lip6.fr>,
        Samuel Ortiz <samuel@sortiz.org>,
        Srishti Sharma <srishtishar@gmail.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Yuan Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8152401b-d68d-c4fe-2619-82a09e0c52ec@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 12 Oct 2017 08:52:53 +0200

Add a jump target so that a bit of exception handling can be better
reused at the end of this function.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/irda/net/irias_object.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/irda/net/irias_object.c b/drivers/staging/irda/net/irias_object.c
index 4c2c65e28836..0c89800d597d 100644
--- a/drivers/staging/irda/net/irias_object.c
+++ b/drivers/staging/irda/net/irias_object.c
@@ -54,10 +54,9 @@ struct ias_object *irias_new_object( char *name, int id)
 
 	obj->magic = IAS_OBJECT_MAGIC;
 	obj->name = kstrndup(name, IAS_MAX_CLASSNAME, GFP_ATOMIC);
-	if (!obj->name) {
-		kfree(obj);
-		return NULL;
-	}
+	if (!obj->name)
+		goto free_object;
+
 	obj->id = id;
 
 	/* Locking notes : the attrib spinlock has lower precendence
@@ -68,11 +67,14 @@ struct ias_object *irias_new_object( char *name, int id)
 		net_warn_ratelimited("%s(), Unable to allocate attribs!\n",
 				     __func__);
 		kfree(obj->name);
-		kfree(obj);
-		return NULL;
+		goto free_object;
 	}
 
 	return obj;
+
+free_object:
+	kfree(obj);
+	return NULL;
 }
 EXPORT_SYMBOL(irias_new_object);
 
-- 
2.14.2
