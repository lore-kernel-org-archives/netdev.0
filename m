From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] skfddi - cleanup local and dead functions
Date: Tue, 22 Jun 2004 10:49:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040622104953.10a5930e@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Cleanup the SK Fddi driver a little more.  Mark some functions as static,
and eliminate (or comment out) some that are defined but never used.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


diff -Nru a/drivers/net/skfp/fplustm.c b/drivers/net/skfp/fplustm.c
--- a/drivers/net/skfp/fplustm.c	2004-06-22 10:47:00 -07:00
+++ b/drivers/net/skfp/fplustm.c	2004-06-22 10:47:00 -07:00
@@ -141,16 +141,17 @@
 /*
  * write long value into buffer memory over memory data register (MDR),
  */
-void	write_mdr(struct s_smc *smc, u_long val)
+static void write_mdr(struct s_smc *smc, u_long val)
 {
 	CHECK_NPP() ;
 	MDRW(val) ;
 }
 
+#if 0
 /*
  * read long value from buffer memory over memory data register (MDR),
  */
-u_long read_mdr(struct s_smc *smc, unsigned int addr)
+static u_long read_mdr(struct s_smc *smc, unsigned int addr)
 {
 	long p ;
 	CHECK_NPP() ;
@@ -164,6 +165,8 @@
 	p += (u_long)inpw(FM_A(FM_MDRL)) ;
 	return(p) ;
 }
+#endif
+
 /*
  * clear buffer memory
  */
@@ -529,7 +532,7 @@
 	outpw(FM_A(FM_RPXSF),0) ;
 }
 
-void formac_rcv_restart(struct s_smc *smc)
+static void formac_rcv_restart(struct s_smc *smc)
 {
 	/* enable receive function */
 	SETMASK(FM_A(FM_MDREG1),smc->hw.fp.rx_mode,FM_ADDRX) ;
@@ -1017,25 +1020,6 @@
 }
 
 /*-------------------------- interface functions ----------------------------*/
-/*
- * control ODL output
- */
-void sm_pm_control(struct s_smc *smc, int mode)
-{
-	SK_UNUSED(smc) ;
-
-	/*
-	 * if PCM logic has set LS_REQUEST = Transmit QUIET Line State
-	 *	/FOTOFF signal turn activ -> ODL disable
-	 */
-	switch(mode) {
-	case PM_TRANSMIT_DISABLE :
-		break ;
-	case PM_TRANSMIT_ENABLE :
-		break ;
-	}
-}
-
 /*
  * control MAC layer	(called by RMT)
  */
