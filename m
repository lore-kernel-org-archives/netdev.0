From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/7] Ipv6 TCP timewait recycling support
Date: Thu, 02 Dec 2010 12:41:58 -0800 (PST)
Message-ID: <20101202.124158.71109616.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37731
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757253Ab0LBUlc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 15:41:32 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B191C24C088
	for <netdev@vger.kernel.org>; Thu,  2 Dec 2010 12:41:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


First we start with two simple cleanups, un-typedef'ification
and a comment fixup.

Then we add the infrastructure to allow the tcp_minisocks.c
timewait recycling code able to be generic and use various
->ops

Sadly, the ipv6 timewait ops are used even for v4-mapped
addresses so we need a special check in the ipv6 timewait
getpeer implementation.  This is similar to the situation
we have in tcp_v6_hash().

Doing these changes also pointed out that our listening socket
incoming connection policy in the non-syncookies case as
being handled differently for ipv4 vs. ipv6.  This has been
rectified.  The issue is that for ipv4 we were reserving the
final 1/4 of the backlog queue to validated destinations.

In the final patch we throw the switch and implement the two
getpeer operations for ipv6, which fully enables timewait
recyling for ipv6.
