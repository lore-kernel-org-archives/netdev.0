From: Simon Paillard <simon.paillard@resel.enst-bretagne.fr>
Subject: should kernel IGMP rejoin on link up ?
Date: Tue, 4 Sep 2012 14:19:48 +0200
Message-ID: <20120904121948.GJ11825@glenfiddich.mraw.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from glenfiddich.mraw.org ([88.191.124.82]:37828 "EHLO
	glenfiddich.mraw.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757046Ab2IDNEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 09:04:36 -0400
Received: from spaillard by glenfiddich.mraw.org with local (Exim 4.72)
	(envelope-from <simon.paillard@resel.enst-bretagne.fr>)
	id 1T8s6e-0000Cj-TR
	for netdev@vger.kernel.org; Tue, 04 Sep 2012 14:19:48 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Here is a scenario where IMO the kernel is not doing the job, where a host
running linux kernel is connected to a switch with igmp snooping enabled:
- nominal case: an interface is member of a multicast group, reports are
  performed 
- failure of link (like cable disconnected)
- the switch flushes the multicast membership for that port
- link is back
- kernel waits for switch query to report membership

-> The application miss packets until next General Query (default value in RFC:
125 seconds)

I cannot find in IGMPv2 RFC a specification of the behaviour to follow in such
a case, but :
- having a very little query interval would affect all the network, and polling
  is not a clean way. 
- it's imo not the application job to check for link failure and issue again
  joins

So I wonder if the kernel should rejoin when interface link flag is up
(ip_mc_rejoin_groups() is already used by bonding code when a new interface is
up).

The next question, if you agree that should be the kernel job, is where the fix
should be located.

Thanks.

PS: I know little about MLD in IPv6, I didn't see in bonding code something
related to MLD, but I guess the same question applies.

(Please CC me on replies)

-- 
Simon Paillard
