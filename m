From: "Steve French" <smfrench@gmail.com>
Subject: Fwd: [PATCH] Fix CIFS compilation with CONFIG_KEYS unset
Date: Sun, 12 Oct 2008 08:40:39 -0500
Message-ID: <524f69650810120640v41778375wf0a7662e773da26f@mail.gmail.com>
References: <200810121315.37203.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: rjw@sisk.pl, "David Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org,
	"samba-technical@lists.samba.org" <samba-technical@lists.samba.org>,
	"linux-cifs-client@lists.samba.org"
	<
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759996AbYJLNkz@vger.kernel.org>
In-Reply-To: <200810121315.37203.rjw@sisk.pl>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rafael and Guo-Fu,
The following change to address the compile error that you noted is
slightly different than what you suggested but should fix what you
found.

diff --git a/fs/cifs/sess.c b/fs/cifs/sess.c
index 2851d5d..d8fce19 100644
--- a/fs/cifs/sess.c
+++ b/fs/cifs/sess.c
@@ -624,10 +624,12 @@ CIFS_SessSetup(unsigned int xid, struct
cifsSesInfo *ses, int first_time,
 					 ses, nls_cp);

 ssetup_exit:
+#ifdef CONFIG_CIFS_UPCALL
 	if (spnego_key) {
 		key_revoke(spnego_key);
 		key_put(spnego_key);
 	}
+#endif
 	kfree(str_area);
 	if (resp_buf_type == CIFS_SMALL_BUFFER) {
 		cFYI(1, ("ssetup freeing small buf %p", iov[0].iov_base));


---------- Forwarded message ----------
From: Rafael J. Wysocki <rjw@sisk.pl>
Date: Sun, Oct 12, 2008 at 6:15 AM
Subject: [PATCH] Fix CIFS compilation with CONFIG_KEYS unset
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML
<linux-kernel@vger.kernel.org>, Herbert Xu
<herbert@gondor.apana.org.au>, Steve French <smfrench@gmail.com>


From: Rafael J. Wysocki <rjw@sisk.pl>

Fix CIFS compilation with CONFIG_KEYS unset

If CONFIG_KEYS is unset, fs/cifs/sess.c doesn't build due to key_revoke()
being undefined.  Fix that.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 include/linux/key.h |    1 +
 1 file changed, 1 insertion(+)

Index: linux-2.6/include/linux/key.h
===================================================================
--- linux-2.6.orig/include/linux/key.h
+++ linux-2.6/include/linux/key.h
@@ -300,6 +300,7 @@ extern void key_init(void);
 #define key_serial(k)                  0
 #define key_get(k)                     ({ NULL; })
 #define key_put(k)                     do { } while(0)
+#define key_revoke(k)                  do { } while(0)
 #define key_ref_put(k)                 do { } while(0)
 #define make_key_ref(k, p)                     ({ NULL; })
 #define key_ref_to_ptr(k)              ({ NULL; })



-- 
Thanks,

Steve
