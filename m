From: Daniel McNeil <daniel@osdl.org>
Subject: [PATCH 2.5.69] wanrouter clean up MOD_*_USE_COUNT
Date: 21 May 2003 13:48:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1053550112.2444.35.camel@ibm-c.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-LOjW0tMMXQfMwmLDlQfh"
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: ncorbic@sangoma.com, dm@sangoma.com, "davem@redhat.com" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-LOjW0tMMXQfMwmLDlQfh
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Here is simple patch to remove MOD_INC_USE_COUNT and
MOD_DEC_USE_COUNT.  The wanrouter module will get a reference
when another module uses its exported symbols.

-- 
Daniel McNeil <daniel@osdl.org>

--=-LOjW0tMMXQfMwmLDlQfh
Content-Disposition: attachment; filename=patch-2.5.69-wan
Content-Type: text/x-patch; name=patch-2.5.69-wan; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

diff -rupN -X /home/daniel/dontdiff linux-2.5.69/net/wanrouter/wanmain.c linux-2.5.69.wan/net/wanrouter/wanmain.c
--- linux-2.5.69/net/wanrouter/wanmain.c	Sun May  4 16:53:35 2003
+++ linux-2.5.69.wan/net/wanrouter/wanmain.c	Wed May 21 11:37:50 2003
@@ -303,7 +303,6 @@ int register_wan_device(wan_device_t *wa
 	wandev->next = router_devlist;
 	router_devlist = wandev;
 	++devcnt;
-        MOD_INC_USE_COUNT;	/* prevent module from unloading */
 	return 0;
 }
 
@@ -348,7 +347,6 @@ int unregister_wan_device(char *name)
 
 	--devcnt;
 	wanrouter_proc_delete(wandev);
-        MOD_DEC_USE_COUNT;
 	return 0;
 }
 

--=-LOjW0tMMXQfMwmLDlQfh--
