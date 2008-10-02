From: Pekka Savola <pekkas@netcore.fi>
Subject: Neighbor Discovery from non-neighbors (fwd)
Date: Thu, 2 Oct 2008 11:07:48 +0300 (EEST)
Message-ID: <alpine.LRH.2.00.0810021048040.11598@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:52448 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752318AbYJBIH6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2008 04:07:58 -0400
Received: from netcore.fi (localhost [127.0.0.1])
	by netcore.fi (8.13.8/8.13.8) with ESMTP id m9287njE014471
	for <netdev@vger.kernel.org>; Thu, 2 Oct 2008 11:07:49 +0300
Received: from localhost (pekkas@localhost)
	by netcore.fi (8.13.8/8.13.8/Submit) with ESMTP id m9287mP1014467
	for <netdev@vger.kernel.org>; Thu, 2 Oct 2008 11:07:48 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a bug in the Neighbor Discovery spec, and it's possible that 
Linux would also be similarly affected.  Anyone check?

For background discussion see: 
http://www.ietf.org/mail-archive/web/ipv6/current/msg09544.html

---------- Forwarded message ----------
Date: Thu, 2 Oct 2008 10:08:07 +0300 (EEST)
From: Pekka Savola <pekkas@netcore.fi>
To: ipv6@ietf.org
Subject: Neighbor Discovery from non-neighbors

FYI,

http://security.freebsd.org/advisories/FreeBSD-SA-08:10.nd6.asc

"IPv6 routers may allow "on-link" IPv6 nodes to create and update the router's 
neighbor cache and forwarding information.  A malicious IPv6 node sharing a 
common router but on a different physical segment from another node may be able 
to spoof Neighbor Discovery messages, allowing it to update router information 
for the victim node."
...

"NOTE WELL: The solution described below causes IPv6 Neighbor Discovery 
Neighbor Solicitation messages from non-neighbors to be ignored. This can be 
re-enabled if required by setting the newly added 
net.inet6.icmp6.nd6_onlink_ns_rfc4861 sysctl to a non-zero value."

+		/*
+		 * According to recent IETF discussions, it is not a good idea
+		 * to accept a NS from an address which would not be deemed
+		 * to be a neighbor otherwise.  This point is expected to be
+		 * clarified in future revisions of the specification.
+		 */

I wonder if off-list discussion qualifies as "IETF discussion".  Or has this 
been raised on a list somewhere?

http://www.freebsd.org/cgi/cvsweb.cgi/src/sys/netinet6/nd6_nbr.c.diff?r1=1.52;r2=1.53

I guess we have a problem.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
--------------------------------------------------------------------
IETF IPv6 working group mailing list
ipv6@ietf.org
Administrative Requests: https://www.ietf.org/mailman/listinfo/ipv6
--------------------------------------------------------------------
