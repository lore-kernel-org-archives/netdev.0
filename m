From: Barry Grussling <barry@grussling.com>
Subject: [PATCH V2 1/4] DSA: Convert DSA comments to network-style comments
Date: Tue,  8 Jan 2013 18:05:53 -0800
Message-ID: <1357697156-5767-2-git-send-email-barry@grussling.com>
References: <1357697156-5767-1-git-send-email-barry@grussling.com>
Cc: Barry Grussling <barry@grussling.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:49987 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753851Ab3AICGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 21:06:14 -0500
Received: by mail-pb0-f45.google.com with SMTP id mc8so616358pbc.18
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 18:06:14 -0800 (PST)
In-Reply-To: <1357697156-5767-1-git-send-email-barry@grussling.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Barry Grussling <barry@grussling.com>

Convert DSA driver comments to network-style comments as reported by
checkpatch.pl.  Fix spelling error.

Signed-off-by: Barry Grussling <barry@grussling.com>
---
 drivers/net/dsa/mv88e6060.c       |   31 +++-------
 drivers/net/dsa/mv88e6123_61_65.c |  113 +++++++++++--------------------------
 drivers/net/dsa/mv88e6131.c       |  102 ++++++++++-----------------------
 drivers/net/dsa/mv88e6xxx.c       |   70 ++++++-----------------
 drivers/net/dsa/mv88e6xxx.h       |    9 +--
 5 files changed, 93 insertions(+), 232 deletions(-)

diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index 325391d..637373c 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -67,27 +67,19 @@ static int mv88e6060_switch_reset(struct dsa_switch *ds)
 	int i;
 	int ret;
 
-	/*
-	 * Set all ports to the disabled state.
-	 */
+	/* Set all ports to the disabled state. */
 	for (i = 0; i < 6; i++) {
 		ret = REG_READ(REG_PORT(i), 0x04);
 		REG_WRITE(REG_PORT(i), 0x04, ret & 0xfffc);
 	}
 
-	/*
-	 * Wait for transmit queues to drain.
-	 */
+	/* Wait for transmit queues to drain. */
 	msleep(2);
 
-	/*
-	 * Reset the switch.
-	 */
+	/* Reset the switch. */
 	REG_WRITE(REG_GLOBAL, 0x0a, 0xa130);
 
-	/*
-	 * Wait up to one second for reset to complete.
-	 */
+	/* Wait up to one second for reset to complete. */
 	for (i = 0; i < 1000; i++) {
 		ret = REG_READ(REG_GLOBAL, 0x00);
 		if ((ret & 0x8000) == 0x0000)
@@ -103,15 +95,13 @@ static int mv88e6060_switch_reset(struct dsa_switch *ds)
 
 static int mv88e6060_setup_global(struct dsa_switch *ds)
 {
-	/*
-	 * Disable discarding of frames with excessive collisions,
+	/* Disable discarding of frames with excessive collisions,
 	 * set the maximum frame size to 1536 bytes, and mask all
 	 * interrupt sources.
 	 */
 	REG_WRITE(REG_GLOBAL, 0x04, 0x0800);
 
-	/*
-	 * Enable automatic address learning, set the address
+	/* Enable automatic address learning, set the address
 	 * database size to 1024 entries, and set the default aging
 	 * time to 5 minutes.
 	 */
@@ -124,16 +114,14 @@ static int mv88e6060_setup_port(struct dsa_switch *ds, int p)
 {
 	int addr = REG_PORT(p);
 
-	/*
-	 * Do not force flow control, disable Ingress and Egress
+	/* Do not force flow control, disable Ingress and Egress
 	 * Header tagging, disable VLAN tunneling, and set the port
 	 * state to Forwarding.  Additionally, if this is the CPU
 	 * port, enable Ingress and Egress Trailer tagging mode.
 	 */
 	REG_WRITE(addr, 0x04, dsa_is_cpu_port(ds, p) ?  0x4103 : 0x0003);
 
-	/*
-	 * Port based VLAN map: give each port its own address
+	/* Port based VLAN map: give each port its own address
 	 * database, allow the CPU port to talk to each of the 'real'
 	 * ports, and allow each of the 'real' ports to only talk to
 	 * the CPU port.
@@ -144,8 +132,7 @@ static int mv88e6060_setup_port(struct dsa_switch *ds, int p)
 				ds->phys_port_mask :
 				(1 << ds->dst->cpu_port)));
 
-	/*
-	 * Port Association Vector: when learning source addresses
+	/* Port Association Vector: when learning source addresses
 	 * of packets, add the address to the address database using
 	 * a port bitmap that has only the bit for this port set and
 	 * the other bits clear.
diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index c17c75b..a644fc9 100644
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ b/drivers/net/dsa/mv88e6123_61_65.c
@@ -51,27 +51,19 @@ static int mv88e6123_61_65_switch_reset(struct dsa_switch *ds)
 	int i;
 	int ret;
 
-	/*
-	 * Set all ports to the disabled state.
-	 */
+	/* Set all ports to the disabled state. */
 	for (i = 0; i < 8; i++) {
 		ret = REG_READ(REG_PORT(i), 0x04);
 		REG_WRITE(REG_PORT(i), 0x04, ret & 0xfffc);
 	}
 
-	/*
-	 * Wait for transmit queues to drain.
-	 */
+	/* Wait for transmit queues to drain. */
 	msleep(2);
 
-	/*
-	 * Reset the switch.
-	 */
+	/* Reset the switch. */
 	REG_WRITE(REG_GLOBAL, 0x04, 0xc400);
 
-	/*
-	 * Wait up to one second for reset to complete.
-	 */
+	/* Wait up to one second for reset to complete. */
 	for (i = 0; i < 1000; i++) {
 		ret = REG_READ(REG_GLOBAL, 0x00);
 		if ((ret & 0xc800) == 0xc800)
@@ -90,54 +82,45 @@ static int mv88e6123_61_65_setup_global(struct dsa_switch *ds)
 	int ret;
 	int i;
 
-	/*
-	 * Disable the PHY polling unit (since there won't be any
+	/* Disable the PHY polling unit (since there won't be any
 	 * external PHYs to poll), don't discard packets with
 	 * excessive collisions, and mask all interrupt sources.
 	 */
 	REG_WRITE(REG_GLOBAL, 0x04, 0x0000);
 
-	/*
-	 * Set the default address aging time to 5 minutes, and
+	/* Set the default address aging time to 5 minutes, and
 	 * enable address learn messages to be sent to all message
 	 * ports.
 	 */
 	REG_WRITE(REG_GLOBAL, 0x0a, 0x0148);
 
-	/*
-	 * Configure the priority mapping registers.
-	 */
+	/* Configure the priority mapping registers. */
 	ret = mv88e6xxx_config_prio(ds);
 	if (ret < 0)
 		return ret;
 
-	/*
-	 * Configure the upstream port, and configure the upstream
+	/* Configure the upstream port, and configure the upstream
 	 * port as the port to which ingress and egress monitor frames
 	 * are to be sent.
 	 */
 	REG_WRITE(REG_GLOBAL, 0x1a, (dsa_upstream_port(ds) * 0x1110));
 
-	/*
-	 * Disable remote management for now, and set the switch's
+	/* Disable remote management for now, and set the switch's
 	 * DSA device number.
 	 */
 	REG_WRITE(REG_GLOBAL, 0x1c, ds->index & 0x1f);
 
-	/*
-	 * Send all frames with destination addresses matching
+	/* Send all frames with destination addresses matching
 	 * 01:80:c2:00:00:2x to the CPU port.
 	 */
 	REG_WRITE(REG_GLOBAL2, 0x02, 0xffff);
 
-	/*
-	 * Send all frames with destination addresses matching
+	/* Send all frames with destination addresses matching
 	 * 01:80:c2:00:00:0x to the CPU port.
 	 */
 	REG_WRITE(REG_GLOBAL2, 0x03, 0xffff);
 
-	/*
-	 * Disable the loopback filter, disable flow control
+	/* Disable the loopback filter, disable flow control
 	 * messages, disable flood broadcast override, disable
 	 * removing of provider tags, disable ATU age violation
 	 * interrupts, disable tag flow control, force flow
@@ -146,9 +129,7 @@ static int mv88e6123_61_65_setup_global(struct dsa_switch *ds)
 	 */
 	REG_WRITE(REG_GLOBAL2, 0x05, 0x00ff);
 
-	/*
-	 * Program the DSA routing table.
-	 */
+	/* Program the DSA routing table. */
 	for (i = 0; i < 32; i++) {
 		int nexthop;
 
@@ -159,33 +140,24 @@ static int mv88e6123_61_65_setup_global(struct dsa_switch *ds)
 		REG_WRITE(REG_GLOBAL2, 0x06, 0x8000 | (i << 8) | nexthop);
 	}
 
-	/*
-	 * Clear all trunk masks.
-	 */
+	/* Clear all trunk masks. */
 	for (i = 0; i < 8; i++)
 		REG_WRITE(REG_GLOBAL2, 0x07, 0x8000 | (i << 12) | 0xff);
 
-	/*
-	 * Clear all trunk mappings.
-	 */
+	/* Clear all trunk mappings. */
 	for (i = 0; i < 16; i++)
 		REG_WRITE(REG_GLOBAL2, 0x08, 0x8000 | (i << 11));
 
-	/*
-	 * Disable ingress rate limiting by resetting all ingress
+	/* Disable ingress rate limiting by resetting all ingress
 	 * rate limit registers to their initial state.
 	 */
 	for (i = 0; i < 6; i++)
 		REG_WRITE(REG_GLOBAL2, 0x09, 0x9000 | (i << 8));
 
-	/*
-	 * Initialise cross-chip port VLAN table to reset defaults.
-	 */
+	/* Initialise cross-chip port VLAN table to reset defaults. */
 	REG_WRITE(REG_GLOBAL2, 0x0b, 0x9000);
 
-	/*
-	 * Clear the priority override table.
-	 */
+	/* Clear the priority override table. */
 	for (i = 0; i < 16; i++)
 		REG_WRITE(REG_GLOBAL2, 0x0f, 0x8000 | (i << 8));
 
@@ -199,8 +171,7 @@ static int mv88e6123_61_65_setup_port(struct dsa_switch *ds, int p)
 	int addr = REG_PORT(p);
 	u16 val;
 
-	/*
-	 * MAC Forcing register: don't force link, speed, duplex
+	/* MAC Forcing register: don't force link, speed, duplex
 	 * or flow control state to any particular values on physical
 	 * ports, but force the CPU port and all DSA ports to 1000 Mb/s
 	 * full duplex.
@@ -210,15 +181,13 @@ static int mv88e6123_61_65_setup_port(struct dsa_switch *ds, int p)
 	else
 		REG_WRITE(addr, 0x01, 0x0003);
 
-	/*
-	 * Do not limit the period of time that this port can be
+	/* Do not limit the period of time that this port can be
 	 * paused for by the remote end or the period of time that
 	 * this port can pause the remote end.
 	 */
 	REG_WRITE(addr, 0x02, 0x0000);
 
-	/*
-	 * Port Control: disable Drop-on-Unlock, disable Drop-on-Lock,
+	/* Port Control: disable Drop-on-Unlock, disable Drop-on-Lock,
 	 * disable Header mode, enable IGMP/MLD snooping, disable VLAN
 	 * tunneling, determine priority by looking at 802.1p and IP
 	 * priority fields (IP prio has precedence), and set STP state
@@ -245,14 +214,12 @@ static int mv88e6123_61_65_setup_port(struct dsa_switch *ds, int p)
 		val |= 0x000c;
 	REG_WRITE(addr, 0x04, val);
 
-	/*
-	 * Port Control 1: disable trunking.  Also, if this is the
+	/* Port Control 1: disable trunking.  Also, if this is the
 	 * CPU port, enable learn messages to be sent to this port.
 	 */
 	REG_WRITE(addr, 0x05, dsa_is_cpu_port(ds, p) ? 0x8000 : 0x0000);
 
-	/*
-	 * Port based VLAN map: give each port its own address
+	/* Port based VLAN map: give each port its own address
 	 * database, allow the CPU port to talk to each of the 'real'
 	 * ports, and allow each of the 'real' ports to only talk to
 	 * the upstream port.
@@ -264,14 +231,12 @@ static int mv88e6123_61_65_setup_port(struct dsa_switch *ds, int p)
 		val |= 1 << dsa_upstream_port(ds);
 	REG_WRITE(addr, 0x06, val);
 
-	/*
-	 * Default VLAN ID and priority: don't set a default VLAN
+	/* Default VLAN ID and priority: don't set a default VLAN
 	 * ID, and set the default packet priority to zero.
 	 */
 	REG_WRITE(addr, 0x07, 0x0000);
 
-	/*
-	 * Port Control 2: don't force a good FCS, set the maximum
+	/* Port Control 2: don't force a good FCS, set the maximum
 	 * frame size to 10240 bytes, don't let the switch add or
 	 * strip 802.1q tags, don't discard tagged or untagged frames
 	 * on this port, do a destination address lookup on all
@@ -281,48 +246,36 @@ static int mv88e6123_61_65_setup_port(struct dsa_switch *ds, int p)
 	 */
 	REG_WRITE(addr, 0x08, 0x2080);
 
-	/*
-	 * Egress rate control: disable egress rate control.
-	 */
+	/* Egress rate control: disable egress rate control. */
 	REG_WRITE(addr, 0x09, 0x0001);
 
-	/*
-	 * Egress rate control 2: disable egress rate control.
-	 */
+	/* Egress rate control 2: disable egress rate control. */
 	REG_WRITE(addr, 0x0a, 0x0000);
 
-	/*
-	 * Port Association Vector: when learning source addresses
+	/* Port Association Vector: when learning source addresses
 	 * of packets, add the address to the address database using
 	 * a port bitmap that has only the bit for this port set and
 	 * the other bits clear.
 	 */
 	REG_WRITE(addr, 0x0b, 1 << p);
 
-	/*
-	 * Port ATU control: disable limiting the number of address
+	/* Port ATU control: disable limiting the number of address
 	 * database entries that this port is allowed to use.
 	 */
 	REG_WRITE(addr, 0x0c, 0x0000);
 
-	/*
-	 * Priorit Override: disable DA, SA and VTU priority override.
-	 */
+	/* Priority Override: disable DA, SA and VTU priority override. */
 	REG_WRITE(addr, 0x0d, 0x0000);
 
-	/*
-	 * Port Ethertype: use the Ethertype DSA Ethertype value.
-	 */
+	/* Port Ethertype: use the Ethertype DSA Ethertype value. */
 	REG_WRITE(addr, 0x0f, ETH_P_EDSA);
 
-	/*
-	 * Tag Remap: use an identity 802.1p prio -> switch prio
+	/* Tag Remap: use an identity 802.1p prio -> switch prio
 	 * mapping.
 	 */
 	REG_WRITE(addr, 0x18, 0x3210);
 
-	/*
-	 * Tag Remap 2: use an identity 802.1p prio -> switch prio
+	/* Tag Remap 2: use an identity 802.1p prio -> switch prio
 	 * mapping.
 	 */
 	REG_WRITE(addr, 0x19, 0x7654);
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 55888b0..b613818 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -15,9 +15,7 @@
 #include <net/dsa.h>
 #include "mv88e6xxx.h"
 
-/*
- * Switch product IDs
- */
+/* Switch product IDs */
 #define ID_6085		0x04a0
 #define ID_6095		0x0950
 #define ID_6131		0x1060
@@ -45,27 +43,19 @@ static int mv88e6131_switch_reset(struct dsa_switch *ds)
 	int i;
 	int ret;
 
-	/*
-	 * Set all ports to the disabled state.
-	 */
+	/* Set all ports to the disabled state. */
 	for (i = 0; i < 11; i++) {
 		ret = REG_READ(REG_PORT(i), 0x04);
 		REG_WRITE(REG_PORT(i), 0x04, ret & 0xfffc);
 	}
 
-	/*
-	 * Wait for transmit queues to drain.
-	 */
+	/* Wait for transmit queues to drain. */
 	msleep(2);
 
-	/*
-	 * Reset the switch.
-	 */
+	/* Reset the switch. */
 	REG_WRITE(REG_GLOBAL, 0x04, 0xc400);
 
-	/*
-	 * Wait up to one second for reset to complete.
-	 */
+	/* Wait up to one second for reset to complete. */
 	for (i = 0; i < 1000; i++) {
 		ret = REG_READ(REG_GLOBAL, 0x00);
 		if ((ret & 0xc800) == 0xc800)
@@ -84,42 +74,34 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 	int ret;
 	int i;
 
-	/*
-	 * Enable the PHY polling unit, don't discard packets with
+	/* Enable the PHY polling unit, don't discard packets with
 	 * excessive collisions, use a weighted fair queueing scheme
 	 * to arbitrate between packet queues, set the maximum frame
 	 * size to 1632, and mask all interrupt sources.
 	 */
 	REG_WRITE(REG_GLOBAL, 0x04, 0x4400);
 
-	/*
-	 * Set the default address aging time to 5 minutes, and
+	/* Set the default address aging time to 5 minutes, and
 	 * enable address learn messages to be sent to all message
 	 * ports.
 	 */
 	REG_WRITE(REG_GLOBAL, 0x0a, 0x0148);
 
-	/*
-	 * Configure the priority mapping registers.
-	 */
+	/* Configure the priority mapping registers. */
 	ret = mv88e6xxx_config_prio(ds);
 	if (ret < 0)
 		return ret;
 
-	/*
-	 * Set the VLAN ethertype to 0x8100.
-	 */
+	/* Set the VLAN ethertype to 0x8100. */
 	REG_WRITE(REG_GLOBAL, 0x19, 0x8100);
 
-	/*
-	 * Disable ARP mirroring, and configure the upstream port as
+	/* Disable ARP mirroring, and configure the upstream port as
 	 * the port to which ingress and egress monitor frames are to
 	 * be sent.
 	 */
 	REG_WRITE(REG_GLOBAL, 0x1a, (dsa_upstream_port(ds) * 0x1100) | 0x00f0);
 
-	/*
-	 * Disable cascade port functionality unless this device
+	/* Disable cascade port functionality unless this device
 	 * is used in a cascade configuration, and set the switch's
 	 * DSA device number.
 	 */
@@ -128,23 +110,19 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 	else
 		REG_WRITE(REG_GLOBAL, 0x1c, 0xe000 | (ds->index & 0x1f));
 
-	/*
-	 * Send all frames with destination addresses matching
+	/* Send all frames with destination addresses matching
 	 * 01:80:c2:00:00:0x to the CPU port.
 	 */
 	REG_WRITE(REG_GLOBAL2, 0x03, 0xffff);
 
-	/*
-	 * Ignore removed tag data on doubly tagged packets, disable
+	/* Ignore removed tag data on doubly tagged packets, disable
 	 * flow control messages, force flow control priority to the
 	 * highest, and send all special multicast frames to the CPU
 	 * port at the highest priority.
 	 */
 	REG_WRITE(REG_GLOBAL2, 0x05, 0x00ff);
 
-	/*
-	 * Program the DSA routing table.
-	 */
+	/* Program the DSA routing table. */
 	for (i = 0; i < 32; i++) {
 		int nexthop;
 
@@ -155,20 +133,15 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 		REG_WRITE(REG_GLOBAL2, 0x06, 0x8000 | (i << 8) | nexthop);
 	}
 
-	/*
-	 * Clear all trunk masks.
-	 */
+	/* Clear all trunk masks. */
 	for (i = 0; i < 8; i++)
 		REG_WRITE(REG_GLOBAL2, 0x07, 0x8000 | (i << 12) | 0x7ff);
 
-	/*
-	 * Clear all trunk mappings.
-	 */
+	/* Clear all trunk mappings. */
 	for (i = 0; i < 16; i++)
 		REG_WRITE(REG_GLOBAL2, 0x08, 0x8000 | (i << 11));
 
-	/*
-	 * Force the priority of IGMP/MLD snoop frames and ARP frames
+	/* Force the priority of IGMP/MLD snoop frames and ARP frames
 	 * to the highest setting.
 	 */
 	REG_WRITE(REG_GLOBAL2, 0x0f, 0x00ff);
@@ -182,8 +155,7 @@ static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
 	int addr = REG_PORT(p);
 	u16 val;
 
-	/*
-	 * MAC Forcing register: don't force link, speed, duplex
+	/* MAC Forcing register: don't force link, speed, duplex
 	 * or flow control state to any particular values on physical
 	 * ports, but force the CPU port and all DSA ports to 1000 Mb/s
 	 * (100 Mb/s on 6085) full duplex.
@@ -196,8 +168,7 @@ static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
 	else
 		REG_WRITE(addr, 0x01, 0x0003);
 
-	/*
-	 * Port Control: disable Core Tag, disable Drop-on-Lock,
+	/* Port Control: disable Core Tag, disable Drop-on-Lock,
 	 * transmit frames unmodified, disable Header mode,
 	 * enable IGMP/MLD snoop, disable DoubleTag, disable VLAN
 	 * tunneling, determine priority by looking at 802.1p and
@@ -214,8 +185,7 @@ static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
 	val = 0x0433;
 	if (p == dsa_upstream_port(ds)) {
 		val |= 0x0104;
-		/*
-		 * On 6085, unknown multicast forward is controlled
+		/* On 6085, unknown multicast forward is controlled
 		 * here rather than in Port Control 2 register.
 		 */
 		if (ps->id == ID_6085)
@@ -225,14 +195,12 @@ static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
 		val |= 0x0100;
 	REG_WRITE(addr, 0x04, val);
 
-	/*
-	 * Port Control 1: disable trunking.  Also, if this is the
+	/* Port Control 1: disable trunking.  Also, if this is the
 	 * CPU port, enable learn messages to be sent to this port.
 	 */
 	REG_WRITE(addr, 0x05, dsa_is_cpu_port(ds, p) ? 0x8000 : 0x0000);
 
-	/*
-	 * Port based VLAN map: give each port its own address
+	/* Port based VLAN map: give each port its own address
 	 * database, allow the CPU port to talk to each of the 'real'
 	 * ports, and allow each of the 'real' ports to only talk to
 	 * the upstream port.
@@ -244,14 +212,12 @@ static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
 		val |= 1 << dsa_upstream_port(ds);
 	REG_WRITE(addr, 0x06, val);
 
-	/*
-	 * Default VLAN ID and priority: don't set a default VLAN
+	/* Default VLAN ID and priority: don't set a default VLAN
 	 * ID, and set the default packet priority to zero.
 	 */
 	REG_WRITE(addr, 0x07, 0x0000);
 
-	/*
-	 * Port Control 2: don't force a good FCS, don't use
+	/* Port Control 2: don't force a good FCS, don't use
 	 * VLAN-based, source address-based or destination
 	 * address-based priority overrides, don't let the switch
 	 * add or strip 802.1q tags, don't discard tagged or
@@ -264,8 +230,7 @@ static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
 	 * forwarding of unknown multicast addresses.
 	 */
 	if (ps->id == ID_6085)
-		/*
-		 * on 6085, bits 3:0 are reserved, bit 6 control ARP
+		/* on 6085, bits 3:0 are reserved, bit 6 control ARP
 		 * mirroring, and multicast forward is handled in
 		 * Port Control register.
 		 */
@@ -277,32 +242,25 @@ static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
 		REG_WRITE(addr, 0x08, val);
 	}
 
-	/*
-	 * Rate Control: disable ingress rate limiting.
-	 */
+	/* Rate Control: disable ingress rate limiting. */
 	REG_WRITE(addr, 0x09, 0x0000);
 
-	/*
-	 * Rate Control 2: disable egress rate limiting.
-	 */
+	/* Rate Control 2: disable egress rate limiting. */
 	REG_WRITE(addr, 0x0a, 0x0000);
 
-	/*
-	 * Port Association Vector: when learning source addresses
+	/* Port Association Vector: when learning source addresses
 	 * of packets, add the address to the address database using
 	 * a port bitmap that has only the bit for this port set and
 	 * the other bits clear.
 	 */
 	REG_WRITE(addr, 0x0b, 1 << p);
 
-	/*
-	 * Tag Remap: use an identity 802.1p prio -> switch prio
+	/* Tag Remap: use an identity 802.1p prio -> switch prio
 	 * mapping.
 	 */
 	REG_WRITE(addr, 0x18, 0x3210);
 
-	/*
-	 * Tag Remap 2: use an identity 802.1p prio -> switch prio
+	/* Tag Remap 2: use an identity 802.1p prio -> switch prio
 	 * mapping.
 	 */
 	REG_WRITE(addr, 0x19, 0x7654);
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index a2c62c2..d436668 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -15,8 +15,7 @@
 #include <net/dsa.h>
 #include "mv88e6xxx.h"
 
-/*
- * If the switch's ADDR[4:0] strap pins are strapped to zero, it will
+/* If the switch's ADDR[4:0] strap pins are strapped to zero, it will
  * use all 32 SMI bus addresses on its SMI bus, and all switch registers
  * will be directly accessible on some {device address,register address}
  * pair.  If the ADDR[4:0] pins are not strapped to zero, the switch
@@ -48,30 +47,22 @@ int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr, int reg)
 	if (sw_addr == 0)
 		return mdiobus_read(bus, addr, reg);
 
-	/*
-	 * Wait for the bus to become free.
-	 */
+	/* Wait for the bus to become free. */
 	ret = mv88e6xxx_reg_wait_ready(bus, sw_addr);
 	if (ret < 0)
 		return ret;
 
-	/*
-	 * Transmit the read command.
-	 */
+	/* Transmit the read command. */
 	ret = mdiobus_write(bus, sw_addr, 0, 0x9800 | (addr << 5) | reg);
 	if (ret < 0)
 		return ret;
 
-	/*
-	 * Wait for the read command to complete.
-	 */
+	/* Wait for the read command to complete. */
 	ret = mv88e6xxx_reg_wait_ready(bus, sw_addr);
 	if (ret < 0)
 		return ret;
 
-	/*
-	 * Read the data.
-	 */
+	/* Read the data. */
 	ret = mdiobus_read(bus, sw_addr, 1);
 	if (ret < 0)
 		return ret;
@@ -100,30 +91,22 @@ int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
 	if (sw_addr == 0)
 		return mdiobus_write(bus, addr, reg, val);
 
-	/*
-	 * Wait for the bus to become free.
-	 */
+	/* Wait for the bus to become free. */
 	ret = mv88e6xxx_reg_wait_ready(bus, sw_addr);
 	if (ret < 0)
 		return ret;
 
-	/*
-	 * Transmit the data to write.
-	 */
+	/* Transmit the data to write. */
 	ret = mdiobus_write(bus, sw_addr, 1, val);
 	if (ret < 0)
 		return ret;
 
-	/*
-	 * Transmit the write command.
-	 */
+	/* Transmit the write command. */
 	ret = mdiobus_write(bus, sw_addr, 0, 0x9400 | (addr << 5) | reg);
 	if (ret < 0)
 		return ret;
 
-	/*
-	 * Wait for the write command to complete.
-	 */
+	/* Wait for the write command to complete. */
 	ret = mv88e6xxx_reg_wait_ready(bus, sw_addr);
 	if (ret < 0)
 		return ret;
@@ -146,9 +129,7 @@ int mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
 
 int mv88e6xxx_config_prio(struct dsa_switch *ds)
 {
-	/*
-	 * Configure the IP ToS mapping registers.
-	 */
+	/* Configure the IP ToS mapping registers. */
 	REG_WRITE(REG_GLOBAL, 0x10, 0x0000);
 	REG_WRITE(REG_GLOBAL, 0x11, 0x0000);
 	REG_WRITE(REG_GLOBAL, 0x12, 0x5555);
@@ -158,9 +139,7 @@ int mv88e6xxx_config_prio(struct dsa_switch *ds)
 	REG_WRITE(REG_GLOBAL, 0x16, 0xffff);
 	REG_WRITE(REG_GLOBAL, 0x17, 0xffff);
 
-	/*
-	 * Configure the IEEE 802.1p priority mapping register.
-	 */
+	/* Configure the IEEE 802.1p priority mapping register. */
 	REG_WRITE(REG_GLOBAL, 0x18, 0xfa41);
 
 	return 0;
@@ -183,14 +162,10 @@ int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr)
 	for (i = 0; i < 6; i++) {
 		int j;
 
-		/*
-		 * Write the MAC address byte.
-		 */
+		/* Write the MAC address byte. */
 		REG_WRITE(REG_GLOBAL2, 0x0d, 0x8000 | (i << 8) | addr[i]);
 
-		/*
-		 * Wait for the write to complete.
-		 */
+		/* Wait for the write to complete. */
 		for (j = 0; j < 16; j++) {
 			ret = REG_READ(REG_GLOBAL2, 0x0d);
 			if ((ret & 0x8000) == 0)
@@ -282,8 +257,7 @@ static int mv88e6xxx_ppu_access_get(struct dsa_switch *ds)
 
 	mutex_lock(&ps->ppu_mutex);
 
-	/*
-	 * If the PHY polling unit is enabled, disable it so that
+	/* If the PHY polling unit is enabled, disable it so that
 	 * we can access the PHY registers.  If it was already
 	 * disabled, cancel the timer that is going to re-enable
 	 * it.
@@ -307,9 +281,7 @@ static void mv88e6xxx_ppu_access_put(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = (void *)(ds + 1);
 
-	/*
-	 * Schedule a timer to re-enable the PHY polling unit.
-	 */
+	/* Schedule a timer to re-enable the PHY polling unit. */
 	mod_timer(&ps->ppu_timer, jiffies + msecs_to_jiffies(10));
 	mutex_unlock(&ps->ppu_mutex);
 }
@@ -431,14 +403,10 @@ static int mv88e6xxx_stats_snapshot(struct dsa_switch *ds, int port)
 {
 	int ret;
 
-	/*
-	 * Snapshot the hardware statistics counters for this port.
-	 */
+	/* Snapshot the hardware statistics counters for this port. */
 	REG_WRITE(REG_GLOBAL, 0x1d, 0xdc00 | port);
 
-	/*
-	 * Wait for the snapshotting to complete.
-	 */
+	/* Wait for the snapshotting to complete. */
 	ret = mv88e6xxx_stats_wait(ds);
 	if (ret < 0)
 		return ret;
@@ -502,9 +470,7 @@ void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
 		return;
 	}
 
-	/*
-	 * Read each of the counters.
-	 */
+	/* Read each of the counters. */
 	for (i = 0; i < nr_stats; i++) {
 		struct mv88e6xxx_hw_stat *s = stats + i;
 		u32 low;
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index fc2cd7b..029e13d 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -16,16 +16,14 @@
 #define REG_GLOBAL2		0x1c
 
 struct mv88e6xxx_priv_state {
-	/*
-	 * When using multi-chip addressing, this mutex protects
+	/* When using multi-chip addressing, this mutex protects
 	 * access to the indirect access registers.  (In single-chip
 	 * mode, this mutex is effectively useless.)
 	 */
 	struct mutex	smi_mutex;
 
 #ifdef CONFIG_NET_DSA_MV88E6XXX_NEED_PPU
-	/*
-	 * Handles automatic disabling and re-enabling of the PHY
+	/* Handles automatic disabling and re-enabling of the PHY
 	 * polling unit.
 	 */
 	struct mutex		ppu_mutex;
@@ -34,8 +32,7 @@ struct mv88e6xxx_priv_state {
 	struct timer_list	ppu_timer;
 #endif
 
-	/*
-	 * This mutex serialises access to the statistics unit.
+	/* This mutex serialises access to the statistics unit.
 	 * Hold this mutex over snapshot + dump sequences.
 	 */
 	struct mutex	stats_mutex;
-- 
1.7.9.5
