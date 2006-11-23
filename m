From: Ralf Baechle <ralf@linux-mips.org>
Subject: [6PACK] Masking bug in 6pack driver
Date: Thu, 23 Nov 2006 18:30:23 +0000
Message-ID: <20061123183023.GA6556@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:59615 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S1755210AbWKWSah
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Nov 2006 13:30:37 -0500
Received: from localhost.localdomain ([127.0.0.1]:687 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20039473AbWKWSag (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Nov 2006 18:30:36 +0000
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Looks like a broken masking to me, binary not is used where bitwise not
was intended.

Signed-off-by: Jean Delvare <khali@linux-fr.org>
Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

---
 drivers/net/hamradio/6pack.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index 102c1f0..d1f6895 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -915,7 +915,7 @@ static void decode_prio_command(struct s
 					printk(KERN_DEBUG "6pack: protocol violation\n");
 				else
 					sp->status = 0;
-				cmd &= !SIXP_RX_DCD_MASK;
+				cmd &= ~SIXP_RX_DCD_MASK;
 		}
 		sp->status = cmd & SIXP_PRIO_DATA_MASK;
 	} else { /* output watchdog char if idle */
