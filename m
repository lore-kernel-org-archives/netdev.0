From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH v3 0/3] can: at91_can: fix for errata 50.2.6.3 & 50.3.5.3
Date: Mon, 24 Jan 2011 15:15:29 +0100
Message-ID: <1295878532-15769-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, Socketcan-core@lists.berlios.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:41525 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751809Ab1AXOPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 09:15:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

as promised I've implemented the proposed workaround for the errata
50.2.6.3 & 50.3.5.3:
"Contents of Mailbox 0 can be sent Even if Mailbox is Disabled"

This means under high bus load it can happen that the mailbox 0 is send
to the bus. And it does happen, even with the mainline driver where
Mailbox 0 is a receive mailbox. The errata proposes not to use mailbox 0
and load it with an unused can_id that will not disturb the bus.

The first patch cleans up the driver without any functional changes, so
that the mailbox 0 can be disabled in the second patch. The third patch
adds a sysfs parameter to the driver, so that the identifier of mailbox 0
can configured.

This series applies to net-2.6/master. It has been tested on a ronetix pm9263
board against a PCI-SJA1000 card with the canfdtest utility and on custom
at91 boards against each other.

changes since v2:
- rebased to current net-2.6/master
- added Acked-by (Thanks to Kurt Van Dijck, Wolfgang Grandegger
  and Wolfram Sang)

regards, Marc



