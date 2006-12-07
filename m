From: Ralf Baechle <ralf@linux-mips.org>
Subject: [AX.25] Constify ax25 utility functions
Date: Thu, 7 Dec 2006 23:40:57 +0000
Message-ID: <20061207234057.GA15220@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:41208 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1164005AbWLGXlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 18:41:03 -0500
Received: from localhost.localdomain ([127.0.0.1]:26552 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20037860AbWLGXlC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 23:41:02 +0000
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 include/net/ax25.h   |   18 ++++++++++--------
 net/ax25/ax25_addr.c |   19 +++++++++++--------
 2 files changed, 21 insertions(+), 16 deletions(-)

Index: linux-net/include/net/ax25.h
===================================================================
--- linux-net.orig/include/net/ax25.h
+++ linux-net/include/net/ax25.h
@@ -283,14 +283,16 @@ extern struct sock *ax25_make_new(struct
 
 /* ax25_addr.c */
 extern ax25_address null_ax25_address;
-extern char *ax2asc(char *buf, ax25_address *);
-extern void asc2ax(ax25_address *addr, char *callsign);
-extern int  ax25cmp(ax25_address *, ax25_address *);
-extern int  ax25digicmp(ax25_digi *, ax25_digi *);
-extern unsigned char *ax25_addr_parse(unsigned char *, int, ax25_address *, ax25_address *, ax25_digi *, int *, int *);
-extern int  ax25_addr_build(unsigned char *, ax25_address *, ax25_address *, ax25_digi *, int, int);
-extern int  ax25_addr_size(ax25_digi *);
-extern void ax25_digi_invert(ax25_digi *, ax25_digi *);
+extern char *ax2asc(char *buf, const ax25_address *);
+extern void asc2ax(ax25_address *addr, const char *callsign);
+extern int ax25cmp(const ax25_address *, const ax25_address *);
+extern int ax25digicmp(const ax25_digi *, const ax25_digi *);
+extern const unsigned char *ax25_addr_parse(const unsigned char *, int,
+	ax25_address *, ax25_address *, ax25_digi *, int *, int *);
+extern int  ax25_addr_build(unsigned char *, const ax25_address *,
+	const ax25_address *, const ax25_digi *, int, int);
+extern int  ax25_addr_size(const ax25_digi *);
+extern void ax25_digi_invert(const ax25_digi *, ax25_digi *);
 
 /* ax25_dev.c */
 extern ax25_dev *ax25_dev_list;
Index: linux-net/net/ax25/ax25_addr.c
===================================================================
--- linux-net.orig/net/ax25/ax25_addr.c
+++ linux-net/net/ax25/ax25_addr.c
@@ -39,7 +39,7 @@ EXPORT_SYMBOL(null_ax25_address);
 /*
  *	ax25 -> ascii conversion
  */
-char *ax2asc(char *buf, ax25_address *a)
+char *ax2asc(char *buf, const ax25_address *a)
 {
 	char c, *s;
 	int n;
@@ -72,7 +72,7 @@ EXPORT_SYMBOL(ax2asc);
 /*
  *	ascii -> ax25 conversion
  */
-void asc2ax(ax25_address *addr, char *callsign)
+void asc2ax(ax25_address *addr, const char *callsign)
 {
 	char *s;
 	int n;
@@ -107,7 +107,7 @@ EXPORT_SYMBOL(asc2ax);
 /*
  *	Compare two ax.25 addresses
  */
-int ax25cmp(ax25_address *a, ax25_address *b)
+int ax25cmp(const ax25_address *a, const ax25_address *b)
 {
 	int ct = 0;
 
@@ -128,7 +128,7 @@ EXPORT_SYMBOL(ax25cmp);
 /*
  *	Compare two AX.25 digipeater paths.
  */
-int ax25digicmp(ax25_digi *digi1, ax25_digi *digi2)
+int ax25digicmp(const ax25_digi *digi1, const ax25_digi *digi2)
 {
 	int i;
 
@@ -149,7 +149,9 @@ int ax25digicmp(ax25_digi *digi1, ax25_d
  *	Given an AX.25 address pull of to, from, digi list, command/response and the start of data
  *
  */
-unsigned char *ax25_addr_parse(unsigned char *buf, int len, ax25_address *src, ax25_address *dest, ax25_digi *digi, int *flags, int *dama)
+const unsigned char *ax25_addr_parse(const unsigned char *buf, int len,
+	ax25_address *src, ax25_address *dest, ax25_digi *digi, int *flags,
+	int *dama)
 {
 	int d = 0;
 
@@ -204,7 +206,8 @@ unsigned char *ax25_addr_parse(unsigned 
 /*
  *	Assemble an AX.25 header from the bits
  */
-int ax25_addr_build(unsigned char *buf, ax25_address *src, ax25_address *dest, ax25_digi *d, int flag, int modulus)
+int ax25_addr_build(unsigned char *buf, const ax25_address *src,
+	const ax25_address *dest, const ax25_digi *d, int flag, int modulus)
 {
 	int len = 0;
 	int ct  = 0;
@@ -261,7 +264,7 @@ int ax25_addr_build(unsigned char *buf, 
 	return len;
 }
 
-int ax25_addr_size(ax25_digi *dp)
+int ax25_addr_size(const ax25_digi *dp)
 {
 	if (dp == NULL)
 		return 2 * AX25_ADDR_LEN;
@@ -272,7 +275,7 @@ int ax25_addr_size(ax25_digi *dp)
 /*
  *	Reverse Digipeat List. May not pass both parameters as same struct
  */
-void ax25_digi_invert(ax25_digi *in, ax25_digi *out)
+void ax25_digi_invert(const ax25_digi *in, ax25_digi *out)
 {
 	int ct;
 
