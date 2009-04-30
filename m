From: Mark Smith
	<lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
Subject: Re: [RFC, PATCH 2.6.29.2] Ethernet V2.0 Configuration Testing
 Protocol, revision 20090428
Date: Thu, 30 Apr 2009 19:06:44 +0930
Message-ID: <20090430190644.4d116984.lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
References: <20090429210436.a515465b.lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
	<20090429115716.3e315812@nehalam>
	<20090430065950.529359e3.lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
	<20090429.143534.32129577.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.adam.net.au ([202.136.110.251]:60411 "EHLO
	smtp2.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306AbZD3Jgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 05:36:51 -0400
In-Reply-To: <20090429.143534.32129577.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Wed, 29 Apr 2009 14:35:34 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Mark Smith <lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
> Date: Thu, 30 Apr 2009 06:59:50 +0930
> 
> > So should I submit patches that rip every protocol out of the kernel
> > that could be implemented in user space using AF_PACKET?
> 
> Don't be rediculious.
> 

I'm sorry about that. That's probably an Australian thing to do when
you seem to be encountering what appears to be an obvious
inconsistency. 

> The deciding factor is actually one of performance.
> 
> And I can't see how putting this into userspace makes it any less
> usable, performance wise.  Whereas for protocols that we do have in
> the kernel, performance does matter.
> 

I understand that, for all protocols where performance is critical.
What I don't understand though is why an IPv4 Echo Request responder,
an IPv6 Echo Request responder and an 802.2/LLC TEST frame responder
are in the kernel. I've never heard of anybody saying these specific
testing functions are performance critical. If they are, I'm genuinely
interested in what the performance critical cases are.

In my opinion, the primary reason why these sorts of testing functions
have been put in kernels rather than user space is to ensure ubiquity.
If they weren't universally available, then you could never be sure
what a lack of response ment - it could either mean the network
connectivity is truely broken, the user space daemon isn't
running, or the protocol hasn't been implemented. The user space daemon
might not be running because it has failed, or because it has been
switched off. The results of your testing are far more ambiguous,
making these tests significantly less useful.

Admittedly this confusion is already now happening more often, because
people are firewalling IPv4 ping. People who have to troubleshoot
networks now have to spend more time and develop different and more
complicated tests to verify basic remote node availability. I used to
be able to rely on a ping test from a router to an locally attached
host, now if I don't get a response to a ping, I now have to check the
ARP cache as well, to verify if the host is actually there or not. Not
a big additonal amount of time in itself, but multipled by all the
network admins out there, it'd be a significant time cost.

> Stephen is right, this protocol could very well be more appropriately
> implemented in userspace.

So that raises a hypthetical question. If I were to develop user space
implementations of an IPv4 ping responder, an IPv6 responder, and an
802.2/LLC TEST responder, would patches to remove those functions from
the kernel be accepted?

Thanks,
Mark.
