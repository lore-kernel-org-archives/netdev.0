From: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
Subject: [PATCH 1/2] dt-bindings: phy: dp83867: provide a workaround for incorrect RX_CTRL pin strap
Date: Tue, 4 Jul 2017 16:23:23 +0530
Message-ID: <ae8b31bf433093590332e7ec65c26320e04d0901.1499162046.git.nsekhar@ti.com>
References: <cover.1499162046.git.nsekhar@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Device Tree Mailing List <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
        Linux OMAP Mailing List <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>,
        Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>,
        Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
To: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1499162046.git.nsekhar-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>

The data manual for DP83867IR/CR, SNLS484E[1], revised march 2017,
advises that strapping RX_DV/RX_CTRL pin in mode 1 and 2 is not
supported (see note below Table 5 (4-Level Strap Pins)).

It further advises that if a board has this pin strapped in mode 1 and
mode 2, then to ensure proper operation of the PHY, a software workaround
must be implemented.

Since it is not possible to detect in software if RX_DV/RX_CTRL pin is
incorrectly strapped, add a device-tree property for the board to
advertise this and allow corrective action in software.

[1] http://www.ti.com/lit/ds/snls484e/snls484e.pdf

Signed-off-by: Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>
[nsekhar-l0cyMroinI0@public.gmane.org: rebase to mainline, split documentation into separate patch]
Signed-off-by: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
---
 Documentation/devicetree/bindings/net/ti,dp83867.txt | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/ti,dp83867.txt b/Documentation/devicetree/bindings/net/ti,dp83867.txt
index afe9630a5e7d..02c4353b5cf2 100644
--- a/Documentation/devicetree/bindings/net/ti,dp83867.txt
+++ b/Documentation/devicetree/bindings/net/ti,dp83867.txt
@@ -18,6 +18,13 @@ Optional property:
 	- ti,max-output-impedance - MAC Interface Impedance control to set
 				    the programmable output impedance to
 				    maximum value (70 ohms).
+	- ti,dp83867-rxctrl-strap-quirk - This denotes the fact that the
+				    board has RX_DV/RX_CTRL pin strapped in
+				    mode 1 or 2. To ensure PHY operation,
+				    there are specific actions that
+				    software needs to take when this pin is
+				    strapped in these modes. See data manual
+				    for details.
 
 Note: ti,min-output-impedance and ti,max-output-impedance are mutually
       exclusive. When both properties are present ti,max-output-impedance
-- 
2.9.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
