From: Tom Goff <thomas.goff@boeing.com>
Subject: [PATCH] netlink: use the appropriate namespace pid
Date: Fri, 19 Mar 2010 18:38:50 -0700
Message-ID: <20100320013850.GA13239@boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stl-smtpout-01.boeing.com ([130.76.96.56]:53862 "EHLO
	stl-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752157Ab0CTCDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 22:03:30 -0400
Received: from slb-av-01.boeing.com (slb-av-01.boeing.com [129.172.13.4])
	by stl-smtpout-01.ns.cs.boeing.com (8.14.4/8.14.4/8.14.4/SMTPOUT) with ESMTP id o2K1cqRQ023556
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Fri, 19 Mar 2010 20:38:58 -0500 (CDT)
Received: from slb-av-01.boeing.com (localhost [127.0.0.1])
	by slb-av-01.boeing.com (8.14.4/8.14.4/DOWNSTREAM_RELAY) with ESMTP id o2K1cq1r010729
	for <netdev@vger.kernel.org>; Fri, 19 Mar 2010 18:38:52 -0700 (PDT)
Received: from packet.blv.boeing.com (packet.blv.boeing.com [130.42.97.136])
	by slb-av-01.boeing.com (8.14.4/8.14.4/UPSTREAM_RELAY) with SMTP id o2K1cpBA010724
	for <netdev@vger.kernel.org>; Fri, 19 Mar 2010 18:38:51 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was included in OpenVZ kernels but wasn't integrated upstream.
>From git://git.openvz.org/pub/linux-2.6.24-openvz:

	commit 5c69402f18adf7276352e051ece2cf31feefab02
	Author: Alexey Dobriyan <adobriyan@openvz.org>
	Date:   Mon Dec 24 14:37:45 2007 +0300

	    netlink: fixup ->tgid to work in multiple PID namespaces

Signed-off-by: Tom Goff <thomas.goff@boeing.com>
---
 net/netlink/af_netlink.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 320d042..b5ac0cd 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -545,7 +545,7 @@ static int netlink_autobind(struct socket *sock)
 	struct hlist_head *head;
 	struct sock *osk;
 	struct hlist_node *node;
-	s32 pid = current->tgid;
+	s32 pid = task_tgid_vnr(current);
 	int err;
 	static s32 rover = -4097;
 
-- 
1.6.3.3

