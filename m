From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [rfc] new sk_buff member: hwstamp
Date: Mon, 14 Jul 2008 20:58:00 +0200
Message-ID: <487BA1B8.5070006@hartkopp.net>
References: <200807141843.00845.opurdila@ixiacom.com> <87abgkz8bc.fsf@basil.nowhere.org> <487B9396.1060701@hartkopp.net> <200807142130.12375.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:58933 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539AbYGNTJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 15:09:30 -0400
In-Reply-To: <200807142130.12375.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila wrote:
>> However i feel, that *one* nanosec resolution timestamp (as it already
>> exists inside the skbuff) is enough. AFAIK the timestamp is only set in
>> the netif_rx(), when it is not already set by the driver itself. For
>> that reason i would suggest to create some semi-intelligent offset
>> calculation inside the driver that makes the skb->tstamp value
>> correspond with the hw timestamp and therefore transports the high
>> resolution timestamp requirement into the userspace.
>>
>>     
>
> You mean something like here [1] ?
> [1] 
> http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc4/2.6.23-rc4-mm1/broken-out/sky2-hardware-receive-timestamp-counter.patch
>
>   

Yes - exactly :-)

> The problem for this approach in our usecase (one way delay measurement) is 
> that the real time clock of the CPUs (of the RX and TX ports) is not 
> synchronized, but the hw timestamp (implemented in the NIC/FPGA) is. 
>   

Is it necessary to have syncronized clocks on the different CPUs or is
it feasible to calculate a per-cpu-clock offset in your driver, so that
you can build a complete timing overview of your setup?

Regards,
Oliver

