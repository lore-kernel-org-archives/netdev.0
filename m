From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2/3] 2.6.5-netdev2 - r8169 update
Date: Wed, 7 Apr 2004 23:15:29 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040407231529.B25867@electric-eye.fr.zoreil.com>
References: <20040405235545.A20805@electric-eye.fr.zoreil.com> <20040407231332.A25021@electric-eye.fr.zoreil.com> <20040407231444.A25867@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040407231444.A25867@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Wed, Apr 07, 2004 at 11:14:44PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The irq handler must not return 1 when the status register is null
during the firt iteration.


 drivers/net/r8169.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/r8169.c~r8169-irq-handler-status drivers/net/r8169.c
--- linux-2.6.5/drivers/net/r8169.c~r8169-irq-handler-status	2004-04-07 22:56:57.000000000 +0200
+++ linux-2.6.5-fr/drivers/net/r8169.c	2004-04-07 22:58:21.000000000 +0200
@@ -1540,8 +1540,8 @@ rtl8169_interrupt(int irq, void *dev_ins
 	do {
 		status = RTL_R16(IntrStatus);
 
-		/* h/w no longer present (hotplug?) or major error, bail */
-		if (status == 0xFFFF)
+		/* hotplug/major error/no more work/shared irq */
+		if ((status == 0xFFFF) || !status)
 			break;
 
 		handled = 1;

_
