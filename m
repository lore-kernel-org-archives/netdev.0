From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] PCnet: Fix section mismatch
Date: Wed, 10 Aug 2011 16:23:46 +0100
Message-ID: <20110810152346.GA6092@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
	linux-mips@linux-mips.org
To: "David S. Miller" <davem@davemloft.net>,
	Don Fry <pcnet32@frontier.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h5.dl5rb.org.uk ([81.2.74.5]:53991 "EHLO linux-mips.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752026Ab1HJPYB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Aug 2011 11:24:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Building MIPS mtx1_defconfig results in:

  MODPOST 735 modules
WARNING: drivers/net/pcnet32.o(.devinit.text+0x11ec): Section mismatch in reference from the function pcnet32_probe_vlbus.constprop.22() to the variable .init.data:pcnet32_portlist
The function __devinit pcnet32_probe_vlbus.constprop.22() references
a variable __initdata pcnet32_portlist.
If pcnet32_portlist is only used by pcnet32_probe_vlbus.constprop.22 then
annotate pcnet32_portlist with a matching annotation.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

---
As recently discussed in the discussion of submission of a fix for a
similar bug in another driver remove __initdata rather than replace it
with __devinitdata.

 drivers/net/pcnet32.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 8b3090d..80b6f36 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -82,7 +82,7 @@ static int cards_found;
 /*
  * VLB I/O addresses
  */
-static unsigned int pcnet32_portlist[] __initdata =
+static unsigned int pcnet32_portlist[] =
     { 0x300, 0x320, 0x340, 0x360, 0 };
 
 static int pcnet32_debug;
