From: Arvid Brodin <arvid.brodin@enea.com>
Subject: Re: bridge: HSR support
Date: Mon, 24 Oct 2011 16:17:47 +0200
Message-ID: <4EA5738B.8080008@enea.com>
References: <4E948A04.8060400@enea.com> <20111011112821.28cd3e51@nehalam.linuxnetplumber.net> <4E94D67A.9060207@enea.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sestofw01.enea.se ([192.36.1.252]:23098 "HELO mx-3.enea.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S932172Ab1JXOSD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Oct 2011 10:18:03 -0400
In-Reply-To: <4E94D67A.9060207@enea.com>
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
> 
> Why is it a bridge thing and not a standalone or bonding (or the new team
> device feature? Wouldn't users want to use it without all the stuff
> related to bridging. The fact that it doesn't work with STP is a big
> red flag that it doesn't belong in the bridge.

Ok, having read up some more on this it looks like STP is a standardised part of
bridging, so I guess you're right. 


I need to do two things:

1) Bind two network interfaces into one (say, eth0 & eth1 => hsr0). Frames sent on
   hsr0 should get an HSR tag (including the correct EtherType) and go out on both
   eth0 and eth1.

2) Ingress frames on eth0 & eth1, with EtherType 0x88fb, should be captured and 
   handled specially (either received on hsr0 or forwarded to the other bound 
   physical interface).

Any ideas on the best way to implement this -- what's the nicest place to "hook
into" for this?


-- 
Arvid Brodin
Enea Services Stockholm AB
