From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [IPv6] "sendmsg: invalid argument" to multicast group after	some time
Date: Tue, 9 Sep 2008 08:05:34 -0700
Message-ID: <OF2C93FA90.E3A61EB0-ON882574BF.0051AE0F-882574BF.0052E85E@us.ibm.com>
References: <20080909100620.GA18584@pest>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org,
	=?ISO-8859-1?Q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
To: Bernhard Schmidt <berni@birkenwald.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:55072 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754513AbYIIPOG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 11:14:06 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m89FE0IF011070
	for <netdev@vger.kernel.org>; Tue, 9 Sep 2008 11:14:00 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m89FDqF81507532
	for <netdev@vger.kernel.org>; Tue, 9 Sep 2008 11:13:53 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m89FDjwa007729
	for <netdev@vger.kernel.org>; Tue, 9 Sep 2008 09:13:50 -0600
In-Reply-To: <20080909100620.GA18584@pest>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bernhard,
        It'll definitely fall back to using the routing table
when the interface is not specified already, which is why
I was ranting about it (I think it should fail without a unicast
routing table lookup in that case, and always require the
application to provide the interface).
        What is odd about your case is you specified
"-I eth0" on the ping6, so it should never be doing a
route lookup (but it also should have a nonzero scope_id).
        That could be a bug in ping6. If it's passing
uninitialized flags to sendmsg, it clearly needs some work.
        Then the question is whether RIPng is explicitly
providing the interface for the sendmsg or not. If it isn't,
that's the problem, but I'd expect it to-- to operate correctly,
it needs to know what interface it's talking on.

                                        +-DLS

