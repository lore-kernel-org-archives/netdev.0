From: subashab@codeaurora.org
Subject: Re: [RFC PATCH] xfrm: Add option to reset oif in xfrm lookup
Date: Wed, 03 Aug 2016 17:02:57 -0600
Message-ID: <3e4bb514a6fc5316c093f5f39cc07762@codeaurora.org>
References: <1469493272-14894-1-git-send-email-subashab@codeaurora.org>
 <ceb825e1-cba5-e252-f8d1-30198797bbb2@cumulusnetworks.com>
 <7e8efab3f896b081adb6bbaf6613a569@codeaurora.org>
 <7c3836e2-adf0-8e04-8c2f-6ee714a38f70@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, netdev-owner@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:43105 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932671AbcHCXDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 19:03:00 -0400
In-Reply-To: <7c3836e2-adf0-8e04-8c2f-6ee714a38f70@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I can't explain the iptables output but from a FIB lookup perspective
> it is using table 8 per the FIB rules, the xfrm is hit and packets
> shift to 192.168.77.1 and go out what you have as eth0.
> 
> Take a look at:
>   perf record -e fib:* -a -g
>   perf script
> 
> And then run tcpdump on both eth0 and eth1. For me on "eth0" (which is
> really eth11 for my VM setup) I see this on the ping:
> 

You can try running these commands as is on UML.
We tried these out on 3.18 as well as on 4.4.

> 20:50:11.389837 ARP, Request who-has 192.168.77.2 tell 192.168.77.1, 
> length 28
> 20:50:11.390079 ARP, Reply 192.168.77.2 is-at 02:00:12:34:02:0a, length 
> 28
> 20:50:11.390101 IP 192.168.77.1 > 192.168.77.2: ICMP 192.168.77.1 udp
> port 4500 unreachable, length 168
> 
> So the packets are going out "eth0" as expected.
> 
> That said, the commands you have given do not totally transfer to
> another setup. In my case I have 2 VMs with eth11 and eth12 directly
> connected (VM1 eth11 <--> VM2 eth11 and ditto for eth12). You have
> given one side of the commands and I have configured the other side
> with the .1 addresses but not bothered to translate the xfrm commands.
> 
> That said, this seems like a contrived example -- you pin ping to
> device eth1 (-I eth1), you are pinging a host on the network for eth1
> but want packets to go out eth0 via the xfrm. Can you elaborate on the
> real use case and problem here?

Applications may be bound to a specific interface but would try to send 
data over multiple types of networks.
Our use case here is wifi calling. In this case, we try to force packets 
to go over wifi after encryption.
The rules which we were using worked on 3.18 but we ran into issues on 
4.4.
Debugging narrowed us down to this oif preservation through xfrm.
