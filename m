From: Ariane Keller <ariane.keller@tik.ee.ethz.ch>
Subject: Re: [PATCH 0/2] netem: trace enhancement
Date: Mon, 03 Dec 2007 10:12:20 +0100
Message-ID: <4753C874.80703@ee.ethz.ch>
References: <20071120231131.oqn4s5eda84k4csw@email.ee.ethz.ch>	<474C2246.50205@ee.ethz.ch> <20071129134554.5c25a891@freepuppy.rosehill> <474F3719.30101@trash.net> <47503971.9080509@ee.ethz.ch> <4753B423.7030000@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ariane Keller <ariane.keller@tik.ee.ethz.ch>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Rainer Baumann <baumann@tik.ee.ethz.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ee.ethz.ch ([129.132.2.219]:45922 "EHLO smtp.ee.ethz.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751681AbXLCJMX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2007 04:12:23 -0500
In-Reply-To: <4753B423.7030000@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Patrick McHardy wrote:
> Ariane Keller wrote:
>> Thanks for your comments!
>>
>> I'd like to better understand your dislike of the current 
>> implementation  of the data transfer from user space to kernel space.
>> Is it the fact that we use configfs?
>> I think, we had already a discussion about this (and we changed from 
>> procfs to configfs).
>> Or don't you like that we need a user space daemon which is 
>> responsible for feeding the data to the kernel module?
>> I think we do not have another option, since the trace file may be of 
>> arbitrary length.
>> Or anything else?
> 
> 
> I dislike using anything besides rtnetlink for qdisc configuration.
> The only way to transfer arbitary amounts of data over netlink would
> be to spread the data over multiple messages. But then again, you're
> using kmalloc and only seem to allocate 4k, so how large are these
> traces in practice?

For each packet to be processed there is 32bit of data, which encodes 
delay and drop, duplicate etc. The size of the actual trace file can 
therefore reach any length, depending on for how many packets the 
information is encoded (up to several GB).
Therefore we send the trace file in chunks of 4000bytes to the kernel. 
In order to have always a "packet-delay-value ready", we maintain two 
"delay queues" in the kernel (each of 4k). In a first step, both queues 
are filled, and the values are read from the first queue, if this queue 
is finished, we read values from the second queue and fill the first 
queue with new values from the trace file etc. Therefore we have a user 
space process running, which reads the values from the trace file, and 
sends them to the kernel.

