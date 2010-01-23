From: David Miller <davem@davemloft.net>
Subject: Re: Deadlock in IPv6 code while garbage collection on the rwlock
 protecting the routing tree.
Date: Sat, 23 Jan 2010 02:22:10 -0800 (PST)
Message-ID: <20100123.022210.56302976.davem@davemloft.net>
References: <20091222143638.37513a94@nehalam>
	<19250.22271.876068.511246@zeus.eng.starentnetworks.com>
	<20091223101309.08974d02@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: djohnson@starentnetworks.com, sakkiped@starentnetworks.com,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39784
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752151Ab0AWKV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 05:21:58 -0500
In-Reply-To: <20091223101309.08974d02@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 23 Dec 2009 10:13:09 -0800

> With RCU, you can safely acquire a spinlock inside rcu_read_lock
> section.  The only issue is that the entry being modified might already
> be in process of being deleted (ie. modifying a dead route).
> 
> Probably simpler to just get rid of rwlock entirely, go with a spinlock
> for now.  Reader/writer locks are slower than spin locks and even if
> lock is highly read contended, it is not held for long.
> 
> IPV6 routing table is using much simpler algorithms on the assumption
> that IPV6 was going to solve the CIDR address explosion problem. That
> assumption will probably not hold up, and having a trie (TRASH) version
> of IPV6 routing table with RCU would be a good research project for
> some graduate student.

This is all well and good, but meanwhile someone does need to
fix the deadlock originally reported here :-)
