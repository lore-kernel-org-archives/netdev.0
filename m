From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next] ethtool: Make more commands available to
 unprivileged processes
Date: Wed, 13 Jun 2012 00:05:41 +0100
Message-ID: <1339542341.15266.3.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:52698 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751847Ab2FLXF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 19:05:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'Get' commands should generally not require CAP_NET_ADMIN, with
the exception of those that expose internal state.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
The one command I'm not sure about is ETHTOOL_STATS.  It might reveal
too much detail about network traffic.  That said, /proc/net/dev and
/sys/class/net/*/statistics are already world-readable.

Ben.

 net/core/ethtool.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index c73d0a5..cbf033d 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1443,6 +1443,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GSET:
 	case ETHTOOL_GDRVINFO:
 	case ETHTOOL_GMSGLVL:
+	case ETHTOOL_GLINK:
 	case ETHTOOL_GCOALESCE:
 	case ETHTOOL_GRINGPARAM:
 	case ETHTOOL_GPAUSEPARAM:
@@ -1451,6 +1452,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GSG:
 	case ETHTOOL_GSSET_INFO:
 	case ETHTOOL_GSTRINGS:
+	case ETHTOOL_GSTATS:
 	case ETHTOOL_GTSO:
 	case ETHTOOL_GPERMADDR:
 	case ETHTOOL_GUFO:
@@ -1463,8 +1465,11 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GRXCLSRLCNT:
 	case ETHTOOL_GRXCLSRULE:
 	case ETHTOOL_GRXCLSRLALL:
+	case ETHTOOL_GRXFHINDIR:
 	case ETHTOOL_GFEATURES:
+	case ETHTOOL_GCHANNELS:
 	case ETHTOOL_GET_TS_INFO:
+	case ETHTOOL_GEEE:
 		break;
 	default:
 		if (!capable(CAP_NET_ADMIN))
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
