From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9 2/3] tlan: inline functions should be static + bogus
 xor
Date: Mon, 18 Oct 2004 14:06:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018140610.6edf1769@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thunderlan driver has lots of inline functions that should have been
declared static (private). Also, someone didn't know there C operators.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/tlan.h b/drivers/net/tlan.h
--- a/drivers/net/tlan.h	2004-10-18 13:59:34 -07:00
+++ b/drivers/net/tlan.h	2004-10-18 13:59:34 -07:00
@@ -443,7 +443,7 @@
 
 /* Routines to access internal registers. */
 
-inline u8 TLan_DioRead8(u16 base_addr, u16 internal_addr)
+static inline u8 TLan_DioRead8(u16 base_addr, u16 internal_addr)
 {
 	outw(internal_addr, base_addr + TLAN_DIO_ADR);
 	return (inb((base_addr + TLAN_DIO_DATA) + (internal_addr & 0x3)));
@@ -453,7 +453,7 @@
 
 
 
-inline u16 TLan_DioRead16(u16 base_addr, u16 internal_addr)
+static inline u16 TLan_DioRead16(u16 base_addr, u16 internal_addr)
 {
 	outw(internal_addr, base_addr + TLAN_DIO_ADR);
 	return (inw((base_addr + TLAN_DIO_DATA) + (internal_addr & 0x2)));
@@ -463,7 +463,7 @@
 
 
 
-inline u32 TLan_DioRead32(u16 base_addr, u16 internal_addr)
+static inline u32 TLan_DioRead32(u16 base_addr, u16 internal_addr)
 {
 	outw(internal_addr, base_addr + TLAN_DIO_ADR);
 	return (inl(base_addr + TLAN_DIO_DATA));
@@ -473,7 +473,7 @@
 
 
 
-inline void TLan_DioWrite8(u16 base_addr, u16 internal_addr, u8 data)
+static inline void TLan_DioWrite8(u16 base_addr, u16 internal_addr, u8 data)
 {
 	outw(internal_addr, base_addr + TLAN_DIO_ADR);
 	outb(data, base_addr + TLAN_DIO_DATA + (internal_addr & 0x3));
@@ -483,7 +483,7 @@
 
 
 
-inline void TLan_DioWrite16(u16 base_addr, u16 internal_addr, u16 data)
+static inline void TLan_DioWrite16(u16 base_addr, u16 internal_addr, u16 data)
 {
 	outw(internal_addr, base_addr + TLAN_DIO_ADR);
 	outw(data, base_addr + TLAN_DIO_DATA + (internal_addr & 0x2));
@@ -493,7 +493,7 @@
 
 
 
-inline void TLan_DioWrite32(u16 base_addr, u16 internal_addr, u32 data)
+static inline void TLan_DioWrite32(u16 base_addr, u16 internal_addr, u32 data)
 {
 	outw(internal_addr, base_addr + TLAN_DIO_ADR);
 	outl(data, base_addr + TLAN_DIO_DATA + (internal_addr & 0x2));
@@ -503,7 +503,7 @@
 
 
 #if 0
-inline void TLan_ClearBit(u8 bit, u16 port)
+static inline void TLan_ClearBit(u8 bit, u16 port)
 {
 	outb_p(inb_p(port) & ~bit, port);
 }
@@ -511,7 +511,7 @@
 
 
 
-inline int TLan_GetBit(u8 bit, u16 port)
+static inline int TLan_GetBit(u8 bit, u16 port)
 {
 	return ((int) (inb_p(port) & bit));
 }
@@ -519,7 +519,7 @@
 
 
 
-inline void TLan_SetBit(u8 bit, u16 port)
+static inline void TLan_SetBit(u8 bit, u16 port)
 {
 	outb_p(inb_p(port) | bit, port);
 }
@@ -532,7 +532,7 @@
 #ifdef I_LIKE_A_FAST_HASH_FUNCTION
 /* given 6 bytes, view them as 8 6-bit numbers and return the XOR of those */
 /* the code below is about seven times as fast as the original code */
-inline u32 TLan_HashFunc( u8 *a )
+static inline u32 TLan_HashFunc( u8 *a )
 {
         u8     hash;
 
@@ -548,14 +548,14 @@
 
 #else /* original code */
 
-inline	u32	xor( u32 a, u32 b )
+static inline	u32	xor( u32 a, u32 b )
 {
-	return ( ( a && ! b ) || ( ! a && b ) );
+	return a ^ b;
 }
 #define XOR8( a, b, c, d, e, f, g, h )	xor( a, xor( b, xor( c, xor( d, xor( e, xor( f, xor( g, h ) ) ) ) ) ) )
 #define DA( a, bit )					( ( (u8) a[bit/8] ) & ( (u8) ( 1 << bit%8 ) ) )
 
-inline u32 TLan_HashFunc( u8 *a )
+static inline u32 TLan_HashFunc( u8 *a )
 {
 	u32	hash;
 
