From: Samuel Ortiz <samuel.ortiz-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 3/5] IrDA: nsc-ircc: support for yet another Thinkpad IrDA chipset
Date: Tue, 14 Feb 2006 00:15:21 +0200
Message-ID: <20060213221521.GD31091@irie>
Reply-To: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>,
	IrDA users <irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Return-path: <irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: "ext David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Disposition: inline
Sender: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Id: netdev.vger.kernel.org

This patch simply adds support for a variation of the nsc-ircc PC8739x
chipset, found in some IBM Thinkpad laptops.

Signed-off-by: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org> 
Signed-off-by: Samuel Ortiz <samuel.ortiz-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org> 

diff --git a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
index e8ff07f..39cf5f0 100644
--- a/drivers/net/irda/nsc-ircc.c
+++ b/drivers/net/irda/nsc-ircc.c
@@ -90,9 +90,9 @@ static int qos_mtt_bits = 0x07;  /* 1 ms
 static int dongle_id;
 
 /* Use BIOS settions by default, but user may supply module parameters */
-static unsigned int io[]  = { ~0, ~0, ~0, ~0 };
-static unsigned int irq[] = {  0,  0,  0,  0 };
-static unsigned int dma[] = {  0,  0,  0,  0 };
+static unsigned int io[]  = { ~0, ~0, ~0, ~0, ~0 };
+static unsigned int irq[] = {  0,  0,  0,  0,  0 };
+static unsigned int dma[] = {  0,  0,  0,  0,  0 };
 
 static int nsc_ircc_probe_108(nsc_chip_t *chip, chipio_t *info);
 static int nsc_ircc_probe_338(nsc_chip_t *chip, chipio_t *info);
@@ -115,10 +115,12 @@ static nsc_chip_t chips[] = {
 	/* Contributed by Jan Frey - IBM A30/A31 */
 	{ "PC8739x", { 0x2e, 0x4e, 0x0 }, 0x20, 0xea, 0xff, 
 	  nsc_ircc_probe_39x, nsc_ircc_init_39x },
+	{ "IBM", { 0x2e, 0x4e, 0x0 }, 0x20, 0xf4, 0xff,
+ 	  nsc_ircc_probe_39x, nsc_ircc_init_39x },
 	{ NULL }
 };
 
-static struct nsc_ircc_cb *dev_self[] = { NULL, NULL, NULL, NULL };
+static struct nsc_ircc_cb *dev_self[] = { NULL, NULL, NULL, NULL, NULL };
 
 static char *dongle_types[] = {
 	"Differential serial interface",


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
