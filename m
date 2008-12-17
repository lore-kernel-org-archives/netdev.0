From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Bonding gigabit and fast?
Date: Tue, 16 Dec 2008 20:48:55 -0800
Message-ID: <20484.1229489335@death.nxdomain.ibm.com>
References: <200812161939.30033.tvrtko@ursulin.net> <200812162012.29811.tvrtko@ursulin.net> <4948119B.5050000@redhat.com> <200812162255.47731.tvrtko@ursulin.net>
Cc: Chris Snook <csnook@redhat.com>, netdev@vger.kernel.org
To: "Tvrtko A. Ursulin" <tvrtko@ursulin.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:48351 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212AbYLQEs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 23:48:58 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e38.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mBH4ljaD007635
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 21:47:45 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mBH4mvfe226834
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 21:48:57 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mBH4mutp006785
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 21:48:57 -0700
In-reply-to: <200812162255.47731.tvrtko@ursulin.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tvrtko A. Ursulin <tvrtko@ursulin.net> wrote:
[...]
>I was using balance-rr, alb flavour does not seem to like 8139too.

	The choice of balance-rr may be half of your problem.  Try
balance-xor with xmit_hash_policy=layer3+4, it may behave better.  That
mode doesn't know about dissimilar speed slaves, so it simply balances
by math, but that still may behave better than balance-rr because it
won't stripe single connections across slaves.

	The balance-alb mode would likely be better (it's smarter about
balancing across slaves of differing speeds), but requires that the
slaves be able to change MAC address while up, which not every device is
capable of doing.

	To elaborate a bit on balance-rr, it will usually cause out of
order delivery to varying degrees, which in turn causes TCP's congestion
control and/or fast retransmits to kick in.  The effect can be mitigated
to some degree (but not eliminated) by raising the value of the
net.ipv4.tcp_reordering sysctl.  If memory serves, values more than
about 125 don't make much additional difference.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
