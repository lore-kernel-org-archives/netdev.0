From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] arp announce, arp_proxy and windows ip conflict verification
Date: Wed, 01 Jul 2009 10:40:08 -0700
Message-ID: <m1ws6sqp3b.fsf@fess.ebiederm.org>
References: <200903011344.45814.denys@visp.net.lb>
	<200907010154.27457.denys@visp.net.lb>
	<m1iqicyjmr.fsf@fess.ebiederm.org>
	<200907011242.12812.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:51915 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbZGARkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 13:40:10 -0400
In-Reply-To: <200907011242.12812.denys@visp.net.lb> (Denys Fedoryschenko's message of "Wed\, 1 Jul 2009 12\:42\:12 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryschenko <denys@visp.net.lb> writes:

> On Wednesday 01 July 2009 09:58:36 Eric W. Biederman wrote:
>>
>> What problem were you originally trying to solve?
>>
>> Having a proxy arp gateway reply to addresses it routes is proper
>> behaviour.
> It is not correct behavior to reply to gratuitous ARP, if you dont have this 
> IP locally! 
>
> IP conflict detection will fail then completely, if proxy arp machine have 
> default route (means answer to ALL ARP requests). 

With proxy arp you pretend to have all of the IPs you are proxing for
locally.  You must do everything that the machine you are proxying for
would do on that network.

Having a default route and proxying everything is a misconfiguration.

> Sadly RFC 1027 (Proxy ARP) dated in 1987 and not explaining this case well.
> I found other source of information, it is not reliable (wikipedia), but it is 
> also mentioned in one of HP patents 
> (http://www.freepatentsonline.com/y2009/0073990.html). My point of view 
> marked as (!!!!!!!).
>
> ARP announcements
>
> An ARP announcement (also known as Gratuitous ARP) is a packet containing 
> valid sender hardware and protocol addresses (SHA and SPA) for the host that 
> sent it, with identical destination and source addresses (TPA = SPA). Such a 
> request (!!!!!!!) is not intended to solicit a reply, but merely updates the 
> ARP caches of other hosts that receive the packet. Gratuitous ARP is usually 
> an ARP request [3], but it may also be an ARP reply [4].

Of course a Gratuitous ARP is not intended to solicit a reply.  Because
two machines should not be configured to have the same IP address.

In the case of two machines being configured with the same IP address
replying to gratuitous ARP is correct behaviour.  As it allows discovery
of the network misconfiguration.

The problem is that you have a proxy machine configured to proxy for
the ip that is also assigned to another machine in the same broadcast
domain.  That is a bug.

The only case where I can imagine proxying the default route would even
approach being correct is on a point to point link.  But that seems
pointless as you could simply have a default route to the other side.

Eric
