From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] ppp: sparse warning fixes
Date: Wed, 23 Jan 2008 15:40:19 -0800
Message-ID: <20080123154019.7cd9c471@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-ppp@vger.kernel.org, netdev@vger.kernel.org
To: Paul Mackerras <paulus@samba.org>
Return-path: <linux-ppp-owner@vger.kernel.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix a bunch of warnings in PPP and related drivers. Mostly because
sparse doesn't like it when the the function is only marked private
in the forward declaration.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/ppp_deflate.c |    4 ++--
 drivers/net/ppp_generic.c |    2 +-
 drivers/net/ppp_synctty.c |    2 +-
 drivers/net/pppoe.c       |    2 ++
 drivers/net/slhc.c        |    4 ++--
 5 files changed, 8 insertions(+), 6 deletions(-)

--- a/drivers/net/ppp_deflate.c	2008-01-23 15:35:22.000000000 -0800
+++ b/drivers/net/ppp_deflate.c	2008-01-23 15:35:40.000000000 -0800
@@ -206,7 +206,7 @@ static void z_comp_reset(void *arg)
  *	Returns the length of the compressed packet, or 0 if the
  *	packet is incompressible.
  */
-int z_compress(void *arg, unsigned char *rptr, unsigned char *obuf,
+static int z_compress(void *arg, unsigned char *rptr, unsigned char *obuf,
 	       int isize, int osize)
 {
 	struct ppp_deflate_state *state = (struct ppp_deflate_state *) arg;
@@ -435,7 +435,7 @@ static void z_decomp_reset(void *arg)
  * bug, so we return DECOMP_FATALERROR for them in order to turn off
  * compression, even though they are detected by inspecting the input.
  */
-int z_decompress(void *arg, unsigned char *ibuf, int isize,
+static int z_decompress(void *arg, unsigned char *ibuf, int isize,
 		 unsigned char *obuf, int osize)
 {
 	struct ppp_deflate_state *state = (struct ppp_deflate_state *) arg;
--- a/drivers/net/ppp_generic.c	2008-01-23 15:34:40.000000000 -0800
+++ b/drivers/net/ppp_generic.c	2008-01-23 15:34:45.000000000 -0800
@@ -1871,7 +1871,7 @@ ppp_mp_insert(struct ppp *ppp, struct sk
  * complete packet, or we get to the sequence number for a fragment
  * which hasn't arrived but might still do so.
  */
-struct sk_buff *
+static struct sk_buff *
 ppp_mp_reconstruct(struct ppp *ppp)
 {
 	u32 seq = ppp->nextseq;
--- a/drivers/net/ppp_synctty.c	2008-01-23 15:35:04.000000000 -0800
+++ b/drivers/net/ppp_synctty.c	2008-01-23 15:35:08.000000000 -0800
@@ -560,7 +560,7 @@ static void ppp_sync_process(unsigned lo
  * Procedures for encapsulation and framing.
  */
 
-struct sk_buff*
+static struct sk_buff*
 ppp_sync_txmunge(struct syncppp *ap, struct sk_buff *skb)
 {
 	int proto;
--- a/drivers/net/pppoe.c	2008-01-23 15:35:52.000000000 -0800
+++ b/drivers/net/pppoe.c	2008-01-23 15:36:16.000000000 -0800
@@ -989,6 +989,7 @@ out:
 }
 
 static void *pppoe_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(pppoe_hash_lock)
 {
 	loff_t l = *pos;
 
@@ -1022,6 +1023,7 @@ out:
 }
 
 static void pppoe_seq_stop(struct seq_file *seq, void *v)
+	__releases(pppoe_hash_lock)
 {
 	read_unlock_bh(&pppoe_hash_lock);
 }
--- a/drivers/net/slhc.c	2008-01-23 15:36:45.000000000 -0800
+++ b/drivers/net/slhc.c	2008-01-23 15:37:22.000000000 -0800
@@ -174,7 +174,7 @@ put16(unsigned char *cp, unsigned short 
 
 
 /* Encode a number */
-unsigned char *
+static unsigned char *
 encode(unsigned char *cp, unsigned short n)
 {
 	if(n >= 256 || n == 0){
@@ -199,7 +199,7 @@ pull16(unsigned char **cpp)
 }
 
 /* Decode a number */
-long
+static long
 decode(unsigned char **cpp)
 {
 	register int x;
