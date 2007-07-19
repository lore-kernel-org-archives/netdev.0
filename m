From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC 0/3] TCP congestion control RTT patches
Date: Thu, 19 Jul 2007 08:41:29 +0100
Message-ID: <20070719074129.670215301@linux-foundation.org>
Cc: Sangtae Ha <sha2@ncsu.edu>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42162 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763075AbXGSIYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 04:24:32 -0400
Cc: Luca De Cicco <ldecicco@gmail.com>
Cc: Gavin McCullagh <gavin.mccullagh@nuim.ie>
Cc: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches deal with issues brought up by Gavin McCullagh
about reactions of Cubic and HTCP to hostile receivers that return
bogus timestamp options. In a couple of places the timestamp value
is used in ways that could cause unfairness.

The solution in these patches is to only use local values to measure
RTT for congestion control.  The timestamp is still used as described
in RFC's to measure RTT used for retransmit timer.

This code is preliminary and not throughly tested yet. It could
be backported to 2.6.22 for stable kernels, but it would be hard to
go back to earlier kernels because it builds on the recent TCP congestion
control API changes.

-- 

