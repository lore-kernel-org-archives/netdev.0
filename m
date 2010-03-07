From: Joe Perches <joe@perches.com>
Subject: [PATCH] vsprintf.c: Use noinline_for_stack
Date: Sat, 06 Mar 2010 18:33:35 -0800
Message-ID: <1267929215.1937.18.camel@Joe-Laptop.home>
References: <cover.1267682641.git.joe@perches.com>
	 <20100304143837.af39845d.akpm@linux-foundation.org>
	 <alpine.LFD.2.00.1003041504080.3751@localhost.localdomain>
	 <1267911399.849.39.camel@Joe-Laptop.home>
	 <alpine.LFD.2.00.1003061356420.31447@localhost.localdomain>
	 <1267914654.849.81.camel@Joe-Laptop.home>
	 <alpine.LFD.2.00.1003061445490.31447@localhost.localdomain>
	 <alpine.LFD.2.00.1003061455590.31447@localhost.localdomain>
	 <1267918554.849.89.camel@Joe-Laptop.home>
	 <alpine.LFD.2.00.1003061540470.23804@localhost.localdomain>
	 <alpine.LFD.2.00.1003061547490.23804@localhost.localdomain>
	 <alpine.LFD.2.00.1003061556420.23804@localhost.localdomain>
	 <1267924214.1937.12.camel@Joe-Laptop.home>
	 <alpine.LFD.2.00.1003061755400.23804@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Nick Andrew <nick@nick-andrew.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org,
	Bjorn Helgaas <bjorn.helgaas@hp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1003061755400.23804@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2010-03-06 at 18:03 -0800, Linus Torvalds wrote:
> A few noinlines might be appropriate.

Mark static functions with noinline_for_stack

Signed-off-by: Joe Perches <joe@perches.com>
---
 lib/vsprintf.c |   67 +++++++++++++++++++++++++++++++++++---------------------
 1 files changed, 42 insertions(+), 25 deletions(-)

diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 0d461c7..e9335a8 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -266,7 +266,8 @@ int strict_strtoll(const char *cp, unsigned int base, long long *res)
 }
 EXPORT_SYMBOL(strict_strtoll);
 
-static int skip_atoi(const char **s)
+static noinline_for_stack
+int skip_atoi(const char **s)
 {
 	int i = 0;
 
@@ -286,7 +287,8 @@ static int skip_atoi(const char **s)
 /* Formats correctly any integer in [0,99999].
  * Outputs from one to five digits depending on input.
  * On i386 gcc 4.1.2 -O2: ~250 bytes of code. */
-static char *put_dec_trunc(char *buf, unsigned q)
+static noinline_for_stack
+char *put_dec_trunc(char *buf, unsigned q)
 {
 	unsigned d3, d2, d1, d0;
 	d1 = (q>>4) & 0xf;
@@ -323,7 +325,8 @@ static char *put_dec_trunc(char *buf, unsigned q)
 	return buf;
 }
 /* Same with if's removed. Always emits five digits */
-static char *put_dec_full(char *buf, unsigned q)
+static noinline_for_stack
+char *put_dec_full(char *buf, unsigned q)
 {
 	/* BTW, if q is in [0,9999], 8-bit ints will be enough, */
 	/* but anyway, gcc produces better code with full-sized ints */
@@ -365,7 +368,8 @@ static char *put_dec_full(char *buf, unsigned q)
 	return buf;
 }
 /* No inlining helps gcc to use registers better */
-static noinline char *put_dec(char *buf, unsigned long long num)
+static noinline_for_stack
+char *put_dec(char *buf, unsigned long long num)
 {
 	while (1) {
 		unsigned rem;
@@ -416,8 +420,9 @@ struct printf_spec {
 	u8	qualifier;
 };
 
-static char *number(char *buf, char *end, unsigned long long num,
-			struct printf_spec spec)
+static noinline_for_stack
+char *number(char *buf, char *end, unsigned long long num,
+	     struct printf_spec spec)
 {
 	/* we are called with base 8, 10 or 16, only, thus don't need "G..."  */
 	static const char digits[16] = "0123456789ABCDEF"; /* "GHIJKLMNOPQRSTUVWXYZ"; */
@@ -536,7 +541,8 @@ static char *number(char *buf, char *end, unsigned long long num,
 	return buf;
 }
 
-static char *string(char *buf, char *end, const char *s, struct printf_spec spec)
+static noinline_for_stack
+char *string(char *buf, char *end, const char *s, struct printf_spec spec)
 {
 	int len, i;
 
@@ -566,8 +572,9 @@ static char *string(char *buf, char *end, const char *s, struct printf_spec spec
 	return buf;
 }
 
-static char *symbol_string(char *buf, char *end, void *ptr,
-				struct printf_spec spec, char ext)
+static noinline_for_stack
+char *symbol_string(char *buf, char *end, void *ptr,
+		    struct printf_spec spec, char ext)
 {
 	unsigned long value = (unsigned long) ptr;
 #ifdef CONFIG_KALLSYMS
@@ -587,8 +594,9 @@ static char *symbol_string(char *buf, char *end, void *ptr,
 #endif
 }
 
-static char *resource_string(char *buf, char *end, struct resource *res,
-				struct printf_spec spec, const char *fmt)
+static noinline_for_stack
+char *resource_string(char *buf, char *end, struct resource *res,
+		      struct printf_spec spec, const char *fmt)
 {
 #ifndef IO_RSRC_PRINTK_SIZE
 #define IO_RSRC_PRINTK_SIZE	6
@@ -678,8 +686,9 @@ static char *resource_string(char *buf, char *end, struct resource *res,
 	return string(buf, end, sym, spec);
 }
 
-static char *mac_address_string(char *buf, char *end, u8 *addr,
-				struct printf_spec spec, const char *fmt)
+static noinline_for_stack
+char *mac_address_string(char *buf, char *end, u8 *addr,
+			 struct printf_spec spec, const char *fmt)
 {
 	char mac_addr[sizeof("xx:xx:xx:xx:xx:xx")];
 	char *p = mac_addr;
@@ -702,7 +711,8 @@ static char *mac_address_string(char *buf, char *end, u8 *addr,
 	return string(buf, end, mac_addr, spec);
 }
 
-static char *ip4_string(char *p, const u8 *addr, const char *fmt)
+static noinline_for_stack
+char *ip4_string(char *p, const u8 *addr, const char *fmt)
 {
 	int i;
 	bool leading_zeros = (fmt[0] == 'i');
@@ -751,7 +761,8 @@ static char *ip4_string(char *p, const u8 *addr, const char *fmt)
 	return p;
 }
 
-static char *ip6_compressed_string(char *p, const char *addr)
+static noinline_for_stack
+char *ip6_compressed_string(char *p, const char *addr)
 {
 	int i, j, range;
 	unsigned char zerolength[8];
@@ -831,7 +842,8 @@ static char *ip6_compressed_string(char *p, const char *addr)
 	return p;
 }
 
-static char *ip6_string(char *p, const char *addr, const char *fmt)
+static noinline_for_stack
+char *ip6_string(char *p, const char *addr, const char *fmt)
 {
 	int i;
 
@@ -846,8 +858,9 @@ static char *ip6_string(char *p, const char *addr, const char *fmt)
 	return p;
 }
 
-static char *ip6_addr_string(char *buf, char *end, const u8 *addr,
-			     struct printf_spec spec, const char *fmt)
+static noinline_for_stack
+char *ip6_addr_string(char *buf, char *end, const u8 *addr,
+		      struct printf_spec spec, const char *fmt)
 {
 	char ip6_addr[sizeof("xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:255.255.255.255")];
 
@@ -859,8 +872,9 @@ static char *ip6_addr_string(char *buf, char *end, const u8 *addr,
 	return string(buf, end, ip6_addr, spec);
 }
 
-static char *ip4_addr_string(char *buf, char *end, const u8 *addr,
-			     struct printf_spec spec, const char *fmt)
+static noinline_for_stack
+char *ip4_addr_string(char *buf, char *end, const u8 *addr,
+		      struct printf_spec spec, const char *fmt)
 {
 	char ip4_addr[sizeof("255.255.255.255")];
 
@@ -869,8 +883,9 @@ static char *ip4_addr_string(char *buf, char *end, const u8 *addr,
 	return string(buf, end, ip4_addr, spec);
 }
 
-static char *uuid_string(char *buf, char *end, const u8 *addr,
-			 struct printf_spec spec, const char *fmt)
+static noinline_for_stack
+char *uuid_string(char *buf, char *end, const u8 *addr,
+		  struct printf_spec spec, const char *fmt)
 {
 	char uuid[sizeof("xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")];
 	char *p = uuid;
@@ -958,8 +973,9 @@ static char *uuid_string(char *buf, char *end, const u8 *addr,
  * function pointers are really function descriptors, which contain a
  * pointer to the real address.
  */
-static char *pointer(const char *fmt, char *buf, char *end, void *ptr,
-			struct printf_spec spec)
+static noinline_for_stack
+char *pointer(const char *fmt, char *buf, char *end, void *ptr,
+	      struct printf_spec spec)
 {
 	if (!ptr)
 		return string(buf, end, "(null)", spec);
@@ -1028,7 +1044,8 @@ static char *pointer(const char *fmt, char *buf, char *end, void *ptr,
  * @precision: precision of a number
  * @qualifier: qualifier of a number (long, size_t, ...)
  */
-static int format_decode(const char *fmt, struct printf_spec *spec)
+static noinline_for_stack
+int format_decode(const char *fmt, struct printf_spec *spec)
 {
 	const char *start = fmt;
 
