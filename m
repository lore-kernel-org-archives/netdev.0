From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] arp announce, arp_proxy and windows ip conflict verification
Date: Thu, 02 Jul 2009 20:14:44 -0700
Message-ID: <m1ab3mihjv.fsf@fess.ebiederm.org>
References: <200903011344.45814.denys@visp.net.lb>
	<200907030203.08294.denys@visp.net.lb>
	<m1ws6qu0te.fsf@fess.ebiederm.org>
	<200907030246.18054.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:45342 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850AbZGCDOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 23:14:46 -0400
In-Reply-To: <200907030246.18054.denys@visp.net.lb> (Denys Fedoryschenko's message of "Fri\, 3 Jul 2009 02\:46\:17 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryschenko <denys@visp.net.lb> writes:

>> Having two networks:
>> 10.0.0.0/24 physical segment
>> 10.0.1.0/24 physical segment
>>
>> It is correct for proxy arp to answer to for 10.0.0.66
>> when it is plugged into the 10.0.1.0/24 network.
> It is not defined in standart, correct or not. 
>
>>
>> Because in that case 10.0.0.66 is on the wrong subnet, and your
>> network is misconfigured.
> What Linux does care about this?
> It is not police inspector to block me from taking this ip in wrong subnet.
>
> And without emotions - it is not his job to give answers for wrong request 
> (ARP Announce), from wrong ip (not linux with proxy arp enabled interface 
> subnet). Especially because there is no use for current behavior, other than 
> making problems.

There is use. Talking to the machine that is known as 10.0.0.66 when
it is plugged into the network it is configured to be on.

> And most important what you are telling violates RFC again, i finally found 
> this in RFC 1027:
>
> ..."The gateway
>     is acting as an agent for host B, which is why this technique is
>     called "Proxy ARP"; we will refer to this as a transparent subnet
>     gateway or ARP subnet gateway.
> "...
>
> "    An ARP subnet gateway implementation must not reply if the physical
>     networks of the source and target of an ARP request are the same.
>     In this case, either the target host is presumably either on the
>     same physical network as the source host and can answer for itself,
>     or the target host lies in the same direction from the gateway as
>     does the source host, and an ARP reply from the would cause a loop.
> "

This is comedy.  They are supposed to be on different physical
networks as far as linux is configured.  The fact the laptop is in the
wrong place is something else again.

As for the rest.  I am not a great expert on how Cisco configuration
works.  In your example I believe you did not place the ports on
different vlans.  If both networks are run in the same vlan and
the packets will be bridged and everything will work smoothly.

Except when you explicitly configure it.  Linux does not do anything
layer 2.  So by default when we have two interfaces coming into a linux
box we do not bridge them.

Is this perhaps where you are confused?

Eric
