From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [RFC] arp announce, arp_proxy and windows ip conflict verification
Date: Wed, 1 Jul 2009 21:12:40 +0300
Message-ID: <200907012112.40396.denys@visp.net.lb>
References: <200903011344.45814.denys@visp.net.lb> <200907011242.12812.denys@visp.net.lb> <m1ws6sqp3b.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:50678 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754953AbZGASMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 14:12:49 -0400
In-Reply-To: <m1ws6sqp3b.fsf@fess.ebiederm.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 01 July 2009 20:40:08 Eric W. Biederman wrote:
>
> Of course a Gratuitous ARP is not intended to solicit a reply.  Because
> two machines should not be configured to have the same IP address.
>
> In the case of two machines being configured with the same IP address
> replying to gratuitous ARP is correct behaviour.  As it allows discovery
> of the network misconfiguration.
Yes, and it is doing that with my patch also. It is answering if there is same 
_local address_, so it is definitely ip conflict. 

But Proxy ARP answering to ARP Announce without checking if destination 
address taken - wrong.  Because it should check if host in destination 
(proxied) network really is taken and should not answer if it is not. 

>
> The problem is that you have a proxy machine configured to proxy for
> the ip that is also assigned to another machine in the same broadcast
> domain.  That is a bug.
Where it is defined as bug? 
Sometimes it can be used on purpose, to filter traffic in local segment with 
lot of unmanaged switches.


>
> The only case where I can imagine proxying the default route would even
> approach being correct is on a point to point link.  But that seems
> pointless as you could simply have a default route to the other side.
Examples just came in mind:
1)Mobile IP. 

2)Port isolated setup, available on some switches and on wireless access 
points, when hosts cannot talk one to each other via broadcast domain, only 
via gateway. In this case gateway must give reply to legitimate arp requests, 
but ignore arp announce(gratuitous ARP).

I will search more respectable sources of information for this case. Btw it is 
difficult to find out this days "generic" gateway host without default 
gateway :-)

And last case, it breaks things for high availability ONLY because it doesn't 
update neighbor table. That can be fixed easily and i sent patches for that.
