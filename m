From: Thomas Graf <tgraf@suug.ch>
Subject: [NET]: Don't do netpoll on per cpu backlog napi struct
Date: Wed, 22 Aug 2007 01:08:51 +0200
Message-ID: <20070821230851.GP32236@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:55219 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751383AbXHUXIb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2007 19:08:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The per cpu backlog napi struct can't do netpoll and has the
dev member set to NULL. Fixes an oops on boot when netpoll is
enabled.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

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
