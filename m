From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] via-velocity: don't oops on MTU change.
Date: Wed, 14 Nov 2007 19:38:44 -0800
Message-ID: <20071114193844.0cab5c7d@freepuppy.rosehill>
References: <bug-9382-10286@http.bugzilla.kernel.org/>
	<20071114192319.e9423144.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jnelson-kernel-bugzilla@jamponi.net
To: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52357 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755515AbXKODlC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 22:41:02 -0500
In-Reply-To: <20071114192319.e9423144.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simple mtu change when device is down.
Fix http://bugzilla.kernel.org/show_bug.cgi?id=9382.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/via-velocity.c	2007-10-22 09:38:11.000000000 -0700
+++ b/drivers/net/via-velocity.c	2007-11-14 19:34:30.000000000 -0800
@@ -1963,6 +1963,11 @@ static int velocity_change_mtu(struct ne
 		return -EINVAL;
 	}
 
+	if (!netif_running(dev)) {
+		dev->mtu = new_mtu;
+		return 0;
+	}
+
 	if (new_mtu != oldmtu) {
 		spin_lock_irqsave(&vptr->lock, flags);
 
