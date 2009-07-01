From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [RFC] arp announce, arp_proxy and windows ip conflict verification
Date: Wed, 1 Jul 2009 22:01:13 +0300
Message-ID: <200907012201.13760.denys@visp.net.lb>
References: <200903011344.45814.denys@visp.net.lb> <200907011242.12812.denys@visp.net.lb> <m1ws6sqp3b.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:56801 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752456AbZGATBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 15:01:33 -0400
In-Reply-To: <m1ws6sqp3b.fsf@fess.ebiederm.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 01 July 2009 20:40:08 Eric W. Biederman wrote:
> The only case where I can imagine proxying the default route would even
> approach being correct is on a point to point link.  But that seems
> pointless as you could simply have a default route to the other side.
>
> Eric

It seems Linux proxy_arp behavior is also RFC 1027 non-conformant.

Quote from RFC:

    In 4.3BSD (and probably in other operating systems), a default route
    is possible.  This default route specifies an address to forward a
!   packet to when no other route is found.  The default route must not
!   be used when checking for a route to the target host of an ARP
!   request.  If the default route were used, the check would always
    succeed.  But the host specified by the default route is unlikely to
    know about subnet routing (since it is usually an Internet gateway),
    and thus packets sent to it will probably be lost.  This special
    case in the routing lookup method is the only implementation change
    needed to the routing mechanism.



If i have linux host with 
eth0 10.0.0.1/24
eth1 10.0.1.1/24

sysctl -w net.ipv4.conf.eth1.proxy_arp=1

from other host in same ethernet segment eth1

Xpernet_137 ~ # arping -I eth1 2.4.6.8
ARPING to 2.4.6.8 from 1.0.0.1 via eth1
Unicast reply from 2.4.6.8 [0:5:5d:2f:9b:ba] 501.685ms
Unicast reply from 2.4.6.8 [0:5:5d:2f:9b:ba] 0.198ms

And RFC define to not do that (use default route for proxy_arp).
