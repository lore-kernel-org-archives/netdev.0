From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.7] sparse annotation of csum_and_copy_to_user
Date: Wed, 16 Jun 2004 15:29:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040616152941.554fc23f@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

csum_and_copy_to_user acts like copy_to_user so it needs annotations to
get rid of several sparse warnings.

diff -Nru a/include/asm-i386/checksum.h b/include/asm-i386/checksum.h
--- a/include/asm-i386/checksum.h	2004-06-16 15:24:33 -07:00
+++ b/include/asm-i386/checksum.h	2004-06-16 15:24:33 -07:00
@@ -172,8 +172,10 @@
  *	Copy and checksum to user
  */
 #define HAVE_CSUM_COPY_USER
-static __inline__ unsigned int csum_and_copy_to_user(const char *src, char *dst,
-				    int len, int sum, int *err_ptr)
+static __inline__ unsigned int csum_and_copy_to_user(const char *src, 
+						     char __user *dst,
+						     int len, int sum, 
+						     int *err_ptr)
 {
 	if (access_ok(VERIFY_WRITE, dst, len))
 		return csum_partial_copy_generic(src, dst, len, sum, NULL, err_ptr);
diff -Nru a/include/asm-mips/checksum.h b/include/asm-mips/checksum.h
--- a/include/asm-mips/checksum.h	2004-06-16 15:24:33 -07:00
+++ b/include/asm-mips/checksum.h	2004-06-16 15:24:33 -07:00
@@ -41,7 +41,8 @@
  * Copy and checksum to user
  */
 #define HAVE_CSUM_COPY_USER
-static inline unsigned int csum_and_copy_to_user (const char *src, char *dst,
+static inline unsigned int csum_and_copy_to_user (const char *src, 
+						  char __user *dst,
 						  int len, int sum,
 						  int *err_ptr)
 {
diff -Nru a/include/asm-parisc/checksum.h b/include/asm-parisc/checksum.h
--- a/include/asm-parisc/checksum.h	2004-06-16 15:24:33 -07:00
+++ b/include/asm-parisc/checksum.h	2004-06-16 15:24:33 -07:00
@@ -191,8 +191,10 @@
  *	Copy and checksum to user
  */
 #define HAVE_CSUM_COPY_USER
-static __inline__ unsigned int csum_and_copy_to_user (const char *src, char *dst,
-				    int len, int sum, int *err_ptr)
+static __inline__ unsigned int csum_and_copy_to_user (const char *src, 
+						      char __user *dst,
+						      int len, int sum, 
+						      int *err_ptr)
 {
 	/* code stolen from include/asm-mips64 */
 	sum = csum_partial(src, len, sum);
diff -Nru a/include/asm-sh/checksum.h b/include/asm-sh/checksum.h
--- a/include/asm-sh/checksum.h	2004-06-16 15:24:33 -07:00
+++ b/include/asm-sh/checksum.h	2004-06-16 15:24:33 -07:00
@@ -201,8 +201,10 @@
  *	Copy and checksum to user
  */
 #define HAVE_CSUM_COPY_USER
-static __inline__ unsigned int csum_and_copy_to_user (const char *src, char *dst,
-				    int len, int sum, int *err_ptr)
+static __inline__ unsigned int csum_and_copy_to_user (const char *src, 
+						      char __user *dst,
+						      int len, int sum,
+						      int *err_ptr)
 {
 	if (access_ok(VERIFY_WRITE, dst, len))
 		return csum_partial_copy_generic(src, dst, len, sum, NULL, err_ptr);
diff -Nru a/include/asm-sparc/checksum.h b/include/asm-sparc/checksum.h
--- a/include/asm-sparc/checksum.h	2004-06-16 15:24:33 -07:00
+++ b/include/asm-sparc/checksum.h	2004-06-16 15:24:33 -07:00
@@ -91,7 +91,7 @@
   }
   
 static inline unsigned int 
-csum_partial_copy_to_user(const char *src, char *dst, int len, 
+csum_partial_copy_to_user(const char *src, char __user *dst, int len, 
 			  unsigned int sum, int *err)
 {
 	if (!access_ok (VERIFY_WRITE, dst, len)) {
diff -Nru a/include/asm-sparc64/checksum.h b/include/asm-sparc64/checksum.h
--- a/include/asm-sparc64/checksum.h	2004-06-16 15:24:33 -07:00
+++ b/include/asm-sparc64/checksum.h	2004-06-16 15:24:33 -07:00
@@ -66,8 +66,9 @@
  */
 #define HAVE_CSUM_COPY_USER
 extern unsigned int csum_partial_copy_user_sparc64(const char *src, char *dst, int len, unsigned int sum);
+
 static __inline__ unsigned int 
-csum_and_copy_to_user(const char *src, char *dst, int len, 
+csum_and_copy_to_user(const char *src, char __user *dst, int len, 
 		      unsigned int sum, int *err)
 {
 	__asm__ __volatile__ ("stx	%0, [%%sp + 0x7ff + 128]"
