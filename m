From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] IPv4 Multicast: prevent reception of mcast frames from	unjoined
 groups
Date: Fri, 11 Jul 2008 10:53:01 -0700
Message-ID: <OFE508C572.3640A61A-ON88257483.0061886C-88257483.00623A05@us.ibm.com>
References: <20080711173125.GB4534@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, jmorris@namei.org, kaber@trash.net,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	netdev@vger.kernel.org, pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:42056 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753295AbYGKRxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2008 13:53:15 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m6BHr4VY020776
	for <netdev@vger.kernel.org>; Fri, 11 Jul 2008 13:53:04 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6BHr4q0104758
	for <netdev@vger.kernel.org>; Fri, 11 Jul 2008 11:53:04 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6BHr3bX011888
	for <netdev@vger.kernel.org>; Fri, 11 Jul 2008 11:53:04 -0600
In-Reply-To: <20080711173125.GB4534@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> currently in ip_mc_sf_allow we assume that we need to allow the frame if 
no
> match is found, but that has the affect of causing frames to be received 
for
> groups a socket hasn't joined.  I asked david aobut this specifically.

        You asked me about this? Or the other David? :-) I don't remember
seeing anything on this-- at least not recently.

        But in the sentence above, I think you missed the point of the
mail I sent before. Joining a group or not on a particular socket has
nothing at all to do with delivery of multicasts to the socket.

        Multicast addresses, like unicast addresses, are for the entire
machine, not just the socket that does the join. If anyone on the
machine has joined the group and your binding matches the packet, you
will receive a copy. That's intentional. If you don't join any groups
at all, but bind to INADDR_ANY, you will receive packets for the port
and protocol and any local unicast or multicast address (including
groups joined by any other process on the machine).

 +-DLS

