From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: Strange IPSec / ICMPv6 redirect behavior
Date: Fri, 19 Apr 2013 00:03:22 +0200
Message-ID: <51706DAA.7050401@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:57812 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752689Ab3DRWI1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 18:08:27 -0400
Received: from gingembre.fourcot.fr (unknown [95.91.99.240])
	(Authenticated sender: gingembre)
	by olfflo.fourcot.fr (Postfix) with ESMTPSA id 068BE2DFF0
	for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 00:03:23 +0200 (CEST)
Received: from [127.0.0.1] (localhost [127.0.0.1])
	by gingembre.fourcot.fr (Postfix) with ESMTP id 859D0401F6
	for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 00:03:22 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have this kind of configuration on my network:

----------                     -----------------
|        |=======  IPv6  ======|               |
| Client |                     |               |
|  A::1  |                     |               |
----------                     |               |
                                | IPSec Gateway |
-----------------              |               |
|  IPv4 Gateway |=IPv6 in IPv4=|               |
|  to Internet  |              |               |
-----------------              -----------------
     ||
     ||IPv6 in IPv4
     ||
-----------
| Client  |
|  B::2   |
-----------

The IPSec gateway has only one network card, i.e. unencrypted packet 
from the client come in eth0 and go out encrypted from eth0.

This work, but I get ICMP redirect like without IPSec encryption. A 
simplified tcpdump output give this:

IP6 A::1 > B::2: ICMP6, echo request
IP6 fe80::3 > A::1: ICMP6, redirect, B::2 to B::2
IP A.B.C.D > E.F.G.H: ESP(spi=0x3be56104,seq=0xa494)
IP E.F.G.H > A.B.C.D: ESP(spi=0xce300198,seq=0x1958b)
IP6 B::2 > A::1: ICMP6, echo reply


Of course, the redirect is invalid, since the remote address is not 
directly reachable. The kernel of the client complains with 
"rt6_redirect: source isn't a valid nexthop for redirect target".

I can disable acceptance of ICMP redirect on the client, but it does not 
look like a good solution (ICMP redirect still flood the network). Any 
idea to solve this?

Regards,

-- 
Florent Fourcot.
