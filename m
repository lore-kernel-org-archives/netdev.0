From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] [sparse] dgrs -- cleanup warnings
Date: Tue, 22 Jun 2004 14:27:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040622142722.343300b3@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

DGRS driver sparse fixes.  Add annotation to ioctl structure and get rid of '#if XXX'

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/dgrs.h b/drivers/net/dgrs.h
--- a/drivers/net/dgrs.h	2004-06-22 14:25:43 -07:00
+++ b/drivers/net/dgrs.h	2004-06-22 14:25:43 -07:00
@@ -26,7 +26,7 @@
 typedef struct dgrs_ioctl {
 	unsigned short cmd;	/* Command to run */
 	unsigned short len;	/* Length of the data buffer */
-	unsigned char  *data;	/* Pointer to the data buffer */
+	unsigned char __user *data;/* Pointer to the data buffer */
 	unsigned short	port;	/* port number for command, if needed */
 	unsigned short	filter;	/* filter number for command, if needed */
 } DGRS_IOCTL;
diff -Nru a/drivers/net/dgrs_asstruct.h b/drivers/net/dgrs_asstruct.h
--- a/drivers/net/dgrs_asstruct.h	2004-06-22 14:25:43 -07:00
+++ b/drivers/net/dgrs_asstruct.h	2004-06-22 14:25:43 -07:00
@@ -4,7 +4,7 @@
  *	$Id: asstruct.h,v 1.1.1.1 1994/10/23 05:08:32 rick Exp $
  */
 
-#if ASSEMBLER
+#ifdef ASSEMBLER
 
 #	define MO(t,a)		(a)
 #	define VMO(t,a)		(a)
