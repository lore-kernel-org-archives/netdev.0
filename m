From: akpm@osdl.org
Subject: [patch 1/5] small sha256 cleanup
Date: Mon, 25 Oct 2004 12:38:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410251940.i9PJeM910827@mail.osdl.org>
Cc: jmorris@redhat.com, netdev@oss.sgi.com, akpm@osdl.org,
        vda@port.imtp.ilyichevsk.odessa.ua
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>

Looks like open-coded be_to_cpu.  GCC produces rather poor code for this. 
be_to_cpu produces asm()s which are ~4 times shorter.

Compile-tested only.

I am not sure whether input can be 32bit-unaligned.
If it indeed can be, replace:

((u32*)(input))[I]  ->  get_unaligned( ((u32*)(input))+I )

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/crypto/sha256.c |   10 +---------
 1 files changed, 1 insertion(+), 9 deletions(-)

diff -puN crypto/sha256.c~small-sha256-cleanup crypto/sha256.c
--- 25/crypto/sha256.c~small-sha256-cleanup	2004-10-01 21:20:39.113354352 -0700
+++ 25-akpm/crypto/sha256.c	2004-10-01 21:20:39.117353744 -0700
@@ -63,15 +63,7 @@ static inline u32 RORu32(u32 x, u32 y)
 
 static inline void LOAD_OP(int I, u32 *W, const u8 *input)
 {
-	u32 t1 = input[(4 * I)] & 0xff;
-
-	t1 <<= 8;
-	t1 |= input[(4 * I) + 1] & 0xff;
-	t1 <<= 8;
-	t1 |= input[(4 * I) + 2] & 0xff;
-	t1 <<= 8;
-	t1 |= input[(4 * I) + 3] & 0xff;
-	W[I] = t1;
+	W[I] = __be32_to_cpu( ((u32*)(input))[I] );
 }
 
 static inline void BLEND_OP(int I, u32 *W)
_
