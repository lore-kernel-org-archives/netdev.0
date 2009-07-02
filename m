From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [RFC] arp announce, arp_proxy and windows ip conflict verification
Date: Fri, 3 Jul 2009 02:46:17 +0300
Message-ID: <200907030246.18054.denys@visp.net.lb>
References: <200903011344.45814.denys@visp.net.lb> <200907030203.08294.denys@visp.net.lb> <m1ws6qu0te.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:46673 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754232AbZGBXqh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 19:46:37 -0400
In-Reply-To: <m1ws6qu0te.fsf@fess.ebiederm.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 03 July 2009 02:23:09 Eric W. Biederman wrote:
> What IOS is irrelevant to this discussion.
Directly relevant, Cisco usually following standards very well.


> Especially when I don't see the "ip proxy-arp" command.
>From Cisco IOS manual:
ip proxy-arp

....

Defaults

Enabled 

It will show in config only "no ip proxy arp"

For example
show running 
....
interface FastEthernet2/0
 ip address 10.0.2.2 255.255.255.0
 duplex half
....

Router(config)#inter FastEthernet 2/0
Router(config-if)#no ip proxy-arp

show running

....
interface FastEthernet2/0
 ip address 10.0.2.2 255.255.255.0
 no ip proxy-arp
 duplex half
....

>
> Having two networks:
> 10.0.0.0/24 physical segment
> 10.0.1.0/24 physical segment
>
> It is correct for proxy arp to answer to for 10.0.0.66
> when it is plugged into the 10.0.1.0/24 network.
It is not defined in standart, correct or not. 

>
> Because in that case 10.0.0.66 is on the wrong subnet, and your
> network is misconfigured.
What Linux does care about this?
It is not police inspector to block me from taking this ip in wrong subnet.

And without emotions - it is not his job to give answers for wrong request 
(ARP Announce), from wrong ip (not linux with proxy arp enabled interface 
subnet). Especially because there is no use for current behavior, other than 
making problems.

And most important what you are telling violates RFC again, i finally found 
this in RFC 1027:

..."The gateway
    is acting as an agent for host B, which is why this technique is
    called "Proxy ARP"; we will refer to this as a transparent subnet
    gateway or ARP subnet gateway.
"...

"    An ARP subnet gateway implementation must not reply if the physical
    networks of the source and target of an ARP request are the same.
    In this case, either the target host is presumably either on the
    same physical network as the source host and can answer for itself,
    or the target host lies in the same direction from the gateway as
    does the source host, and an ARP reply from the would cause a loop.
"
Also not very clear, but maybe it is a reason why Cisco doesn't answer to ip 
who is not reachable from this interface
"
    If the IP networks of the source and target hosts of an ARP request
    are different, an ARP subnet gateway implementation should not
    reply.  This is to prevent the ARP subnet gateway from being used to
    reach foreign IP networks and thus possibly bypass security checks
    provided by IP gateways.
"



>
> Eric


