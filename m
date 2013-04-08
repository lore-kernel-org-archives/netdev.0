From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK
 packet
Date: Mon, 08 Apr 2013 17:33:25 -0400 (EDT)
Message-ID: <20130408.173325.1683493727549657170.davem@davemloft.net>
References: <3505145.vfXt1x4t0P@sifl>
	<20130408.171512.973275376690340387.davem@davemloft.net>
	<2921619.mqaHl5PnPI@sifl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	mvadkert@redhat.com, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org
To: pmoore@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53281 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965085Ab3DHVd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 17:33:27 -0400
In-Reply-To: <2921619.mqaHl5PnPI@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <pmoore@redhat.com>
Date: Mon, 08 Apr 2013 17:24:50 -0400

> If the void pointer is wrapped by a #ifdef (plenty of precedence for that) and 
> the management of that pointer is handled by LSM hooks why is it a concern?  I 
> apologize for pushing on the issue, but I'm having a hard time reconciling the 
> reason for the "no" with the comments/decisions about the regression fix; at 
> present there seems to be a level of contradiction between the two.

8 bytes times however many millions of packets per second we can process
on a big machine, you do the math.

It's memory, less cache locality, etc. etc. etc.

It's the most important data structure in the entire networking stack,
and every single byte matters.

I want the overhead to be your problem, so that only users of your
stuff eat the overhead, rather than everyone.

And don't even mention ifdefs, that's bogus, because every
distribution turns every option on, %99.9999999 of users will
therefore not see the savings.

Really, this is a dead topic, let's move on.

Thanks.
