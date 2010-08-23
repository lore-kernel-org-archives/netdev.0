From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] ethtool: allow non-netadmin to query settings
Date: Mon, 23 Aug 2010 13:24:18 -0700
Message-ID: <20100823132418.7721b072@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43125 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753972Ab0HWUYU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Aug 2010 16:24:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SNMP daemon uses ethtool to determine the speed of
network interfaces. This fails on Debian (and probably elsewhere)
because for security SNMP daemon runs as non-root user (snmp).

Note: A similar patch was rejected previously because of a concern about
the possibility that on some hardware querying the ethtool settings
requires access to the PHY and could slow the machine down.  But the
security risk of requiring SNMP daemon (and related services)
to run as root far out weighs the risk of denial-of-service.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/ethtool.c	2010-08-22 11:45:34.680419224 -0700
+++ b/net/core/ethtool.c	2010-08-22 11:46:17.207548950 -0700
@@ -1423,6 +1423,7 @@ int dev_ethtool(struct net *net, struct 
 
 	/* Allow some commands to be done by anyone */
 	switch (ethcmd) {
+	case ETHTOOL_GSET:
 	case ETHTOOL_GDRVINFO:
 	case ETHTOOL_GMSGLVL:
 	case ETHTOOL_GCOALESCE:
