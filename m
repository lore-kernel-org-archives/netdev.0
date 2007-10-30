From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] remove claim balance_rr won't reorder on many to one
Date: Tue, 30 Oct 2007 15:12:18 -0700
Message-ID: <4727AC42.2060709@hp.com>
References: <200710301948.MAA04351@tardy.cup.hp.com> <5242.1193777750@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:46324 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752708AbXJ3WMU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 18:12:20 -0400
In-Reply-To: <5242.1193777750@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> Rick Jones <rick.jones2@hp.com> wrote:
> [...]
> 
>>-	Note that this out of order delivery occurs when both the
>>-	sending and receiving systems are utilizing a multiple
>>-	interface bond.  Consider a configuration in which a
>>-	balance-rr bond feeds into a single higher capacity network
>>-	channel (e.g., multiple 100Mb/sec ethernets feeding a single
>>-	gigabit ethernet via an etherchannel capable switch).  In this
>>-	configuration, traffic sent from the multiple 100Mb devices to
>>-	a destination connected to the gigabit device will not see
>>-	packets out of order.  However, traffic sent from the gigabit
>>-	device to the multiple 100Mb devices may or may not see
>>-	traffic out of order, depending upon the balance policy of the
>>-	switch.  Many switches do not support any modes that stripe
>>-	traffic (instead choosing a port based upon IP or MAC level
>>-	addresses); for those devices, traffic flowing from the
>>-	gigabit device to the many 100Mb devices will only utilize one
>>-	interface.
> 
> 
> 	Rather than simply removing this entirely (because I do think
> there is value in discussion of the reordering aspects of balance-rr),
> I'd rather see something that makes the following points:
> 
> 	1- the worst reordering is balance-rr to balance-rr, back to
> back.  The reordering rate here depends upon (a) the number of slaves
> involved and (b) packet reception scheduling behaviors (packet
> coalescing, NAPI, etc), and thus will vary signficantly, but won't be
> better than case #2.
> 
> 	2- next worst is "balance-rr many slow" to "single fast", with
> the reordering rate generally being substantially lower than case #1 (it
> looked like your test showed about a 1% reordering rate, if I'm reading
> your data correctly).
> 
> 	3- For the "single fast" to "balance-rr many" case, going
> through a switch configured for etherchannel "may or may not see traffic
> out of order, depending upon the balance policy of the switch.  Many
> switches do not support any modes that stripe traffic (instead choosing
> a port based upon IP or MAC level addresses); for those devices, traffic
> flowing from the [single fast] device to the [balance-rr many] devices
> will only utilize one interface."

I have to wonder if the full description of the different versions of being a 
little bit pregnant is worth it.  Just saying that using balance-rr will result 
in reordering seems much more simple to comprehend.  Also, since balance-rr is 
strictly an outbound policy, does case three even enter into it - as you say, 
that will be up to the switch, which will be doing whatever it was told or felt 
like doing regardless of balance-rr on the bond in the host.

> 
> [...]
> 
>>	This mode requires the switch to have the appropriate ports
>>-	configured for "etherchannel" or "trunking."
>>+	configured for "etherchannel" or "aggregation." N.B. some
>>+	switches might use the term "trunking" for something other 
>>+	than link aggregation.
> 
> 
> 	If memory serves, Sun uses the term "trunking" to refer to
> "etherchannel" compatible behavior.

I'm not really all that tied to that part of the change - it is there because I 
noticed in one of the HP ITRC forums someone talking about a switch (Cisco?) 
where trunking meant something with vlans rather than aggregation.

> 
> 	I'm also hearing "aggregation" used to described 802.3ad
> specifically.
> 
> 	Perhaps text of the form:
> 
> 	This mode requires the switch to have the appropriate ports
> configured for "Etherchannel."  Some switches use different terms, so
> the configuration may be called "trunking" or "aggregation."  Note that
> both of these terms also have other meanings.  For example, "trunking"
> is also used to describe a type of switch port, and "aggregation" or
> "link aggregation" is often used to refer to 802.3ad link aggregation,
> which is compatible with bonding's 802.3ad mode, but not balance-rr.
> 
> 	Thoughts?

Even better would be to be able to start to move away from "etherchannel" 
towards the de jure standard's terms, whatever the heck they are :)

rick jones
