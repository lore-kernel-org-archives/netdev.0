From: Ariane Keller <ariane.keller@tik.ee.ethz.ch>
Subject: Re: [PATCH 0/2] netem: trace enhancement
Date: Tue, 04 Dec 2007 15:45:35 +0100
Message-ID: <20071204154535.4eu35nfe9wks8kgg@email.ee.ethz.ch>
References: <20071120231131.oqn4s5eda84k4csw@email.ee.ethz.ch>
	<474C2246.50205@ee.ethz.ch> <20071129134554.5c25a891@freepuppy.rosehill>
	<474F3719.30101@trash.net> <47503971.9080509@ee.ethz.ch>
	<4753B423.7030000@trash.net> <4753C874.80703@ee.ethz.ch>
	<47543E65.4060303@trash.net> <47544B1F.1010902@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=UTF-8;
	format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Ariane Keller <ariane.keller@tik.ee.ethz.ch>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Rainer Baumann <baumann@tik.ee.ethz.ch>
To: Ben Greear <greearb@candelatech.com>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ee.ethz.ch ([129.132.2.219]:33994 "EHLO smtp.ee.ethz.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752929AbXLDOph (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 09:45:37 -0500
In-Reply-To: <47544B1F.1010902@candelatech.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>> That sounds like it would also be possible using rtnetlink. You could
>> send out a notification whenever you switch the active buffer and have
>> userspace listen to these and replace the inactive one.

I guess using rtnetlink is possible. However I'm not sure about how to 
implement it:
The first thought was to use RTM_NEWQDISC to send the data to the 
netem_change() function (similar to tc_qdisc_modify() ). But with this 
we would need the tcm_handle, tcm_parent arguments etc. which are not 
known in q_netem.c
Therefore we would have to change the parse_qopt() function prototype 
in order to pass the whole "req" and not only the nlmsghdr.

The second possibility would be to add a new message type, e.g 
RTM_NETEMDATA. This type would be registered in the netem kernel module 
with a callback function netem_recv_data(). If this function receives 
some data it searches for the correct flow, and saves the data in the 
corresponding buffer.

However, I'm not convinced of any of these options. Do you have an 
alternative suggestion?


> Also, I think you will need a larger cache than 4-8k if you are 
> running higher speeds (100,000 pps, etc),
> as you probably can't rely on user-space responding reliably every 
> 10ms (or even less time for faster
> speeds.)

Increasing the cache size to say 32k for each buffer would be no problem.
Is this enough?



