From: Rick Jones <rick.jones2@hp.com>
Subject: Re: pktgen question
Date: Mon, 24 Sep 2007 11:02:36 -0700
Message-ID: <46F7FBBC.6080401@hp.com>
References: <46F6905C.6030309@opengridcomputing.com>		<20070923172803.GA11997@2ka.mipt.ru>		<46F6A887.1030301@opengridcomputing.com>	<1190571527.4256.78.camel@localhost>	<46F75968.4010307@candelatech.com>	<46F7C185.1030202@opengridcomputing.com>	<46F7CC09.6070603@candelatech.com>	<46F7D12A.7020607@opengridcomputing.com> <46F7D9C8.7020101@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steve Wise <swise@opengridcomputing.com>, hadi@cyberus.ca,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:50350 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758935AbXIXSDl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2007 14:03:41 -0400
In-Reply-To: <46F7D9C8.7020101@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Perf-wise, you could clone the skbs up front, then deliver them to the 
>> nic in a tight loop.  This would mitigate the added overhead 
>> introduced by calling skb_clone() in the loop doing transmits...
> 
> That only works if you are sending a small number of skbs.  You can't 
> pre-clone several minutes worth of 10Gbe traffic
> with any normal amount of RAM.

Does pktgen really need to allocate anything more than some smallish fraction 
more than the depth of the driver's transmit queue?

Of course, even that won't fit in the L1 cache of a processor, so if one is 
really just trying to max-out the NIC it might still have too much overhead, but 
then does pktgen+driver et al actually fit in an L1 cache?

rick jones
