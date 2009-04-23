From: Kumar Gala <galak@kernel.crashing.org>
Subject: [PATCH] powerpc: Refactor board check for PCI quirks on FSL boards
	with uli1575
Date: Wed, 22 Apr 2009 22:47:30 -0500
Message-ID: <1240458450-9939-1-git-send-email-galak@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Refactor the check to determine if the quirk is applicable to the boards
into one inline function so we only have to change one place to add more
boards that the quirks might be applicable to.

Also removed a warning related to unused temp variable.

Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
---
* With new and improved subject line

- k

 arch/powerpc/platforms/fsl_uli1575.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/arch/powerpc/platforms/fsl_uli1575.c b/arch/powerpc/platforms/fsl_uli1575.c
index 65a35f3..df83dc9 100644
--- a/arch/powerpc/platforms/fsl_uli1575.c
+++ b/arch/powerpc/platforms/fsl_uli1575.c
@@ -51,13 +51,19 @@ u8 uli_pirq_to_irq[8] = {
 	ULI_8259_NONE,		/* PIRQH */
 };
 
+static inline bool is_quirk_valid(void)
+{
+	return (machine_is(mpc86xx_hpcn) || 
+		machine_is(mpc8544_ds) ||
+		machine_is(mpc8572_ds));
+}
+
 /* Bridge */
 static void __devinit early_uli5249(struct pci_dev *dev)
 {
 	unsigned char temp;
 
-	if (!machine_is(mpc86xx_hpcn) && !machine_is(mpc8544_ds) &&
-			!machine_is(mpc8572_ds))
+	if (!is_quirk_valid())
 		return;
 
 	pci_write_config_word(dev, PCI_COMMAND, PCI_COMMAND_IO |
@@ -80,8 +86,7 @@ static void __devinit quirk_uli1575(struct pci_dev *dev)
 {
 	int i;
 
-	if (!machine_is(mpc86xx_hpcn) && !machine_is(mpc8544_ds) &&
-			!machine_is(mpc8572_ds))
+	if (!is_quirk_valid())
 		return;
 
 	/*
@@ -149,8 +154,7 @@ static void __devinit quirk_final_uli1575(struct pci_dev *dev)
 	 * IRQ 14: Edge
 	 * IRQ 15: Edge
 	 */
-	if (!machine_is(mpc86xx_hpcn) && !machine_is(mpc8544_ds) &&
-			!machine_is(mpc8572_ds))
+	if (!is_quirk_valid())
 		return;
 
 	outb(0xfa, 0x4d0);
@@ -176,8 +180,7 @@ static void __devinit quirk_uli5288(struct pci_dev *dev)
 	unsigned char c;
 	unsigned int d;
 
-	if (!machine_is(mpc86xx_hpcn) && !machine_is(mpc8544_ds) &&
-			!machine_is(mpc8572_ds))
+	if (!is_quirk_valid())
 		return;
 
 	/* read/write lock */
@@ -201,8 +204,7 @@ static void __devinit quirk_uli5229(struct pci_dev *dev)
 {
 	unsigned short temp;
 
-	if (!machine_is(mpc86xx_hpcn) && !machine_is(mpc8544_ds) &&
-			!machine_is(mpc8572_ds))
+	if (!is_quirk_valid())
 		return;
 
 	pci_write_config_word(dev, PCI_COMMAND, PCI_COMMAND_INTX_DISABLE |
@@ -270,7 +272,6 @@ static void __devinit hpcd_quirk_uli1575(struct pci_dev *dev)
 static void __devinit hpcd_quirk_uli5288(struct pci_dev *dev)
 {
 	unsigned char c;
-	unsigned short temp;
 
 	if (!machine_is(mpc86xx_hpcd))
 		return;
-- 
1.6.0.6
