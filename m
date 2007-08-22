From: Thomas Graf <tgraf@suug.ch>
Subject: Re: net-2.6.24 failure with netconsole
Date: Wed, 22 Aug 2007 12:39:09 +0200
Message-ID: <20070822103909.GQ32236@postel.suug.ch>
References: <20070821225438.9493f44c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56374 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752957AbXHVKit (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 06:38:49 -0400
Content-Disposition: inline
In-Reply-To: <20070821225438.9493f44c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Andrew Morton <akpm@linux-foundation.org> 2007-08-21 22:54
> Which used to be a BUG.  It later oopsed via a null-pointer deref in
> net_rx_action(), which is a much preferable result.

I fixed this already

Index: net-2.6.24/include/linux/netpoll.h
===================================================================
--- net-2.6.24.orig/include/linux/netpoll.h	2007-08-22 01:02:14.000000000 +0200
+++ net-2.6.24/include/linux/netpoll.h	2007-08-22 01:02:30.000000000 +0200
@@ -75,7 +75,7 @@ static inline void *netpoll_poll_lock(st
 	struct net_device *dev = napi->dev;
 
 	rcu_read_lock(); /* deal with race on ->npinfo */
-	if (dev->npinfo) {
+	if (dev && dev->npinfo) {
 		spin_lock(&napi->poll_lock);
 		napi->poll_owner = smp_processor_id();
 		return napi;
