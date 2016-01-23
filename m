From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: fix mv88e6xxx switches
Date: Sat, 23 Jan 2016 21:16:47 +0100
Message-ID: <20160123201647.GH3880@lunn.ch>
References: <E1aMvmm-0006G3-8T@rmk-PC.arm.linux.org.uk>
 <20160123181526.GD3880@lunn.ch>
 <20160123190622.GA10826@n2100.arm.linux.org.uk>
 <20160123193705.GE3880@lunn.ch>
 <20160123194856.GB10826@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41367 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754956AbcAWURD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jan 2016 15:17:03 -0500
Content-Disposition: inline
In-Reply-To: <20160123194856.GB10826@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 23, 2016 at 07:48:57PM +0000, Russell King - ARM Linux wrote:
> On Sat, Jan 23, 2016 at 08:37:05PM +0100, Andrew Lunn wrote:
> > I'm testing on a 6172. But 6172 and 6176 are both in the same family
> > 6352, and share the same driver.
> 
> Hmm, can't be that then.
> 
> > So you initially have lan1 in an bridge. I don't.

Running tcpdump on the device i'm trying to ping, there are ARP
requests and replies. But the replies are never received by the
target, arp -a shows <incomplete>.

Looking at the stats counters in debugfs, the packets are counted in
in_unicast, but also sw_in_filtered.

Port 0 is lan0 and port 5 is the cpu port.

root@370-rd:/sys/kernel/debug/dsa0# cat regs
    GLOBAL GLOBAL2 SERDES   0    1    2    3    4    5    6  
 0:  c874       0    1940  1d0f 1d0f 1d0f 1d0f 100f  e07    6 
 1:   fa0       0     149     3    3    3    3    3 c03e    3 
 2:   fa0    ffff     141     0    0    0    0    0    0    0 
 3:     0    ffff     ea1  1721 1721 1721 1721 1721 1721 1721 
 4:  6000     258     1e0   433  433  433  433  433 373f  433 
 5:  3000      ff       0     0    0    0    0    0    0    0 
 6:   fa0    1f0f       4    7f   7e   7d   7c   7b   7a   79 
 7:  3331    707f    2001     0  fa1  fa2  fa3  fa4    0  fa6 
 8:   303    7800       0  2c80 2c80 2c80 2c80 2c80 2c80 2c80 
 9:     0    1600       0     1    1    1    1    1    1    1 
 a:   148       0       0     0    0    0    0    0    0    0 
 b:  2000    1000       0     1    2    4    8   10 2000   40 
 c:   f0f      7f       0     0    0    0    0    0    0    0 
 d:     0     5f1       3     0    0    0    0    0    0    0 
 e:     0       0       0     0    0    0    0    0    0    0 
 f:     0     f00    c000  dada dada dada dada dada dada dada 
10:     0       0    4005     0    0    0    0    0    0    0 
11:     0       0    8000     0    0    0    0    0    0    0 
12:  5555       0       0    12    0    0    0    0    8    0 
13:  5555       0       0     0    0    0    0    0   22    0 
14:  aaaa     400       0     0    0    0    0    0    0    0 
15:  aaaa       0       0     0    0    0    0    0    0    0 
16:  ffff       0       1  700f 7002 7004 7008   33   33    0 
17:  ffff       0       0     0    0    0    0    0    0    0 
18:  fa41    15f6       0  3210 3210 3210 3210 3210 3210 3210 
19:     0       0       0  7654 7654 7654 7654 7654 7654 7654 
1a:  5550       0      42     0    0    0    0    0    0    0 
1b:   1fa    f869       0  8000 8000 8000 8000 8000 8000 8000 
1c:     0       0       0     0    0    0    0    0    0    0 
1d:  5ce0       0       0     0    0    0    0    0    0    0 
1e:     0       0       0     0    0    0    0    0    0    0 
1f:     0       0       0     0    0    0    0    0    0    0 

	Andrew
