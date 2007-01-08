From: Brendan Cully <brendan@kublai.com>
Subject: Re: Question on advanced routing and/or virtual routers.
Date: Mon, 8 Jan 2007 10:23:27 -0800
Message-ID: <20070108182327.GB19417@ventoux.cs.ubc.ca>
References: <45A27A78.8010200@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zakopane.cs.ubc.ca ([198.162.52.68]:42248 "EHLO
	mail.quuxuum.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161344AbXAHSpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jan 2007 13:45:52 -0500
Received: from zakopane.cs.ubc.ca (localhost.localdomain [127.0.0.1])
	by mail.quuxuum.com (Postfix) with ESMTP id 8DC745C340
	for <netdev@vger.kernel.org>; Mon,  8 Jan 2007 10:23:28 -0800 (PST)
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <45A27A78.8010200@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, 08 January 2007 at 09:08, Ben Greear wrote:
> Hello!
> 
> I am curious if a single machine can be made to look like several 
> routers.  Please consider the following
> configuration:
> 
> Linux Router-A has 4 ethernet interfaces.  PC-A is connected to eth0 and 
> has IP 192.168.0.2.
> eth0 on Router-A has IP 192.168.0.1/24
> eth1 has IP 192.168.1.1/24, and eth1 is connected directly to eth2
> eth2 has IP 192.168.2.1/24
> eth3 is connected 'upstream' and has IP 192.168.3.1/24
> 
> I would like for PC-A to be able to ping 192.168.0.1 and 192.168.1.1 as 
> normal.
> The part I'm not sure how to make work is that I want to be able to ping 
> 192.168.2.1 and
> have the packet route out of eth1 and into eth2 (PC-A -> eth0 -> eth1 -> 
> eth2), and have the return packet follow the
> eth2 -> eth1 -> eth0 -> PC-A path.  A trace-route from PC-A should show 
> each of these hops (or, at least eth0 and eth2.)
> 
> The eventual goal is to have arbitrary numbers of 'routers' in a single 
> Linux machine for emulation
> purposes.
> 
> I was thinking that I might could accomplish this using multiple routing 
> tables and perhaps
> specific subnet routes for each each virtual router, specifying which 
> interface the packets should
> leave in order to find the next hop.
> 
> Has anyone tried something similar to this or have ideas for how to best 
> proceed?

I started something like this a while ago (posted at
<20051006215312.GD24375@zakopane.cs.ubc.ca> with a couple of replies
by Thomas Graf, but I can't seem to find it in the archives) but then
dropped the ball. It seems to work fairly well with a one-line kernel
patch to allow route lookup before the local address check. Oh, and I
didn't get traceroute working quite right either - I think there was
some trick to finding the source address for the generated reply.

I've got some info and code here: http://dsg.cs.ubc.ca/~brendan/remus/
