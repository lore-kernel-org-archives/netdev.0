From: Valentijn Sessink <valentyn@blub.net>
Subject: IPv6 path discovery oddities - flushing the routing cache resolves
Date: Wed, 16 Oct 2013 12:31:31 +0200
Message-ID: <525E6B03.1040409@blub.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.openoffice.nl ([95.97.76.242]:40243 "EHLO
	openoffice.kantoor.openoffice.nl" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1760286Ab3JPKkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 06:40:23 -0400
Received: from [192.168.112.50] (stout.kantoor.openoffice.nl [192.168.112.50])
	by openoffice.kantoor.openoffice.nl (Postfix) with ESMTP id 8599DC0019
	for <netdev@vger.kernel.org>; Wed, 16 Oct 2013 12:31:31 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello list,

I'm experiencing difficulties with IPv6 path discovery. The setup is 
quite simple, a machine with native IPv6, no special routing - let's 
call it the "server" for now. Unfortunately, I seem to loose 
connectivity multiple times a day - and after digging in, I found this 
to be "too big" messages that weren't honored at the server. The network 
consists of something like:

server --- hosting --- others ---- SIXXS tunnel with 1280 MTU --- me.

A "ip -6 route list cache" would show a cached route to my "client", but 
one without MTU. Then after "ip -6 route flush cache", and after trying 
to send a large packet (for example issuing "ps uaxww" on an ssh 
prompt), "ip -6 route list cache" will show a correct MTU.

But after a while, things start to go wrong again, and another "ip -6 
route flush cache" is needed.

The server is running 3.8.0-something (ubuntu 12.04 with a newer kernel).

tcpdump shows that on reception of icmpv6 "too big", nothing happens 
(i.e. the "too big" packet will be sent time and again), and after the 
"ip -6 route flush cache", suddenly the "too big" message is honored.

I saw a couple of path discovery issues on this list, more specifically 
one with the subject "IPv6 path MTU discovery broken" earlier this month 
- but I'm not sure it's the same issue (because the original submitter 
specifically mentions kernels 3.10 and 3.11 and has a much more 
complicated routing table).

The "server" just has:

auto br0
iface br0 inet6 static
   address 2a01:xxxx:xxx:xxxx::2
   netmask 64
   gateway fe80::1
   bridge_ports eth0
   bridge_maxwait 0

Nothing special, no special routes, no routing daemons.

If I can do anything to shine more light on this issue, please tell me so.

Best regards,

Valentijn
