From: Ben Greear <greearb@candelatech.com>
Subject: Re: questions on NAPI processing latency and dropped network packets
Date: Mon, 21 Jan 2008 15:32:39 -0800
Message-ID: <47952B97.90900@candelatech.com>
References: <478654C3.60806@nortel.com> <4794F848.9020402@nortel.com> <47950A71.5010304@candelatech.com> <47952783.8080505@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:53875 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755387AbYAUXcr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2008 18:32:47 -0500
In-Reply-To: <47952783.8080505@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen wrote:
> Ben Greear wrote:
>> Chris Friesen wrote:
>>
>>> Is there anything else we can do to minimize the latency of network 
>>> packet processing and avoid having to crank the rx ring size up so high?
>>
>>
>> Why is it such a big deal to crank up the rx queue length?  Seems like
>> a perfectly normal way to handle bursts like this...
> 
> It means that the latency for handling those packets is higher than it 
> could be.  Draining 4096 packets from the queue will take a while.
> 
> Ideally we'd like to bring the latency down as much as possible, and 
> then bump up the rx queue length to handle the rest.

Unless having a bigger queue somehow makes the IRQ fire later,
then it wouldn't seem to increase the time for packets that arrive
early in the queue, though it would of course take longer to process
the ones at the back.  Still, if the option is process them slightly
later or drop them, the choice seems obvious...

Decreasing your latencies seems a mostly un-related optimization that
should be tackled independently of queue size.

Do you perhaps have any network equipment that would queue up the pkts
and burst them?  Maybe a firewall, router, or something?  That could
potentially cause small bursts of pkts...

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

