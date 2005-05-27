From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] baycom_epp.c: Fix compilation with gcc-4.1.0-20050522
Date: Fri, 27 May 2005 18:08:31 +0400
Message-ID: <200505271808.32032.adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Sailer <t.sailer@alumni.ethz.ch>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

drivers/net/hamradio/baycom_epp.c:432: error: jump into statement expression
	...

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

--- linux-vanilla/drivers/net/hamradio/baycom_epp.c	2005-05-27 12:58:48.000000000 +0400
+++ linux-gcc4/drivers/net/hamradio/baycom_epp.c	2005-05-27 17:54:14.000000000 +0400
@@ -380,22 +380,18 @@ static inline void do_kiss_params(struct
  */
 
 #define ENCODEITERA(j)                         \
-({                                             \
         if (!(notbitstream & (0x1f0 << j)))    \
                 goto stuff##j;                 \
-  encodeend##j:    	;                      \
-})
+  encodeend##j:    	;
 
 #define ENCODEITERB(j)                                          \
-({                                                              \
   stuff##j:                                                     \
         bitstream &= ~(0x100 << j);                             \
         bitbuf = (bitbuf & (((2 << j) << numbit) - 1)) |        \
                 ((bitbuf & ~(((2 << j) << numbit) - 1)) << 1);  \
         numbit++;                                               \
         notbitstream = ~bitstream;                              \
-        goto encodeend##j;                                      \
-})
+        goto encodeend##j;
 
 
 static void encode_hdlc(struct baycom_state *bc)
@@ -611,16 +607,13 @@ static void do_rxpacket(struct net_devic
 }
 
 #define DECODEITERA(j)                                                        \
-({                                                                            \
         if (!(notbitstream & (0x0fc << j)))              /* flag or abort */  \
                 goto flgabrt##j;                                              \
         if ((bitstream & (0x1f8 << j)) == (0xf8 << j))   /* stuffed bit */    \
                 goto stuff##j;                                                \
-  enditer##j:      ;                                                           \
-})
+  enditer##j:      ;
 
 #define DECODEITERB(j)                                                                 \
-({                                                                                     \
   flgabrt##j:                                                                          \
         if (!(notbitstream & (0x1fc << j))) {              /* abort received */        \
                 state = 0;                                                             \
@@ -638,8 +631,7 @@ static void do_rxpacket(struct net_devic
   stuff##j:                                                                            \
         numbits--;                                                                     \
         bitbuf = (bitbuf & ((~0xff) << j)) | ((bitbuf & ~((~0xff) << j)) << 1);        \
-        goto enditer##j;                                                               \
-})
+        goto enditer##j;
         
 static int receive(struct net_device *dev, int cnt)
 {
