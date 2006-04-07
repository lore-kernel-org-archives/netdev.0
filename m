From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 20/21] orinoco: further comment cleanup in the PCI drivers
Date: Fri, 07 Apr 2006 04:11:00 -0400
Message-ID: <20060407081100.16107.94176.stgit@dv.roinet.com>
References: <20060407081019.16107.67672.stgit@dv.roinet.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
In-Reply-To: <20060407081019.16107.67672.stgit-fdEtzkpK75rby3iVrkZq2A@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
---

 drivers/net/wireless/orinoco_nortel.c |    7 +--
 drivers/net/wireless/orinoco_pci.c    |   69 +++++----------------------=
------
 drivers/net/wireless/orinoco_plx.c    |   42 +++-----------------
 drivers/net/wireless/orinoco_tmd.c    |   16 +-------
 4 files changed, 22 insertions(+), 112 deletions(-)

diff --git a/drivers/net/wireless/orinoco_nortel.c b/drivers/net/wireless=
/orinoco_nortel.c
index deb22fb..1596182 100644
--- a/drivers/net/wireless/orinoco_nortel.c
+++ b/drivers/net/wireless/orinoco_nortel.c
@@ -3,7 +3,6 @@
  * Driver for Prism II devices which would usually be driven by orinoco_=
cs,
  * but are connected to the PCI bus by a PCI-to-PCMCIA adapter used in
  * Nortel emobility, Symbol LA-4113 and Symbol LA-4123.
- * but are connected to the PCI bus by a Nortel PCI-PCMCIA-Adapter.=20
  *
  * Copyright (C) 2002 Tobias Hoffmann
  *           (C) 2003 Christoph Jungegger <disdos-Bv35esvkf38b1SvskN2V4Q@public.gmane.org>
@@ -57,7 +56,7 @@ #define COR_VALUE     (COR_LEVEL_REQ | C
=20
=20
 /*
- * Do a soft reset of the PCI card using the Configuration Option Regist=
er
+ * Do a soft reset of the card using the Configuration Option Register
  * We need this to get going...
  * This is the part of the code that is strongly inspired from wlan-ng
  *
@@ -68,7 +67,7 @@ static int orinoco_nortel_cor_reset(stru
 {
 	struct orinoco_pci_card *card =3D priv->card;
=20
-	/* Assert the reset until the card notice */
+	/* Assert the reset until the card notices */
 	iowrite16(8, card->bridge_io + 2);
 	ioread16(card->attr_io + COR_OFFSET);
 	iowrite16(0x80, card->attr_io + COR_OFFSET);
@@ -126,7 +125,7 @@ static int orinoco_nortel_hw_init(struct
 		return -EBUSY;
 	}
=20
-	/* Set the PCMCIA COR-Register */
+	/* Set the PCMCIA COR register */
 	iowrite16(COR_VALUE, card->attr_io + COR_OFFSET);
 	mdelay(1);
 	reg =3D ioread16(card->attr_io + COR_OFFSET);
diff --git a/drivers/net/wireless/orinoco_pci.c b/drivers/net/wireless/or=
inoco_pci.c
index 41efac2..df37b95 100644
--- a/drivers/net/wireless/orinoco_pci.c
+++ b/drivers/net/wireless/orinoco_pci.c
@@ -1,11 +1,11 @@
 /* orinoco_pci.c
  *=20
- * Driver for Prism II devices that have a direct PCI interface
- * (i.e., not in a Pcmcia or PLX bridge)
- *
- * Specifically here we're talking about the Linksys WMP11
+ * Driver for Prism 2.5/3 devices that have a direct PCI interface
+ * (i.e. these are not PCMCIA cards in a PCMCIA-to-PCI bridge).
+ * The card contains only one PCI region, which contains all the usual
+ * hermes registers, as well as the COR register.
  *
- * Current maintainers (as of 29 September 2003) are:
+ * Current maintainers are:
  * 	Pavel Roskin <proski AT gnu.org>
  * and	David Gibson <hermes AT gibson.dropbear.id.au>
  *
@@ -39,54 +39,6 @@
  * other provisions required by the GPL.  If you do not delete the
  * provisions above, a recipient may use your version of this file
  * under either the MPL or the GPL.
- */
-
-/*
- * Theory of operation...
- * -------------------
- * Maybe you had a look in orinoco_plx. Well, this is totally different.=
..
- *
- * The card contains only one PCI region, which contains all the usual
- * hermes registers.
- *
- * The driver will memory map this region in normal memory. Because
- * the hermes registers are mapped in normal memory and not in ISA I/O
- * post space, we can't use the usual inw/outw macros and we need to
- * use readw/writew.
- * This slight difference force us to compile our own version of
- * hermes.c with the register access macro changed. That's a bit
- * hackish but works fine.
- *
- * Note that the PCI region is pretty big (4K). That's much more than
- * the usual set of hermes register (0x0 -> 0x3E). I've got a strong
- * suspicion that the whole memory space of the adapter is in fact in
- * this region. Accessing directly the adapter memory instead of going
- * through the usual register would speed up significantely the
- * operations...
- *
- * Finally, the card looks like this :
------------------------
-  Bus  0, device  14, function  0:
-    Network controller: PCI device 1260:3873 (Harris Semiconductor) (rev=
 1).
-      IRQ 11.
-      Master Capable.  Latency=3D248. =20
-      Prefetchable 32 bit memory at 0xffbcc000 [0xffbccfff].
------------------------
-00:0e.0 Network controller: Harris Semiconductor: Unknown device 3873 (r=
ev 01)
-        Subsystem: Unknown device 1737:3874
-        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParE=
rr- Stepping- SERR- FastB2B-
-        Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbor=
t- <TAbort- <MAbort- >SERR- <PERR-
-        Latency: 248 set, cache line size 08
-        Interrupt: pin A routed to IRQ 11
-        Region 0: Memory at ffbcc000 (32-bit, prefetchable) [size=3D4K]
-        Capabilities: [dc] Power Management version 2
-                Flags: PMEClk- AuxPwr- DSI- D1+ D2+ PME+
-                Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
------------------------
- *
- * That's all..
- *
- * Jean II
  */
=20
 #define DRIVER_NAME "orinoco_pci"
@@ -102,11 +54,12 @@ #include <linux/pci.h>
 #include "orinoco.h"
 #include "orinoco_pci.h"
=20
-/* All the magic there is from wlan-ng */
-/* Magic offset of the reset register of the PCI card */
+/* Offset of the COR register of the PCI card */
 #define HERMES_PCI_COR		(0x26)
-/* Magic bitmask to reset the card */
+
+/* Bitmask to reset the card */
 #define HERMES_PCI_COR_MASK	(0x0080)
+
 /* Magic timeouts for doing the reset.
  * Those times are straight from wlan-ng, and it is claimed that they
  * are necessary. Alan will kill me. Take your time and grab a coffee. *=
/
@@ -115,7 +68,7 @@ #define HERMES_PCI_COR_OFFT	(500)		/* ms
 #define HERMES_PCI_COR_BUSYT	(500)		/* ms */
=20
 /*
- * Do a soft reset of the PCI card using the Configuration Option Regist=
er
+ * Do a soft reset of the card using the Configuration Option Register
  * We need this to get going...
  * This is the part of the code that is strongly inspired from wlan-ng
  *
@@ -133,7 +86,7 @@ static int orinoco_pci_cor_reset(struct=20
 	unsigned long timeout;
 	u16 reg;
=20
-	/* Assert the reset until the card notice */
+	/* Assert the reset until the card notices */
 	hermes_write_regn(hw, PCI_COR, HERMES_PCI_COR_MASK);
 	mdelay(HERMES_PCI_COR_ONT);
=20
diff --git a/drivers/net/wireless/orinoco_plx.c b/drivers/net/wireless/or=
inoco_plx.c
index c00388e..7b94050 100644
--- a/drivers/net/wireless/orinoco_plx.c
+++ b/drivers/net/wireless/orinoco_plx.c
@@ -3,7 +3,7 @@
  * Driver for Prism II devices which would usually be driven by orinoco_=
cs,
  * but are connected to the PCI bus by a PLX9052.
  *
- * Current maintainers (as of 29 September 2003) are:
+ * Current maintainers are:
  * 	Pavel Roskin <proski AT gnu.org>
  * and	David Gibson <hermes AT gibson.dropbear.id.au>
  *
@@ -30,38 +30,18 @@
  * other provisions required by the GPL.  If you do not delete the
  * provisions above, a recipient may use your version of this file
  * under either the MPL or the GPL.
-
- * Caution: this is experimental and probably buggy.  For success and
- * failure reports for different cards and adaptors, see
- * orinoco_plx_id_table near the end of the file.  If you have a
- * card we don't have the PCI id for, and looks like it should work,
- * drop me mail with the id and "it works"/"it doesn't work".
- *
- * Note: if everything gets detected fine but it doesn't actually send
- * or receive packets, your first port of call should probably be to
- * try newer firmware in the card.  Especially if you're doing Ad-Hoc
- * modes.
- *
- * The actual driving is done by orinoco.c, this is just resource
- * allocation stuff.  The explanation below is courtesy of Ryan Niemi
- * on the linux-wlan-ng list at
- * http://archives.neohapsis.com/archives/dev/linux-wlan/2001-q1/0026.ht=
ml
  *
- * The PLX9052-based cards (WL11000 and several others) are a
- * different beast than the usual PCMCIA-based PRISM2 configuration
- * expected by wlan-ng.  Here's the general details on how the WL11000
- * PCI adapter works:
+ * Here's the general details on how the PLX9052 adapter works:
  *
  * - Two PCI I/O address spaces, one 0x80 long which contains the
  * PLX9052 registers, and one that's 0x40 long mapped to the PCMCIA
  * slot I/O address space.
  *
- * - One PCI memory address space, mapped to the PCMCIA memory space
+ * - One PCI memory address space, mapped to the PCMCIA attribute space
  * (containing the CIS).
  *
- * After identifying the I/O and memory space, you can read through
- * the memory space to confirm the CIS's device ID or manufacturer ID
- * to make sure it's the expected card.  qKeep in mind that the PCMCIA
+ * Using the later, you can read through the CIS data to make sure the
+ * card is compatible with the driver. Keep in mind that the PCMCIA
  * spec specifies the CIS as the lower 8 bits of each word read from
  * the CIS, so to read the bytes of the CIS, read every other byte
  * (0,2,4,...). Passing that test, you need to enable the I/O address
@@ -71,7 +51,7 @@
  * within the PCI memory space. Write 0x41 to the COR register to
  * enable I/O mode and to select level triggered interrupts. To
  * confirm you actually succeeded, read the COR register back and make
- * sure it actually got set to 0x41, incase you have an unexpected
+ * sure it actually got set to 0x41, in case you have an unexpected
  * card inserted.
  *
  * Following that, you can treat the second PCI I/O address space (the
@@ -101,16 +81,6 @@
  * that, I've hot-swapped a number of times during debugging and
  * driver development for various reasons (stuck WAIT# line after the
  * radio card's firmware locks up).
- *
- * Hope this is enough info for someone to add PLX9052 support to the
- * wlan-ng card. In the case of the WL11000, the PCI ID's are
- * 0x1639/0x0200, with matching subsystem ID's. Other PLX9052-based
- * manufacturers other than Eumitcom (or on cards other than the
- * WL11000) may have different PCI ID's.
- *
- * If anyone needs any more specific info, let me know. I haven't had
- * time to implement support myself yet, and with the way things are
- * going, might not have time for a while..
  */
=20
 #define DRIVER_NAME "orinoco_plx"
diff --git a/drivers/net/wireless/orinoco_tmd.c b/drivers/net/wireless/or=
inoco_tmd.c
index 438fe54..0496663 100644
--- a/drivers/net/wireless/orinoco_tmd.c
+++ b/drivers/net/wireless/orinoco_tmd.c
@@ -26,25 +26,13 @@
  * other provisions required by the GPL.  If you do not delete the
  * provisions above, a recipient may use your version of this file
  * under either the MPL or the GPL.
-
- * Caution: this is experimental and probably buggy.  For success and
- * failure reports for different cards and adaptors, see
- * orinoco_tmd_id_table near the end of the file.  If you have a
- * card we don't have the PCI id for, and looks like it should work,
- * drop me mail with the id and "it works"/"it doesn't work".
- *
- * Note: if everything gets detected fine but it doesn't actually send
- * or receive packets, your first port of call should probably be to
- * try newer firmware in the card.  Especially if you're doing Ad-Hoc
- * modes.
  *
  * The actual driving is done by orinoco.c, this is just resource
  * allocation stuff.
  *
  * This driver is modeled after the orinoco_plx driver. The main
- * difference is that the TMD chip has only IO port ranges and no
- * memory space, i.e.  no access to the CIS. Compared to the PLX chip,
- * the io range functionalities are exchanged.
+ * difference is that the TMD chip has only IO port ranges and doesn't
+ * provide access to the PCMCIA attribute space.
  *
  * Pheecom sells cards with the TMD chip as "ASIC version"
  */



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
