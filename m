From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/2] netem: trace enhancement
Date: Wed, 05 Dec 2007 14:05:23 +0100
Message-ID: <4756A213.2060806@trash.net>
References: <20071120231131.oqn4s5eda84k4csw@email.ee.ethz.ch>	<474C2246.50205@ee.ethz.ch> <20071129134554.5c25a891@freepuppy.rosehill>	<474F3719.30101@trash.net> <47503971.9080509@ee.ethz.ch>	<4753B423.7030000@trash.net> <4753C874.80703@ee.ethz.ch>	<47543E65.4060303@trash.net> <47544B1F.1010902@candelatech.com> <20071204154535.4eu35nfe9wks8kgg@email.ee.ethz.ch> <47556B20.2030700@trash.net> <4756A046.1070608@ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Rainer Baumann <baumann@tik.ee.ethz.ch>
To: Ariane Keller <ariane.keller@tik.ee.ethz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61921 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495AbXLENFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 08:05:40 -0500
In-Reply-To: <4756A046.1070608@ee.ethz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ariane Keller wrote:
> Thanks for your comments!
> 
> Patrick McHardy wrote:
>
>>> But with this we would need the tcm_handle, tcm_parent arguments etc. 
>>> which are not known in q_netem.c
>>> Therefore we would have to change the parse_qopt() function prototype 
>>> in order to pass the whole "req" and not only the nlmsghdr.
>>
>> I assume you mean netem_init, parse_qopt is userspace. But I don't
>> see how that is related, emptying the buffer happens during packet
>> processing, right?
 >
> Actually I meant parse_qopt from user space.
> If we would change that function prototype we would have the whole 
> message header available in netem_parse_opt() and could pass this to the 
> process which is responsible for sending the data to the kernel. This 
> process would use this header every time it has to send new values to 
> the netem_change() function in the kernel module.


You don't actually want to parse tc output in your program?
Just open a netlink socket and do the necessary processing
yourself, libnl makes this really easy.

> I thought about this because I was not aware of the qdisc_notify function.
> Anyway I've got some troubles with calling qdisc_notify.
> 1. I have to do a EXPORT_SYMBOL(qdisc_notify) (currently it is declared 
> static in sch_api.c)

This is fine.

> 2. I'd like to call it from netem_enqueue(), which leads to a "sleeping 
> function called from invalid context", since we are still in interrupt 
> context. Therefore I think I have to put it in a workqueue.

Just change it to use gfp_any().
