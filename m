From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] /net/ax25/: some cleanups
Date: Sun, 12 Dec 2004 22:13:39 +0100
Message-ID: <20041212211339.GX22324@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hams@vger.kernel.org, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: ralf@linux-mips.org
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The patch below contains the following cleanups:
- make two needlessly global functions static
- net/ax25/ax25_addr.c: remove the unused global function ax25digicmp


diffstat output:
 include/net/ax25.h      |    3 ---
 net/ax25/af_ax25.c      |    2 +-
 net/ax25/ax25_addr.c    |   20 --------------------
 net/ax25/ax25_ds_subr.c |    2 +-
 4 files changed, 2 insertions(+), 25 deletions(-)


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.10-rc2-mm4-full/include/net/ax25.h.old	2004-12-12 18:56:04.000000000 +0100
+++ linux-2.6.10-rc2-mm4-full/include/net/ax25.h	2004-12-12 19:00:07.000000000 +0100
@@ -231,7 +231,6 @@
 extern void ax25_destroy_socket(ax25_cb *);
 extern ax25_cb *ax25_create_cb(void);
 extern void ax25_fillin_cb(ax25_cb *, ax25_dev *);
-extern int  ax25_create(struct socket *, int);
 extern struct sock *ax25_make_new(struct sock *, struct ax25_dev *);
 
 /* ax25_addr.c */
@@ -239,7 +238,6 @@
 extern char *ax2asc(ax25_address *);
 extern ax25_address *asc2ax(char *);
 extern int  ax25cmp(ax25_address *, ax25_address *);
-extern int  ax25digicmp(ax25_digi *, ax25_digi *);
 extern unsigned char *ax25_addr_parse(unsigned char *, int, ax25_address *, ax25_address *, ax25_digi *, int *, int *);
 extern int  ax25_addr_build(unsigned char *, ax25_address *, ax25_address *, ax25_digi *, int, int);
 extern int  ax25_addr_size(ax25_digi *);
@@ -268,7 +266,6 @@
 extern void ax25_ds_nr_error_recovery(ax25_cb *);
 extern void ax25_ds_enquiry_response(ax25_cb *);
 extern void ax25_ds_establish_data_link(ax25_cb *);
-extern void ax25_dev_dama_on(ax25_dev *);
 extern void ax25_dev_dama_off(ax25_dev *);
 extern void ax25_dama_on(ax25_cb *);
 extern void ax25_dama_off(ax25_cb *);
--- linux-2.6.10-rc2-mm4-full/net/ax25/af_ax25.c.old	2004-12-12 18:55:30.000000000 +0100
+++ linux-2.6.10-rc2-mm4-full/net/ax25/af_ax25.c	2004-12-12 18:55:41.000000000 +0100
@@ -755,7 +755,7 @@
 	return res;
 }
 
-int ax25_create(struct socket *sock, int protocol)
+static int ax25_create(struct socket *sock, int protocol)
 {
 	struct sock *sk;
 	ax25_cb *ax25;
--- linux-2.6.10-rc2-mm4-full/net/ax25/ax25_addr.c.old	2004-12-12 18:56:23.000000000 +0100
+++ linux-2.6.10-rc2-mm4-full/net/ax25/ax25_addr.c	2004-12-12 18:56:32.000000000 +0100
@@ -121,26 +121,6 @@
 }
 
 /*
- *	Compare two AX.25 digipeater paths.
- */
-int ax25digicmp(ax25_digi *digi1, ax25_digi *digi2)
-{
-	int i;
-
-	if (digi1->ndigi != digi2->ndigi)
-		return 1;
-
-	if (digi1->lastrepeat != digi2->lastrepeat)
-		return 1;
-
-	for (i = 0; i < digi1->ndigi; i++)
-		if (ax25cmp(&digi1->calls[i], &digi2->calls[i]) != 0)
-			return 1;
-
-	return 0;
-}
-
-/*
  *	Given an AX.25 address pull of to, from, digi list, command/response and the start of data
  *
  */
--- linux-2.6.10-rc2-mm4-full/net/ax25/ax25_ds_subr.c.old	2004-12-12 18:57:03.000000000 +0100
+++ linux-2.6.10-rc2-mm4-full/net/ax25/ax25_ds_subr.c	2004-12-12 18:57:45.000000000 +0100
@@ -174,7 +174,7 @@
 	return res;
 }
 
-void ax25_dev_dama_on(ax25_dev *ax25_dev)
+static void ax25_dev_dama_on(ax25_dev *ax25_dev)
 {
 	if (ax25_dev == NULL)
 		return;
