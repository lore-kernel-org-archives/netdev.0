From: Ben Kibbey <bjk@luxsci.net>
Subject: Re: [Bugme-new] [Bug 13589] New: usbnet and /proc/net/dev stats
Date: Mon, 29 Jun 2009 20:42:51 -0400
Message-ID: <200906300045.n5U0j2To004168@rs49.luxsci.com>
References: <bug-13589-10286@http.bugzilla.kernel.org/> <20090629172341.50bce90f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs49.luxsci.com ([65.61.166.75]:51012 "EHLO rs49.luxsci.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751486AbZF3Axo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2009 20:53:44 -0400
Content-Disposition: inline
In-Reply-To: <20090629172341.50bce90f.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 29, 2009 at 05:23:41PM -0700, Andrew Morton wrote:

All usbnet stats weren't getting updated (ifconfig, was always showing 0).
When applied to 2.6.30 this fixes it. Commit 805aaa29fa was the culprit and
reverting it re-adds usbnet_get_stats() but needed to be modified to add whats
in usbnet_netdev_ops:

--- /tmp/usbnet.c	2009-06-29 20:35:59.000000000 -0400
+++ usbnet.c	2009-06-20 11:40:41.000000000 -0400
@@ -1106,9 +1106,16 @@
 }
 EXPORT_SYMBOL_GPL(usbnet_disconnect);
 
+static struct net_device_stats *usbnet_get_stats (struct net_device *net)
+{
+       struct usbnet   *dev = netdev_priv(net);
+       return &dev->stats;
+}
+
 static const struct net_device_ops usbnet_netdev_ops = {
 	.ndo_open		= usbnet_open,
 	.ndo_stop		= usbnet_stop,
+	.ndo_get_stats		= usbnet_get_stats,
 	.ndo_start_xmit		= usbnet_start_xmit,
 	.ndo_tx_timeout		= usbnet_tx_timeout,
 	.ndo_change_mtu		= usbnet_change_mtu,

-- 
Ben Kibbey (bjk) @ FreeNode/OFTC/Jabber
