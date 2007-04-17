From: Sebastian Kuzminsky <seb@highlab.com>
Subject: Re: bug in tcp?
Date: Tue, 17 Apr 2007 07:56:26 -0600
Message-ID: <E1HdoAU-0001Ao-T8@highlab.com>
References: <E1HdZgM-0001n2-F0@highlab.com> <462450C5.5080702@snapgear.com> <E1HdgLb-0005eU-Ji@highlab.com> <46246572.9020108@snapgear.com>
Cc: netdev@vger.kernel.org, Sebastian Kuzminsky <seb@highlab.com>
To: Philip Craig <philipc@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alnrmhc14.comcast.net ([206.18.177.54]:33546 "EHLO
	alnrmhc14.comcast.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754396AbXDQOBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 10:01:52 -0400
In-reply-to: <46246572.9020108@snapgear.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Philip Craig <philipc@snapgear.com> wrote:
> Sebastian Kuzminsky wrote:
> > Weird.  Why does sending a message from the client make it go again?
> 
> The rule that allows packets with an "ESTABLISHED" state only matches
> packets for which the connection is in netfilter's conntrack table.
> The connection is removed from the table after the 5 days of idle.
> It is only added again if netfilter accepts a packet for that connection.
> So the packet from the client will cause it to be added.

Why did the packet from the client cause the connection to be added back
to the conntrack table, but the packet from the server did not?


> > How do people normally handle this?
> 
> Change the timeout or use keepalives.  I can't think of any other way.
> The 5 days is a compromise between keeping valid connections and
> timing out dead connections.  There will always be connections for
> which it times out too fast or too slow.  I don't think there are
> any drawbacks to increasing the timeout if you aren't a router,
> but as long as there is a timeout, you need keepalives to be sure.

Thanks!  I'll add keepalives and rerun the tests, and I expect the
problem to go away.


-- 
Sebastian Kuzminsky
