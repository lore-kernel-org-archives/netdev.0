From: Matthew Wilcox <willy@debian.org>
Subject: [PATCH] ethtool_ops bug
Date: Wed, 27 Aug 2003 16:56:02 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030827155602.GD22294@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


C's switch statements need breaks.  I know that.

Index: net/core/ethtool.c
===================================================================
RCS file: /var/cvs/linux-2.6/net/core/ethtool.c,v
retrieving revision 1.1
diff -u -p -r1.1 ethtool.c
--- net/core/ethtool.c	23 Aug 2003 02:47:29 -0000	1.1
+++ net/core/ethtool.c	27 Aug 2003 15:55:03 -0000
@@ -502,15 +502,15 @@ static int ethtool_get_strings(struct ne
 
 	switch (gstrings.string_set) {
 	case ETH_SS_TEST:
-		if (ops->self_test_count)
-			gstrings.len = ops->self_test_count(dev);
-		else
+		if (!ops->self_test_count)
 			return -EOPNOTSUPP;
+		gstrings.len = ops->self_test_count(dev);
+		break;
 	case ETH_SS_STATS:
-		if (ops->get_stats_count)
-			gstrings.len = ops->get_stats_count(dev);
-		else
+		if (!ops->get_stats_count)
 			return -EOPNOTSUPP;
+		gstrings.len = ops->get_stats_count(dev);
+		break;
 	default:
 		return -EINVAL;
 	}

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
