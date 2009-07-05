From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [RFC] arp announce, arp_proxy and windows ip conflict verification
Date: Sun, 5 Jul 2009 03:28:09 +0300
Message-ID: <200907050328.09788.denys@visp.net.lb>
References: <200907030246.18054.denys@visp.net.lb> <20090705085203.332f0c3b.lk-netdev@lk-netdev.nosense.org> <m13a9c2dsg.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:34851 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753037AbZGEA2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jul 2009 20:28:37 -0400
In-Reply-To: <m13a9c2dsg.fsf@fess.ebiederm.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 05 July 2009 03:07:11 Eric W. Biederman wrote:
>
> Multiple subnets on an ethernet segment sure.  Multiple subnets
> subnets that don't communicate?  Not telling your router about all of
> the subnets on the ethernet segment?
>
> The combination of not configuring the router to know about all of the
> subnets and enabling proxy arp is what is causing problems for Denys.
>
> That sure seems like a misconfiguration to me.
>
> Eric
Real example

Still a lot of letters, but i hope it will help to understand situation.

Big office network. We trust each other and we dont have much money. So 
unmanaged switches. Network separated to two locations

Router in the middle.

eth0 - 10.0.0.2/24
eth1 - 10.0.1.1/24
default gateway is 10.0.0.1

arp_proxy enabled on both. Users have on machines netmask /22, so they can 
communicate freely. DHCP assigning addresses for them.

I just install few Windows XP machines in same network, and planned to do some 
tests only between them. I am just using same physical media, i dont think it 
is reasonable to install new switch and cables just for them. Sure if i had 
managed switches i can put them in separate VLAN, but it is just silly to do 
that, because proper network equipment will not interfere with this tests.
So i assign them ip's 192.168.1.1 , 192.168.1.2, 1.3, 1.4 and etc. No default 
gateway. I dont want my traffic go outside.

But whoops, on boot i got IP address conflict. Nice. Ok, let's say i manage 
it, it can be disabled in registry.

I am trying to do tests, and packets supposed to go from 192.168.1.1 to 
192.168.1.2 are being forwarded to router! WTF! In fact router by answering 
any ARP request, and is can be called "ARP spoofing", forwarding my packets 
to default gateway, and sure they wont come back. It makes difficult also to 
find problem, because ARP reply will be given by both hosts, legitimate and 
router who is violating RFC, and depends which come first and which last, it 
will work properly or not. Sure i can enable delay on sending proxy_arp 
request, but if windows host was down at this moment, it will give again, 
invalid "target" in MAC address.

On your logics i must reconfigure router each time when i do tests and assign 
some ip's. Actually i am bringing and plugging to network a lot of different 
equipment, with different default ips. I cannot plug them sometimes directly 
over crossover cable to my PC, and have to use network.

It doesn't look logic to reconfigure office router for each of those devices 
or to make isolation. Thats why in RFC mentioned " The default route must not
    be used when checking for a route to the target host of an ARP
    request. If the default route were used, the check would always
    succeed.  But the host specified by the default route is unlikely to
    know about subnet routing (since it is usually an Internet gateway),
    and thus packets sent to it will probably be lost."
