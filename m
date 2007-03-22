From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Recent net-2.6.22 patches break bootup!
Date: Fri, 23 Mar 2007 00:47:04 +0100
Message-ID: <20070322234704.GA521@postel.suug.ch>
References: <20070322125955.055083236@lsx.localdomain> <20070322.120619.71102556.davem@davemloft.net> <20070322142753.52fec3ca@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56582 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752769AbXCVXqn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 19:46:43 -0400
Content-Disposition: inline
In-Reply-To: <20070322142753.52fec3ca@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Stephen Hemminger <shemminger@linux-foundation.org> 2007-03-22 14:27
> Something is broken now.  If I boot the system (Fedora) it gets to:
> 
> Bringing up loopback interface:  RTNETLINK answers: Invalid argument
> Dump terminated
> RTNETLINK answers: Invalid argument
> ....
> 
> tg3 device eth0 does not seem to be present, delaying initialization
> 
> 
> then it hangs because cups won't come up without loopback

Thinko. It always returned the first message handler of a rtnl
family.

[RTNL]: Properly return rntl message handler

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/net/core/rtnetlink.c
===================================================================
--- net-2.6.22.orig/net/core/rtnetlink.c	2007-03-23 00:31:37.000000000 +0100
+++ net-2.6.22/net/core/rtnetlink.c	2007-03-23 00:32:52.000000000 +0100
@@ -122,10 +122,10 @@ static rtnl_doit_func rtnl_get_doit(int 
 	struct rtnl_link *tab;
 
 	tab = rtnl_msg_handlers[protocol];
-	if (tab == NULL || tab->doit == NULL)
+	if (tab == NULL || tab[msgindex].doit == NULL)
 		tab = rtnl_msg_handlers[PF_UNSPEC];
 
-	return tab ? tab->doit : NULL;
+	return tab ? tab[msgindex].doit : NULL;
 }
 
 static rtnl_dumpit_func rtnl_get_dumpit(int protocol, int msgindex)
@@ -133,10 +133,10 @@ static rtnl_dumpit_func rtnl_get_dumpit(
 	struct rtnl_link *tab;
 
 	tab = rtnl_msg_handlers[protocol];
-	if (tab == NULL || tab->dumpit == NULL)
+	if (tab == NULL || tab[msgindex].dumpit == NULL)
 		tab = rtnl_msg_handlers[PF_UNSPEC];
 
-	return tab ? tab->dumpit : NULL;
+	return tab ? tab[msgindex].dumpit : NULL;
 }
 
 /**
