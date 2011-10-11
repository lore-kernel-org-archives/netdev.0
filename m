From: Arvid Brodin <arvid.brodin@enea.com>
Subject: Re: bridge: HSR support
Date: Wed, 12 Oct 2011 01:51:22 +0200
Message-ID: <4E94D67A.9060207@enea.com>
References: <4E948A04.8060400@enea.com> <20111011112821.28cd3e51@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Lennert Buytenhek <kernel@wantstofly.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sestofw01.enea.se ([192.36.1.252]:2587 "HELO mx-3.enea.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1750919Ab1JKX47 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 19:56:59 -0400
In-Reply-To: <20111011112821.28cd3e51@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Tue, 11 Oct 2011 20:25:08 +0200
> Arvid Brodin <arvid.brodin@enea.com> wrote:
> 
>> Hi,
>>
>> I want to add support for HSR ("High-availability Seamless Redundancy",
>> IEC-62439-3) to the bridge code. With HSR, all connected units have two network
>> ports and are connected in a ring. All new Ethernet packets are sent on both
>> ports (or passed through if the current unit is not the originating unit). The
>> same packet is never passed twice. Non-HSR units are not allowed in the ring.
>>
>> This gives instant, reconfiguration-free failover.
>>
>> I'd like your input on how to design the user interface. To me it seems natural
>> to use bridge-utils, which of course today supports STP.
>>
>> One solution is to simply add an "hsr" command:
>>
>> # brctl hsr <bridge> on|off
>>
>> But HSR is mutually exclusive to other modes, and I think that STP and standard
>> bridge mode are mutually exclusive, too? Perhaps it would be better (more user-
>> friendly) to 
>>
>> # brctl type <bridge> standard|stp|hsr
>>
>> ?
>>
>> 'brctl stp <bridge> on|off' would have to be kept for compatibility, but could
>> be a simple wrapper for 'brctl type <bridge> stp|standard'
>>
>> What do you think about this?
>>
>>
> 
> Why is it a bridge thing and not a standalone or bonding (or the new team
> device feature? Wouldn't users want to use it without all the stuff
> related to bridging. The fact that it doesn't work with STP is a big
> red flag that it doesn't belong in the bridge.

Good question! I'm new to the more advanced networking possibilities in Linux, so 
I really don't know where HSR fits best.

HSR is a layer 2 only protocol, with the host acting as bridge for packets not 
destined for itself. It also sends all originating Ethernet packets on both ports,
adding a HSR sequence tag to the packet (using a dedicated EtherType of 0x88FB).
As described above, the HSR units are connected in a ring, in which only HSR units
are allowed.

Having looked now at bonding, it seems to act on several network layers, doing 
multiple things mainly centered around 802.3ad (link aggregation). I'm not sure
how HSR would fit there.

If I understand correctly, team device is an emerging userspace implementation of
the bonding driver?

I guess my take was that HSR seems like a special bridging mode, much like STP.


> Please discuss this on netdev mailing list, others may have different
> opinions.

Done! :)


-- 
Arvid Brodin
Enea Services Stockholm AB
