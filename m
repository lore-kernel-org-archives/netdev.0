From: Ben Greear <greearb@candelatech.com>
Subject: Re: pktgen question
Date: Mon, 24 Sep 2007 11:22:50 -0700
Message-ID: <46F8007A.6000701@candelatech.com>
References: <46F6905C.6030309@opengridcomputing.com>		<20070923172803.GA11997@2ka.mipt.ru>		<46F6A887.1030301@opengridcomputing.com>	<1190571527.4256.78.camel@localhost>	<46F75968.4010307@candelatech.com>	<46F7C185.1030202@opengridcomputing.com>	<46F7CC09.6070603@candelatech.com>	<46F7D12A.7020607@opengridcomputing.com> <46F7D9C8.7020101@candelatech.com> <46F7FBBC.6080401@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steve Wise <swise@opengridcomputing.com>, hadi@cyberus.ca,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:37582 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762648AbXIXSXT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2007 14:23:19 -0400
In-Reply-To: <46F7FBBC.6080401@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
>>> Perf-wise, you could clone the skbs up front, then deliver them to 
>>> the nic in a tight loop.  This would mitigate the added overhead 
>>> introduced by calling skb_clone() in the loop doing transmits...
>>
>> That only works if you are sending a small number of skbs.  You can't 
>> pre-clone several minutes worth of 10Gbe traffic
>> with any normal amount of RAM.
> 
> Does pktgen really need to allocate anything more than some smallish 
> fraction more than the depth of the driver's transmit queue?

If you want to send sustained high rates of traffic, for more than
just a trivial amount of time, then you either have to play the current
trick with the skb_get(), or you have to allocate a real packet each time
(maybe with skb_clone() or similar, but it's still more overhead than the skb_get
which only bumps a reference count.)

I see no other way, but if you can think of one, please let me know.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

