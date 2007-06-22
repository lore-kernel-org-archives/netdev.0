From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 0/7] CAN: Add new PF_CAN protocol family, try #3
Date: Fri, 22 Jun 2007 18:23:50 +0200
Message-ID: <467BF796.9080900@trash.net>
References: <20070622034452.28886.0@janus.isnogud.escape.de> <467BC1E9.6030201@trash.net> <467BF184.8040109@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs@isnogud.escape.de>,
	David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	netdev@vger.kernel.org, j.hadi123@gmail.com
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34048 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854AbXFVQYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 12:24:01 -0400
In-Reply-To: <467BF184.8040109@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Hartkopp wrote:
> Patrick McHardy wrote:
>   
>> Urs Thuermann wrote:
>>   
>>     
>>> * Use skb->iif instead of skb->cb to pass receiving interface from
>>>   raw_rcv() and bcm_rcv() up to raw_recvmsg() and bcm_recvmsg().
>>>     
>>>       
>> skb->iif doesn't necessarily point to the incoming network device
>> as seen seen by netif_receive_skb, for layered devices it currently
>> always points to the first interface that received a packet.
>>   
>>     
>
> This is exactly the intention.
>
>   
>> Its so far also only used for traffic classification, please explain
>> how you're using it and what values it is set to on which paths.
>>   
>>     
>
> As you might have seen in Documentation/networking/can.txt (hint, hint,
> hint!) the CAN has no routing, no ARP, no MAC adressing and is a
> broadcast only medium. So if there is (at least) any reasonable
> addressing on CAN it consists of the CAN-frame's "CAN-Identifier" and
> the CAN-bus this CAN-frame is sent/received on.
>
> For this reason the information about the interface the CAN-frame has
> been received on has to be made available to the user-application if it
> needs this information. Until your hint about our skb->cb missusage, we
> (successfully) transported this information inside skb->cb to
> socket-level. But indeed skb->iif is the better (and in our opinion the
> right) place to transport this information inside the skb to the
> socket-level.
>   

Lets hear Jamal's opinion on this, to be honest I never understood
how exactly it is supposed to be used.

> In both cases (receiving real CAN-frames from the CAN-netdev /
> performing the loopback of CAN-frames) we set skb->iif to zero to let
> netif_receive_skb() set the iif-value to the current skb->dev index. So
> skb->iif is set to the first interface the CAN-frame is received on,
> which is what we need & intended here.
>
> Is it the right approach to let netif_receive_skb() set the iif-value or
> should we better set this value on our own before invoking netif_rx()?
>   

netif_receive_skb is meant to be used as a default, the driver can
override this if it makes sense. If you touch it anyway you might
as well set it to the final value.

