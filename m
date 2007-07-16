From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: kernel module to list sockets with their multicast group joins and
 respective processes
Date: Mon, 16 Jul 2007 13:18:39 -0700
Message-ID: <OF57FAD1F9.00750CDD-ON8825731A.006E33C6-8825731A.006F814B@us.ibm.com>
References: <Pine.LNX.4.64.0707162029430.952@nettc.informatik.uni-stuttgart.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org,
	Steffen Maier <smaier@users.sourceforge.net>
To: Steffen Maier <smaier@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:34068 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757281AbXGPUSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 16:18:44 -0400
In-Reply-To: <Pine.LNX.4.64.0707162029430.952@nettc.informatik.uni-stuttgart.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> sockets that join different groups receive messages from the respective 
> other group (if they are only bound to the wildcard address). Obviously 
> this is handled differently in Linux for IPv4, where the socket matching 

> for incoming message is done solely on the 4-tuple of addresses and 
ports, 
> and IPv6, where the explicit socket joins are taken into account [1,2]. 

        These are not different in v4 vs v6. Group membership is 
per-interface,
delivery depends on the binding (for both v4 and v6), and this is the same
as BSD behavior since IP multicasting was invented.
        There are two levels of checks, and I think you're confusing them.
inet6_mc_check() is checking that somebody (*anybody*) has joined the
group on the receiving interface, before delivering the packet to IP.
Delivery to a particular socket depends on source filter settings, if
they are in use, and bindings (only). The socket has a list of joined
addresses to track source filters and to check for correct join/leave
(a socket can't leave a group it hasn't joined), but that list does not
determine delivery of a multicast packet to the socket when source 
filtering
is not in use.
 +-DLS



