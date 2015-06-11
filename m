From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: ssh connections hanging on 4.1rc7
Date: Thu, 11 Jun 2015 15:39:28 -0400
Message-ID: <20150611193928.GA20774@codemonkey.org.uk>
References: <20150611174618.GA30268@codemonkey.org.uk>
 <1434047061.27504.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:32810 "EHLO
	arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218AbbFKTjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 15:39:37 -0400
Content-Disposition: inline
In-Reply-To: <1434047061.27504.40.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 11, 2015 at 11:24:21AM -0700, Eric Dumazet wrote:
 
 > > Just hit this weird problem where I can ssh into a machine once,
 > > then after logging out, subsequent ssh connections hang.
 >  
 > Your tcpdumps look one way only.

ok hit it again, so let's try again...

client side:

15:34:10.184012 IP wopr.kernelslacker.org.44268 > gelk.kernelslacker.org.ssh: Flags [.], ack 1505519347, win 229, options [nop,nop,TS val 84312472 ecr 26272557], length 0
15:34:10.210704 IP wopr.kernelslacker.org.44268 > gelk.kernelslacker.org.ssh: Flags [.], ack 33, win 229, options [nop,nop,TS val 84312499 ecr 26272584], length 0
15:34:10.218178 IP wopr.kernelslacker.org.44268 > gelk.kernelslacker.org.ssh: Flags [P.], seq 2000:2048, ack 985, win 243, options [nop,nop,TS val 84312506 ecr 26272587], length 48
15:34:10.248332 IP wopr.kernelslacker.org.44268 > gelk.kernelslacker.org.ssh: Flags [P.], seq 2048:2064, ack 1265, win 258, options [nop,nop,TS val 84312536 ecr 26272614], length 16
15:34:10.288172 IP gelk.kernelslacker.org.ssh > wopr.kernelslacker.org.44268: Flags [.], ack 2064, win 257, options [nop,nop,TS val 26272662 ecr 84312536], length 0
15:34:10.328516 IP wopr.kernelslacker.org.44268 > gelk.kernelslacker.org.ssh: Flags [.], ack 1309, win 258, options [nop,nop,TS val 84312617 ecr 26272662], length 0
<ctrl-c>
15:34:27.693304 IP wopr.kernelslacker.org.44268 > gelk.kernelslacker.org.ssh: Flags [.], ack 1310, win 258, options [nop,nop,TS val 84329981 ecr 26290067], length 0

server side:

15:34:10.188611 IP wopr.kernelslacker.org.44268 > gelk.kernelslacker.org.ssh: Flags [S], seq 2139969123, win 29200, options [mss 1460,sackOK,TS val 84312472 ecr 0,nop,wscale 7], length 0
15:34:10.188777 IP gelk.kernelslacker.org.ssh > wopr.kernelslacker.org.44268: Flags [S.], seq 1505519346, ack 2139969124, win 28960, options [mss 1460,sackOK,TS val 26272557 ecr 84312472,nop,wscale 7], length 0
15:34:10.189033 IP wopr.kernelslacker.org.44268 > gelk.kernelslacker.org.ssh: Flags [.], ack 1, win 229, options [nop,nop,TS val 84312472 ecr 26272557], length 0
15:34:10.189534 IP wopr.kernelslacker.org.44268 > gelk.kernelslacker.org.ssh: Flags [P.], seq 1:33, ack 1, win 229, options [nop,nop,TS val 84312473 ecr 26272557], length 32
15:34:10.189636 IP gelk.kernelslacker.org.ssh > wopr.kernelslacker.org.44268: Flags [.], ack 33, win 227, options [nop,nop,TS val 26272558 ecr 84312473], length 0
15:34:10.215507 IP gelk.kernelslacker.org.ssh > wopr.kernelslacker.org.44268: Flags [P.], seq 1:33, ack 33, win 227, options [nop,nop,TS val 26272584 ecr 84312473], length 32
15:34:10.215700 IP wopr.kernelslacker.org.44268 > gelk.kernelslacker.org.ssh: Flags [.], ack 33, win 229, options [nop,nop,TS val 84312499 ecr 26272584], length 0
15:34:10.216834 IP wopr.kernelslacker.org.44268 > gelk.kernelslacker.org.ssh: Flags [P.], seq 33:2001, ack 33, win 229, options [nop,nop,TS val 84312500 ecr 26272584], length 1968
15:34:10.216938 IP gelk.kernelslacker.org.ssh > wopr.kernelslacker.org.44268: Flags [.], ack 2001, win 257, options [nop,nop,TS val 26272585 ecr 84312500], length 0
15:34:10.218280 IP gelk.kernelslacker.org.ssh > wopr.kernelslacker.org.44268: Flags [P.], seq 33:985, ack 2001, win 257, options [nop,nop,TS val 26272587 ecr 84312500], length 952
15:34:10.223192 IP wopr.kernelslacker.org.44268 > gelk.kernelslacker.org.ssh: Flags [P.], seq 2001:2049, ack 985, win 243, options [nop,nop,TS val 84312506 ecr 26272587], length 48
15:34:10.245469 IP gelk.kernelslacker.org.ssh > wopr.kernelslacker.org.44268: Flags [P.], seq 985:1265, ack 2049, win 257, options [nop,nop,TS val 26272614 ecr 84312506], length 280
15:34:10.253331 IP wopr.kernelslacker.org.44268 > gelk.kernelslacker.org.ssh: Flags [P.], seq 2049:2065, ack 1265, win 258, options [nop,nop,TS val 84312536 ecr 26272614], length 16
15:34:10.293038 IP gelk.kernelslacker.org.ssh > wopr.kernelslacker.org.44268: Flags [.], ack 2065, win 257, options [nop,nop,TS val 26272662 ecr 84312536], length 0
15:34:10.293210 IP wopr.kernelslacker.org.44268 > gelk.kernelslacker.org.ssh: Flags [P.], seq 2065:2109, ack 1265, win 258, options [nop,nop,TS val 84312576 ecr 26272662], length 44
15:34:10.293313 IP gelk.kernelslacker.org.ssh > wopr.kernelslacker.org.44268: Flags [.], ack 2109, win 257, options [nop,nop,TS val 26272662 ecr 84312576], length 0
15:34:10.293487 IP gelk.kernelslacker.org.ssh > wopr.kernelslacker.org.44268: Flags [P.], seq 1265:1309, ack 2109, win 257, options [nop,nop,TS val 26272662 ecr 84312576], length 44
15:34:10.333528 IP wopr.kernelslacker.org.44268 > gelk.kernelslacker.org.ssh: Flags [.], ack 1309, win 258, options [nop,nop,TS val 84312617 ecr 26272662], length 0
<ctrl-c>
15:34:27.693322 IP wopr.kernelslacker.org.44268 > gelk.kernelslacker.org.ssh: Flags [F.], seq 2109, ack 1309, win 258, options [nop,nop,TS val 84329976 ecr 26272662], length 0
15:34:27.698094 IP gelk.kernelslacker.org.ssh > wopr.kernelslacker.org.44268: Flags [F.], seq 1309, ack 2110, win 257, options [nop,nop,TS val 26290067 ecr 84329976], length 0
15:34:27.698293 IP wopr.kernelslacker.org.44268 > gelk.kernelslacker.org.ssh: Flags [.], ack 1310, win 258, options [nop,nop,TS val 84329981 ecr 26290067], length 0


 > Could this be some routing or mtu problem ?

Same mtu on both, no fancy routing. Both on same 192.168.42.x subnet
plugged into the same dumb 1Gb switch

The only unusual thing is that the client side is running bonding (bond-mode 0)
I'll take that out of the equation to rule it out when I get home.

	Dave
