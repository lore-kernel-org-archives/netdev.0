From: Pavel Machek <pavel@ucw.cz>
Subject: [PATCH] stmmac: cleanup documenation, make it match reality
Date: Thu, 1 Dec 2016 11:32:18 +0100
Message-ID: <20161201103218.GB19056@amd>
References: <20161123105125.GA26394@amd>
 <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="IiVenqGWf+H9Y6IX"
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161124.110416.198867271899443489.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--IiVenqGWf+H9Y6IX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Fix english in documentation, make documentation match reality, remove
options that were removed from code.
   =20
Signed-off-by: Pavel Machek <pavel@denx.de>

diff --git a/Documentation/networking/stmmac.txt b/Documentation/networking=
/stmmac.txt
index e226f89..014f4f7 100644
--- a/Documentation/networking/stmmac.txt
+++ b/Documentation/networking/stmmac.txt
@@ -28,8 +28,6 @@ CONFIG_STMMAC_PCI: is to enable the pci driver.
 2) Driver parameters list:
 	debug: message level (0: no output, 16: all);
 	phyaddr: to manually provide the physical address to the PHY device;
-	dma_rxsize: DMA rx ring size;
-	dma_txsize: DMA tx ring size;
 	buf_sz: DMA buffer size;
 	tc: control the HW FIFO threshold;
 	watchdog: transmit timeout (in milliseconds);
@@ -40,31 +38,31 @@ CONFIG_STMMAC_PCI: is to enable the pci driver.
=20
 3) Command line options
 Driver parameters can be also passed in command line by using:
-	stmmaceth=3Ddma_rxsize:128,dma_txsize:512
+	stmmaceth=3Dwatchdog:100,chain_mode=3D1
=20
 4) Driver information and notes
=20
 4.1) Transmit process
 The xmit method is invoked when the kernel needs to transmit a packet; it =
sets
-the descriptors in the ring and informs the DMA engine that there is a pac=
ket
+the descriptors in the ring and informs the DMA engine, that there is a pa=
cket
 ready to be transmitted.
 By default, the driver sets the NETIF_F_SG bit in the features field of the
-net_device structure enabling the scatter-gather feature. This is true on
+net_device structure, enabling the scatter-gather feature. This is true on
 chips and configurations where the checksum can be done in hardware.
-Once the controller has finished transmitting the packet, napi will be
+Once the controller has finished transmitting the packet, timer will be
 scheduled to release the transmit resources.
=20
 4.2) Receive process
 When one or more packets are received, an interrupt happens. The interrupts
-are not queued so the driver has to scan all the descriptors in the ring d=
uring
+are not queued, so the driver has to scan all the descriptors in the ring =
during
 the receive process.
-This is based on NAPI so the interrupt handler signals only if there is wo=
rk
+This is based on NAPI, so the interrupt handler signals only if there is w=
ork
 to be done, and it exits.
 Then the poll method will be scheduled at some future point.
 The incoming packets are stored, by the DMA, in a list of pre-allocated so=
cket
 buffers in order to avoid the memcpy (zero-copy).
=20
-4.3) Interrupt Mitigation
+4.3) Interrupt mitigation
 The driver is able to mitigate the number of its DMA interrupts
 using NAPI for the reception on chips older than the 3.50.
 New chips have an HW RX-Watchdog used for this mitigation.
@@ -88,19 +86,20 @@ the list, hence creating the explicit chaining in the d=
escriptor itself,
 whereas such explicit chaining is not possible in RING mode.
=20
 4.5.1) Extended descriptors
-	The extended descriptors give us information about the Ethernet payload
-	when it is carrying PTP packets or TCP/UDP/ICMP over IP.
-	These are not available on GMAC Synopsys chips older than the 3.50.
-	At probe time the driver will decide if these can be actually used.
-	This support also is mandatory for PTPv2 because the extra descriptors
-	are used for saving the hardware timestamps and Extended Status.
+The extended descriptors give us information about the Ethernet payload
+when it is carrying PTP packets or TCP/UDP/ICMP over IP.
+These are not available on GMAC Synopsys chips older than the 3.50.
+At probe time the driver will decide if these can be actually used.
+This support also is mandatory for PTPv2 because the extra descriptors
+are used for saving the hardware timestamps and Extended Status.
=20
 4.6) Ethtool support
 Ethtool is supported.
=20
 For example, driver statistics (including RMON), internal errors can be ta=
ken
 using:
-  # ethtool -S ethX command
+  # ethtool -S ethX
+command
=20
 4.7) Jumbo and Segmentation Offloading
 Jumbo frames are supported and tested for the GMAC.
@@ -275,11 +274,11 @@ Please see the following document:
 	Documentation/devicetree/bindings/net/stmmac.txt
=20
 4.11) This is a summary of the content of some relevant files:
- o stmmac_main.c: to implement the main network device driver;
- o stmmac_mdio.c: to provide mdio functions;
- o stmmac_pci: this the PCI driver;
- o stmmac_platform.c: this the platform driver (OF supported)
- o stmmac_ethtool.c: to implement the ethtool support;
+ o stmmac_main.c: implements the main network device driver;
+ o stmmac_mdio.c: provides MDIO functions;
+ o stmmac_pci: this is the PCI driver;
+ o stmmac_platform.c: this the platform driver (OF supported);
+ o stmmac_ethtool.c: implements the ethtool support;
  o stmmac.h: private driver structure;
  o common.h: common definitions and VFTs;
  o mmc_core.c/mmc.h: Management MAC Counters;
@@ -381,12 +380,12 @@ In addition to the basic timestamp features mentioned=
 in IEEE 1588-2002
 Timestamps, new GMAC cores support the advanced timestamp features.
 IEEE 1588-2008 that can be enabled when configure the Kernel.
=20
-8) SGMII/RGMII supports
+8) SGMII/RGMII support
 New GMAC devices provide own way to manage RGMII/SGMII.
 This information is available at run-time by looking at the
 HW capability register. This means that the stmmac can manage
-auto-negotiation and link status w/o using the PHYLIB stuff
+auto-negotiation and link status w/o using the PHYLIB stuff.
 In fact, the HW provides a subset of extended registers to
 restart the ANE, verify Full/Half duplex mode and Speed.
-Also thanks to these registers it is possible to look at the
+Thanks to these registers, it is possible to look at the
 Auto-negotiated Link Parter Ability.
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--IiVenqGWf+H9Y6IX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlg//DIACgkQMOfwapXb+vIr5wCgrksRvv1ieF00R8AOHdFoly2c
dKoAnjXoqZuc53Fyr+o1orN+zvzI9mBf
=nXSM
-----END PGP SIGNATURE-----

--IiVenqGWf+H9Y6IX--
