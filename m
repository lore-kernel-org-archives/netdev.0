From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] ipv6 addrconf: Ignore requests to set NODAD flag when changing addresses
Date: Thu, 5 Jun 2008 01:47:51 +0200
Message-ID: <20080604234751.GH20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:60295 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759184AbYFDXrb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2008 19:47:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The decision to run DAD has already been made at the time the address
was added. Changing the flag later on does not have any effect and
is only confusing.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/net/ipv6/addrconf.c
===================================================================
--- net-2.6.orig/net/ipv6/addrconf.c	2008-06-04 22:57:41.000000000 +0200
+++ net-2.6/net/ipv6/addrconf.c	2008-06-04 22:59:11.000000000 +0200
@@ -3200,7 +3200,7 @@
 	}
 
 	spin_lock_bh(&ifp->lock);
-	ifp->flags = (ifp->flags & ~(IFA_F_DEPRECATED | IFA_F_PERMANENT | IFA_F_NODAD | IFA_F_HOMEADDRESS)) | ifa_flags;
+	ifp->flags = (ifp->flags & ~(IFA_F_DEPRECATED | IFA_F_PERMANENT | IFA_F_HOMEADDRESS)) | ifa_flags;
 	ifp->tstamp = jiffies;
 	ifp->valid_lft = valid_lft;
 	ifp->prefered_lft = prefered_lft;
@@ -3267,6 +3267,9 @@
 				      preferred_lft, valid_lft);
 	}
 
+	/* It's too late to disable DOD now, ignore the flag */
+	ifa_flags &= ~IFA_F_NODAD;
+
 	if (nlh->nlmsg_flags & NLM_F_EXCL ||
 	    !(nlh->nlmsg_flags & NLM_F_REPLACE))
 		err = -EEXIST;
