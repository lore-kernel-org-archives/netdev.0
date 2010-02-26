From: Patrick McHardy <kaber@trash.net>
Subject: net 01/04: rtnetlink: ignore NETDEV_PRE_UP notifier in rtnetlink_event()
Date: Fri, 26 Feb 2010 17:34:50 +0100 (MET)
Message-ID: <20100226163450.11434.29192.sendpatchset@x2.localnet>
References: <20100226163449.11434.13013.sendpatchset@x2.localnet>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59362 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965325Ab0BZQev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 11:34:51 -0500
In-Reply-To: <20100226163449.11434.13013.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 140dcbaa692be4ce66e68624d438aed030184186
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Feb 23 20:56:39 2010 +0100

    net: rtnetlink: ignore NETDEV_PRE_UP notifier in rtnetlink_event()
    
    Commit 3b8bcfd (net: introduce pre-up netdev notifier) added a new
    notifier which is run before a device is set UP for use by cfg80211.
    
    The patch missed to add the new notifier to the ignore list in
    rtnetlink_event(), so we currently get an unnecessary netlink
    notification before a device is set UP.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 4dd4c3c..b7c7dfd 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1432,6 +1432,7 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_DOWN:
 		rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING);
 		break;
+	case NETDEV_PRE_UP:
 	case NETDEV_POST_INIT:
 	case NETDEV_REGISTER:
 	case NETDEV_CHANGE:
