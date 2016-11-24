From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: [PATCH] net: ethtool: don't require CAP_NET_ADMIN for ETHTOOL_GLINKSETTINGS
Date: Thu, 24 Nov 2016 10:55:06 +0100
Message-ID: <20161124095506.25791-1-mlichvar@redhat.com>
Cc: David Decotigny <decot@googlers.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39542 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964839AbcKXJzc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Nov 2016 04:55:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ETHTOOL_GLINKSETTINGS command is deprecating the ETHTOOL_GSET
command and likewise it shouldn't require the CAP_NET_ADMIN capability.

Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>
---
 net/core/ethtool.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 9774898..047a175 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -2479,6 +2479,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GET_TS_INFO:
 	case ETHTOOL_GEEE:
 	case ETHTOOL_GTUNABLE:
+	case ETHTOOL_GLINKSETTINGS:
 		break;
 	default:
 		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
-- 
2.9.3
