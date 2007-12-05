From: David Miller <davem@davemloft.net>
Subject: TCP event tracking via netlink...
Date: Wed, 05 Dec 2007 05:30:31 -0800 (PST)
Message-ID: <20071205.053031.87154402.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60668
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751160AbXLENac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 08:30:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ilpo, I was pondering the kind of debugging one does to find
congestion control issues and even SACK bugs and it's currently too
painful because there is no standard way to track state changes.

I assume you're using something like carefully crafted printk's,
kprobes, or even ad-hoc statistic counters.  That's what I used to do
:-)

With that in mind it occurred to me that we might want to do something
like a state change event generator.

Basically some application or even a daemon listens on this generic
netlink socket family we create.  The header of each event packet
indicates what socket the event is for and then there is some state
information.

Then you can look at a tcpdump and this state dump side by side and
see what the kernel decided to do.

Now there is the question of granularity.

A very important consideration in this is that we want this thing to
be enabled in the distributions, therefore it must be cheap.  Perhaps
one test at the end of the packet input processing.

So I say we pick some state to track (perhaps start with tcp_info)
and just push that at the end of every packet input run.  Also,
we add some minimal filtering capability (match on specific IP
address and/or port, for example).

Maybe if we want to get really fancy we can have some more-expensive
debug mode where detailed specific events get generated via some
macros we can scatter all over the place.  This won't be useful
for general user problem analysis, but it will be excellent for
developers.

Let me know if you think this is useful enough and I'll work on
an implementation we can start playing with.
