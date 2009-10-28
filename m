From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] Multicast packet reassembly can fail
Date: Wed, 28 Oct 2009 11:10:15 -0700
Message-ID: <4AE88907.3030206@hp.com>
References: <1256683583.3153.389.camel@linux-1lbu> <4AE780CB.8070401@hp.com>	<4AE8776D.4020609@mvista.com>  <4AE87D03.4020708@hp.com> <1256752203.3153.461.camel@linux-1lbu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark Huth <mhuth@mvista.com>, netdev@vger.kernel.org
To: Steve Chen <schen@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:24170 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915AbZJ1SKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 14:10:16 -0400
In-Reply-To: <1256752203.3153.461.camel@linux-1lbu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>If I understand correctly, the idea here is to say that when multiple interfaces 
>>receive fragments of copies of the same  IP datagram that both copies will 
>>"survive" and flow up the stack?
>>
>>I'm basing that on your description, and an email from Steve that reads:
>>
>>
>>>Actually, the patch tries to prevent packet drop for this exact
>>>scenario.  Please consider the following scenarios
>>>1.  Packet comes in the fragment reassemble code in the following order
>>>(eth0 frag1), (eth0 frag2), (eth1 frag1), (eth1 frag2)
>>>Packet from both interfaces get reassembled and gets further processed.
>>>
>>>2. Packet can some times arrive in (perhaps other orders as well)
>>>(eth0 frag1), (eth1 frag1), (eth0 frag2), (eth1 frag2)
>>>Without this patch, eth0 frag 1/2 are overwritten by eth1 frag1/2, and
>>>packet from eth1 is dropped in the routing code.
>>
>>Doesn't that rather fly in the face of the weak-end-system model followed by Linux?
>>
>>I can see where scenario one leads to two IP datagrams making it up the stack, 
>>but I would have thought that was simply an "accident" of the situation that 
>>cannot reasonably be prevented, not justification to cause scenario two to send 
>>two datagrams up the stack.
> 
> 
> For scenario 2, the routing code drops the 2nd packet.  As a result, no
> packet make it to the application.  If someone is willing to suggest an
> alternative, I can certainly rework the patch and retest.

I'll ask my next potentially Emily Litella question - don't multicast IP 
applications bind to multicast IP addresses and not interfaces?  That is to say, 
doesn't the first datagram completed get delivered to all applications on the 
host which have bound to the corresponding multicast IP (and port number...) ?

rick jones
