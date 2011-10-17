From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] net: ipv6: Allow netlink to set IPv6 address scope
Date: Sun, 16 Oct 2011 20:45:19 -0400
Message-ID: <4E9B7A9F.7000302@hp.com>
References: <20111005201559.E544016A599@drone1.mtv.corp.google.com> <4E931A46.1040905@hp.com> <CAKD1Yr29dAC+_=bT5-_W3XuTzoxMiEzOhpHvwrAzyA8NdcCjSQ@mail.gmail.com> <4E98981D.6080908@hp.com> <CAKD1Yr0EQ0P8e1V7pw48F2LMPCFKuZHm0DGoq8VM+LeKO_aZhQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: maze@google.com, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:11363 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044Ab1JQApZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Oct 2011 20:45:25 -0400
In-Reply-To: <CAKD1Yr0EQ0P8e1V7pw48F2LMPCFKuZHm0DGoq8VM+LeKO_aZhQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/14/2011 06:32 PM, Lorenzo Colitti wrote:
> On Fri, Oct 14, 2011 at 13:14, Brian Haley <brian.haley@hp.com> wrote:
>> Playing devil's advocate here, isn't this a brain-dead ISP?  If they're
>> giving you a global IPv6 address you should get Internet connectivity
>> with it.  If not, you probably knew it up front, or you're going to find
>> another provider that does.  It's like they're giving you a site-local
>> address...
> 
> I wouldn't say they're a brain-dead carrier, because they also give you
> true IPv6 connectivity on another interface. The phone will deactivate
> this interface when bringing up wifi, because wifi is usually cheaper and
> faster. However, the carrier interface needs to stay up all the time
> in order to do such things as provisioning, send and receive SMS
> messages, handle voice over IP calls, and so on. So you will have
> cases where the phone's primary Internet connection is over wifi, but
> the phone still has a global unicast IPv6 address on the carrier interface.
> 
>> So are you talking about being able to dynamically change the scope
>> of an address?  Wifi comes up - change provider addreses to host-
>> local, wifi goes down - change it back to global.  That looks like a
>> hack.
> 
> What I'm suggesting is to have the carrier interface be created with
> site scope and stay up forever (or as long as the phone is on the cell
> network). If an application wants to use the carrier interface, it will create
> host routes that explicitly specify the carrier interface and the source
> address of the carrier interface.
> 
> Applications that don't use the carrier interface will not have to do
> anything special; if you set the carrier interface to site scope,
> the kernel should just do the right thing.

I think this goes against the intent of RFC 3879 (Deprecating Site Local
Addresses), and it assumes that the user has some knowledge of the network
topology.  When we send something out the carrier interface, we don't know why
it didn't make it to it's final destination - firewall, network link down,
congestion - we might not get the ICMP reason back.

The MIF problem statement (in the RFC editor's queue) talks about this problem,
http://tools.ietf.org/html/draft-ietf-mif-problem-statement-15 - perhaps it's
better to work there to develop a more generic solution (using DHCPv6, RA
options, etc) before making this change?

-Brian
