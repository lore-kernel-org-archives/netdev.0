From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/2] netem: trace enhancement
Date: Mon, 03 Dec 2007 18:35:33 +0100
Message-ID: <47543E65.4060303@trash.net>
References: <20071120231131.oqn4s5eda84k4csw@email.ee.ethz.ch>	<474C2246.50205@ee.ethz.ch> <20071129134554.5c25a891@freepuppy.rosehill> <474F3719.30101@trash.net> <47503971.9080509@ee.ethz.ch> <4753B423.7030000@trash.net> <4753C874.80703@ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Rainer Baumann <baumann@tik.ee.ethz.ch>
To: Ariane Keller <ariane.keller@tik.ee.ethz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39614 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751199AbXLCRfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 12:35:51 -0500
In-Reply-To: <4753C874.80703@ee.ethz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ariane Keller wrote:
> Patrick McHardy wrote:
>>
>> I dislike using anything besides rtnetlink for qdisc configuration.
>> The only way to transfer arbitary amounts of data over netlink would
>> be to spread the data over multiple messages. But then again, you're
>> using kmalloc and only seem to allocate 4k, so how large are these
>> traces in practice?
> 
> For each packet to be processed there is 32bit of data, which encodes 
> delay and drop, duplicate etc. The size of the actual trace file can 
> therefore reach any length, depending on for how many packets the 
> information is encoded (up to several GB).
> Therefore we send the trace file in chunks of 4000bytes to the kernel. 
> In order to have always a "packet-delay-value ready", we maintain two 
> "delay queues" in the kernel (each of 4k). In a first step, both queues 
> are filled, and the values are read from the first queue, if this queue 
> is finished, we read values from the second queue and fill the first 
> queue with new values from the trace file etc. Therefore we have a user 
> space process running, which reads the values from the trace file, and 
> sends them to the kernel.


That sounds like it would also be possible using rtnetlink. You could
send out a notification whenever you switch the active buffer and have
userspace listen to these and replace the inactive one.

