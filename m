From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 3/4] e1000e: remove RXSEQ link monitoring for serdes
Date: Tue, 10 Feb 2009 14:52:05 -0800
Message-ID: <20090210225205.32208.91681.stgit@lost.foo-projects.org>
References: <20090210225116.32208.78338.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	dave graham <david.graham@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:55352 "EHLO
	QMTA06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755680AbZBJWw2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 17:52:28 -0500
In-Reply-To: <20090210225116.32208.78338.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: dave graham <david.graham@intel.com>

RXSEQ interrupts were used to force link state interrogation of serdes
links, as the Si was not guaranteed to report LSC interrupts when the
link changed state. On some bladeservers this resulted in false link up
reports if no link partner was connected. The RXSEQ treatment is
not necessary, as the link can be monitored from the watchdog timer, and
the false link indications cease.

Signed-off-by: dave graham <david.graham@intel.com>
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 00e19e9..04e007d 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1153,7 +1153,7 @@ static irqreturn_t e1000_intr_msi(int irq, void *data)
 	 * read ICR disables interrupts using IAM
 	 */
 
-	if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {
+	if (icr & E1000_ICR_LSC) {
 		hw->mac.get_link_status = 1;
 		/*
 		 * ICH8 workaround-- Call gig speed drop workaround on cable
@@ -1219,7 +1219,7 @@ static irqreturn_t e1000_intr(int irq, void *data)
 	 * IMC write
 	 */
 
-	if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {
+	if (icr & E1000_ICR_LSC) {
 		hw->mac.get_link_status = 1;
 		/*
 		 * ICH8 workaround-- Call gig speed drop workaround on cable

