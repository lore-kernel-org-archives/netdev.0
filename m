From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2/5] r8169: C 101
Date: Tue, 7 Dec 2004 01:15:35 +0100
Message-ID: <20041207001535.GA18672@electric-eye.fr.zoreil.com>
References: <20041119162920.GA26836@lilah.hetzel.org> <20041119201203.GA13522@electric-eye.fr.zoreil.com> <20041120003754.GA32133@lilah.hetzel.org> <20041120002946.GA18059@electric-eye.fr.zoreil.com> <20041122181307.GA3625@lilah.hetzel.org> <20041205235519.GA21885@lilah.hetzel.org> <20041205233756.GB29236@electric-eye.fr.zoreil.com> <20041207001419.GB12838@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com,
        Dorn Hetzel <kernel@dorn.hetzel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
Content-Disposition: inline
In-Reply-To: <20041207001419.GB12838@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Back to C101 and code which gives the expected result.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-255 drivers/net/r8169.c
--- linux-2.6.10-rc2/drivers/net/r8169.c~r8169-255	2004-12-05 22:36:19.717006983 +0100
+++ linux-2.6.10-rc2-fr/drivers/net/r8169.c	2004-12-05 22:36:19.721006330 +0100
@@ -1978,7 +1978,7 @@ static void rtl8169_pcierr_interrupt(str
 		PCI_STATUS_REC_TARGET_ABORT | PCI_STATUS_SIG_TARGET_ABORT));
 
 	/* The infamous DAC f*ckup only happens at boot time */
-	if ((tp->cp_cmd & PCIDAC) && (tp->dirty_rx == tp->cur_rx == 0)) {
+	if ((tp->cp_cmd & PCIDAC) && !tp->dirty_rx && !tp->cur_rx) {
 		printk(KERN_INFO PFX "%s: disabling PCI DAC.\n", dev->name);
 		tp->cp_cmd &= ~PCIDAC;
 		RTL_W16(CPlusCmd, tp->cp_cmd);

_
