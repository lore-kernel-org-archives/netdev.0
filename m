From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Subject: Re: [PATCH 1/4] Restore multicast settings on resume
Date: Sun, 18 May 2008 15:00:36 +0200
Message-ID: <20080518130035.GA21417@yamamaya.is-a-geek.org>
References: <20080518125715.GA19229@yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yumi.tdiedrich.de ([85.10.210.183]:33235 "EHLO mx.tdiedrich.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754799AbYERNBJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 May 2008 09:01:09 -0400
Content-Disposition: inline
In-Reply-To: <20080518125715.GA19229@yamamaya.is-a-geek.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Diedrich <ranma+kernel@tdiedrich.de>

nv_open() resets multicast settings, call nv_set_multicast(dev) to restore them.
(Maybe this should rather be moved into nv_open())

Signed-off-by: Tobias Diedrich <ranma+kernel@tdiedrich.de>

Index: linux-2.6.26-rc2.forcedwol/drivers/net/forcedeth.c
===================================================================
--- linux-2.6.26-rc2.forcedwol.orig/drivers/net/forcedeth.c	2008-05-18 13:52:59.000000000 +0200
+++ linux-2.6.26-rc2.forcedwol/drivers/net/forcedeth.c	2008-05-18 13:53:02.000000000 +0200
@@ -5823,6 +5823,7 @@
 	writel(txreg, base + NvRegTransmitPoll);
 
 	rc = nv_open(dev);
+	nv_set_multicast(dev);
 out:
 	return rc;
 }
