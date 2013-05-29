From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 07/11] net: emaclite: Support multiple phys connected to one MDIO bus
Date: Wed, 29 May 2013 17:33:07 +0200
Message-ID: <7c5f92357e1b6614ea1f51df616a703865f0dd70.1369841519.git.michal.simek@xilinx.com>
References: <131c9262c3094ee3c664bd729a66e0709ceae82c.1369841519.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-27631-1369841613-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Michal Simek <monstr@monstr.eu>,
	Michal Simek <michal.simek@xilinx.com>,
	Bill Pemberton <wfp5p@virginia.edu>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <131c9262c3094ee3c664bd729a66e0709ceae82c.1369841519.git.michal.simek@xilinx.com>
In-Reply-To: <131c9262c3094ee3c664bd729a66e0709ceae82c.1369841519.git.michal.simek@xilinx.com>
References: <131c9262c3094ee3c664bd729a66e0709ceae82c.1369841519.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-27631-1369841613-0001

For system which contains at least two ethernet IP where
one IP manage MDIO bus with several PHYs.

Example dts node:
ethernet_mac0: ethernet@81000000 {
	compatible = "xlnx,xps-ethernetlite-1.00.a";
	device_type = "network";
	interrupt-parent = <&xps_intc_0>;
	interrupts = < 1 0 >;
		local-mac-address = [ 00 0a 35 00 db bb ];
	phy-handle = <&ethernet_mac0_phy0>;
	reg = < 0x81000000 0x10000 >;
	xlnx,duplex = <0x1>;
	xlnx,family = "spartan3e";
	xlnx,include-internal-loopback = <0x0>;
	xlnx,include-mdio = <0x1>;
	xlnx,rx-ping-pong = <0x0>;
	xlnx,tx-ping-pong = <0x0>;
	ethernet_mac0_mdio {
		#address-cells = <1>;
		#size-cells = <0>;
		ethernet_mac0_phy0: phy@1 {
			reg = <0x1>;
		} ;
		ethernet_mac0_phy1: phy@3 {
			reg = <0x3>;
		} ;
	} ;
} ;
ethernet_mac2: ethernet@81040000 {
	compatible = "xlnx,xps-ethernetlite-1.00.a";
	device_type = "network";
	interrupt-parent = <&xps_intc_0>;
	interrupts = < 11 0 >;
		local-mac-address = [ 00 0a 35 00 db bb ];
	phy-handle = <&ethernet_mac0_phy1>;
	reg = < 0x81040000 0x10000 >;
	xlnx,duplex = <0x1>;
	xlnx,family = "spartan3e";
	xlnx,include-internal-loopback = <0x0>;
	xlnx,include-mdio = <0x0>;
	xlnx,rx-ping-pong = <0x0>;
	xlnx,tx-ping-pong = <0x0>;
} ;

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---
 drivers/net/ethernet/xilinx/xilinx_emaclite.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index a16dc35..fcd1e0b 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -848,6 +848,7 @@ static int xemaclite_mdio_setup(struct net_local *lp, struct device *dev)
 	int rc;
 	struct resource res;
 	struct device_node *np = of_get_parent(lp->phy_node);
+	struct device_node *npp;

 	/* Don't register the MDIO bus if the phy_node or its parent node
 	 * can't be found.
@@ -856,6 +857,17 @@ static int xemaclite_mdio_setup(struct net_local *lp, struct device *dev)
 		dev_err(dev, "Failed to register mdio bus.\n");
 		return -ENODEV;
 	}
+	npp = of_get_parent(np);
+
+	of_address_to_resource(npp, 0, &res);
+	if (lp->ndev->mem_start != res.start) {
+		struct phy_device *phydev;
+		phydev = of_phy_find_device(lp->phy_node);
+		if (!phydev)
+			dev_info(dev,
+				 "MDIO of the phy is not registered yet\n");
+		return 0;
+	}

 	/* Enable the MDIO bus by asserting the enable bit in MDIO Control
 	 * register.
@@ -869,7 +881,6 @@ static int xemaclite_mdio_setup(struct net_local *lp, struct device *dev)
 		return -ENOMEM;
 	}

-	of_address_to_resource(np, 0, &res);
 	snprintf(bus->id, MII_BUS_ID_SIZE, "%.8llx",
 		 (unsigned long long)res.start);
 	bus->priv = lp;
--
1.8.2.3


--=_mimegpg-monstr-desktop-27631-1369841613-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlGmH80ACgkQykllyylKDCHEugCfYIgywNdnlNiFkNmsYvZ0wJ7Y
kY4An1NAMRwxvkmIeH0G+ESWEUpdrHWd
=b7E2
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-27631-1369841613-0001--
