From: Steve Chen <schen@mvista.com>
Subject: Re: [PATCH] Multicast packet reassembly can fail
Date: Wed, 28 Oct 2009 13:40:14 -0500
Message-ID: <1256755214.3153.489.camel@linux-1lbu>
References: <1256683583.3153.389.camel@linux-1lbu> <4AE780CB.8070401@hp.com>
	 <4AE8776D.4020609@mvista.com>  <4AE87D03.4020708@hp.com>
	 <1256752203.3153.461.camel@linux-1lbu>  <4AE88907.3030206@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mark Huth <mhuth@mvista.com>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu47.mvista.com ([206.112.117.47]:57428 "HELO
	gateway-1237.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with SMTP id S1752639AbZJ1ScX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 14:32:23 -0400
In-Reply-To: <4AE88907.3030206@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-10-28 at 11:10 -0700, Rick Jones wrote:
> >>If I understand correctly, the idea here is to say that when multiple interfaces 
> >>receive fragments of copies of the same  IP datagram that both copies will 
> >>"survive" and flow up the stack?
> >>
> >>I'm basing that on your description, and an email from Steve that reads:
> >>
> >>
> >>>Actually, the patch tries to prevent packet drop for this exact
> >>>scenario.  Please consider the following scenarios
> >>>1.  Packet comes in the fragment reassemble code in the following order
> >>>(eth0 frag1), (eth0 frag2), (eth1 frag1), (eth1 frag2)
> >>>Packet from both interfaces get reassembled and gets further processed.
> >>>
> >>>2. Packet can some times arrive in (perhaps other orders as well)
> >>>(eth0 frag1), (eth1 frag1), (eth0 frag2), (eth1 frag2)
> >>>Without this patch, eth0 frag 1/2 are overwritten by eth1 frag1/2, and
> >>>packet from eth1 is dropped in the routing code.
> >>
> >>Doesn't that rather fly in the face of the weak-end-system model followed by Linux?
> >>
> >>I can see where scenario one leads to two IP datagrams making it up the stack, 
> >>but I would have thought that was simply an "accident" of the situation that 
> >>cannot reasonably be prevented, not justification to cause scenario two to send 
> >>two datagrams up the stack.
> > 
> > 
> > For scenario 2, the routing code drops the 2nd packet.  As a result, no
> > packet make it to the application.  If someone is willing to suggest an
> > alternative, I can certainly rework the patch and retest.
> 
> I'll ask my next potentially Emily Litella question - don't multicast IP 
> applications bind to multicast IP addresses and not interfaces?  That is to say, 
> doesn't the first datagram completed get delivered to all applications on the 
> host which have bound to the corresponding multicast IP (and port number...) ?
I actually don't know who Emily Litella is until today.  This mailing
list is great not just for learning networking stuff :).  In the test
code I received, one of the step to setup is to configure the IP address
of the interface that the application is expecting the packet.  It
appears to bind on interface based on that casual observation.  I'll
have to study the code in detail to be able to say for sure.

Regards,

Steve


