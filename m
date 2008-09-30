From: Riccardo Losselli <riccardo@e4a.it>
Subject: Problem on ipv6 side of the lan.
Date: Tue, 30 Sep 2008 17:26:46 +0200
Message-ID: <48E24536.5040508@e4a.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from io.e4a.it ([80.79.48.55]:32929 "EHLO io.e4a.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753426AbYI3PzO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2008 11:55:14 -0400
Received: from localhost (localhost [127.0.0.1])
	by io.e4a.it (Postfix) with ESMTP id 0CCA87005C
	for <netdev@vger.kernel.org>; Tue, 30 Sep 2008 15:48:20 +0000 (UTC)
Received: from io.e4a.it ([127.0.0.1])
	by localhost (io.e4a.i [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 29xAkA8ey+m0 for <netdev@vger.kernel.org>;
	Tue, 30 Sep 2008 15:48:14 +0000 (UTC)
Received: from [79.137.0.3] (unknown [79.137.0.3])
	by io.e4a.it (Postfix) with ESMTP id 8377A70083
	for <netdev@vger.kernel.org>; Tue, 30 Sep 2008 15:48:14 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all, i would like to request a hint to sort out a problem is driving 
me crazy since the last two days..
i'm running a small network of 8 linux boxes, each one of them acting as 
a router.
I used a /64 as peering lan, configured the network interfaces, set up 
the peerings and all went smooth for about one week.
Two days ago one of the machines rebooted, and since then i have a very 
strange behaviour of the network.
Network is made of box1,2,3,4,5,6,7 and box200, which is a xen machine 
hosted by box5, box4 really is a Mikrotik box...

"Box1" and "Box200" can reach all other boxes as expected.
"Box2" can reach all boxes except 4,5 and 6
"box3" can reach all boxes except 4,5 and 6
"box4" can reach box1 and 200 only
"box5" can reach box1 and 200 only
"box6" can reach box 1 and 200 only
"box7" can reach all boxes except 4,5 and 6

i tried to check with tcpdump, pinging box7 from box6.. what i get is, 
from box6
14:13:57.662327 IP6 xxxx:xxxx::6 > xxxx:xxxx::7: ICMP6, echo request, 
seq 234, length 64
as expected, but  no reply..

ip neighbor shows

xxxx:xxxx::7 dev eth0 lladdr 00:0e:0c:b8:70:a4 router REACHABLE

On box7 tcpdump i see no requests coming..

If i try to ping from box7 to box6 i get, on box7

16:21:14.891742 IP6 xxxx:xxxx::7 > xxxx:xxxx::6: ICMP6, echo request, 
seq 47, length 64

and on box6

14:19:51.765354 IP6 xxxx:xxxx::7 > 2001:4c00::6: ICMP6, echo request, 
seq 2, length 64
14:19:51.765366 IP6 xxxx:xxxx::6 > 2001:4c00::7: ICMP6, echo reply, seq 
2, length 64

but i can see no reply on box7

ip neig , on box 7 reports no entry for box6

xxxx:xxxx::6 dev eth2 lladdr 00:30:48:98:5d:84 DELAY

network interfaces are correct.

or... i can se the echo request on both boxes (when pinging from the 
box) and no reply (but no "unreachable" either)

I'm pretty confused, as the same boxes work with ipv4 without problems 
and worked pretty fine with ipv6 too for about one week.


Any hint?
Thank you very much,
ricky
