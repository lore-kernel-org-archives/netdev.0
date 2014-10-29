From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v3 10/15] dsa: Add new optional devicetree property to describe EEPROM size
Date: Wed, 29 Oct 2014 10:45:02 -0700
Message-ID: <1414604707-22407-11-git-send-email-linux@roeck-us.net>
References: <1414604707-22407-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>, devicetree@vger.kernel.org,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Rob Herring <robh+dt@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:51789 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755932AbaJ2Rpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 13:45:39 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1XjXJS-0049Ue-Dg
	for netdev@vger.kernel.org; Wed, 29 Oct 2014 17:45:38 +0000
In-Reply-To: <1414604707-22407-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dsa core now supports reading from and writing to a switch EEPROM
if connected. Describe optional devicetree property indicating that
an EEPROM is present and its size.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
v3:
- eeprom-length property is attached to switch devicetree node,
  not to dsa node.
v2:
- Added patch

 Documentation/devicetree/bindings/net/dsa/dsa.txt | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Documentation/devicetree/bindings/net/dsa/dsa.txt
index a62c889..e124847 100644
--- a/Documentation/devicetree/bindings/net/dsa/dsa.txt
+++ b/Documentation/devicetree/bindings/net/dsa/dsa.txt
@@ -10,7 +10,7 @@ Required properties:
 - dsa,ethernet		: Should be a phandle to a valid Ethernet device node
 - dsa,mii-bus		: Should be a phandle to a valid MDIO bus device node
 
-Optionnal properties:
+Optional properties:
 - interrupts		: property with a value describing the switch
 			  interrupt number (not supported by the driver)
 
@@ -23,6 +23,13 @@ Each of these switch child nodes should have the following required properties:
 - #address-cells	: Must be 1
 - #size-cells		: Must be 0
 
+A switch child node has the following optional property:
+
+- eeprom-length		: Set to the length of an EEPROM connected to the
+			  switch. Must be set if the switch can not detect
+			  the presence and/or size of a connected EEPROM,
+			  otherwise optional.
+
 A switch may have multiple "port" children nodes
 
 Each port children node must have the following mandatory properties:
-- 
1.9.1
