From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] NET: MIPSsim: Fix modpost warning.
Date: Mon, 21 Jun 2010 14:44:50 +0100
Message-ID: <20100621134450.GA10265@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h5.dl5rb.org.uk ([81.2.74.5]:59743 "EHLO h5.dl5rb.org.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932388Ab0FUNpA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jun 2010 09:45:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

$ make CONFIG_DEBUG_SECTION_MISMATCH=y
[...]
WARNING: drivers/net/built-in.o(.data+0x0): Section mismatch in reference from the variable mipsnet_driver to the function .init.text:mipsnet_probe()
The variable mipsnet_driver references
the function __init mipsnet_probe()
If the reference is valid then annotate the
variable with __init* or __refdata (see linux/init.h) or name the variable:
*_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console,
[...]

Fixed by making mipsnet_probe __devinit.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 drivers/net/mipsnet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mipsnet.c b/drivers/net/mipsnet.c
index 8e9704f..869f0ea 100644
--- a/drivers/net/mipsnet.c
+++ b/drivers/net/mipsnet.c
@@ -247,7 +247,7 @@ static const struct net_device_ops mipsnet_netdev_ops = {
 	.ndo_set_mac_address	= eth_mac_addr,
 };
 
-static int __init mipsnet_probe(struct platform_device *dev)
+static int __devinit mipsnet_probe(struct platform_device *dev)
 {
 	struct net_device *netdev;
 	int err;
