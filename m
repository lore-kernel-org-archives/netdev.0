From: Thomas Habets <thomas@habets.pp.se>
Subject: Re: BUG: IPv6 stops working after a while, needs ip ne del command
 to reset
Date: Tue, 17 Aug 2010 20:52:27 +0200 (CEST)
Message-ID: <alpine.DEB.1.10.1008172035520.21857@red.crap.retrofitta.se>
References: <alpine.DEB.1.10.1008161224510.13728@red.crap.retrofitta.se> <alpine.DEB.1.10.1008170719180.21857@red.crap.retrofitta.se> <1282024802.2487.687.camel@edumazet-laptop> <alpine.DEB.1.10.1008171053230.21857@red.crap.retrofitta.se>
 <1282050920.2448.47.camel@edumazet-laptop> <alpine.DEB.1.10.1008171547090.21857@red.crap.retrofitta.se> <1282055659.2448.58.camel@edumazet-laptop> <alpine.DEB.1.10.1008171737260.21857@red.crap.retrofitta.se> <20100817171115.GA4134@mcarlson.broadcom.com>
 <alpine.DEB.1.10.1008171928160.21857@red.crap.retrofitta.se> <20100817183112.GA4351@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Thomas Habets <thomas@habets.pp.se>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from reptilian.habets.pp.se ([193.151.93.131]:2729 "EHLO
	reptilian.habets.pp.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932977Ab0HQSwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 14:52:35 -0400
In-Reply-To: <20100817183112.GA4351@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Aug 2010, Matt Carlson wrote:
> Thanks.  I put the question out to the firmware developer.  While we
> wait, can you keep Eric's patch in place and give me the results along
> with the output of 'ethtool -d eth0 | grep 0x047' after the problem
> happens?

Sure.

I think the problem occurs shortly after booting, or is triggered by it 
Linux getting a neighbor table entry for the router. The reason it took a 
while for everything to actually stop working is that the router was 
caching and presumably updating its neighbors cache when it saw traffic.

That is, maybe it only works if the router sets up its neigbor table 
first, and not otherwise.

The problem is there now. Last output in the kernel log about this is:

$ dmesg | egrep 'eth0|^add mc|^filters='
[...]
add mc_addr(ha->addr=33:33:00:00:00:01)
add mc_addr(ha->addr=01:00:5e:00:00:01)
add mc_addr(ha->addr=33:33:ff:5c:00:02)
add mc_addr(ha->addr=33:33:ff:a3:44:24)
filters=80020001 00000000 00000000 40000000

$ sudo ethtool -d eth0 | grep 0x047
0x0470	0x80020001
0x0474	0x00000000
0x0478	0x00000000
0x047c	0x40000000

> Eric's patch shows the hash registers at the time they are programmed.
> I'm interested to see if the values change (by firmware) after the
> failure.

Look the same.

But a strange thing is that if I delete the ipv6 neighbor on the Linux 
box (ip ne del 2a00:800:752:1::5c:1 dev eth0) it suddenly answers a ND 
solicitation. I tried it just now and it "wakes it up".

Nothing was written to the kernel log when I ran this command, and the 
ethtools -d output is the same afterwards as it was before. So unless 
there's another code path that changes the registers when I do "ip ne 
del" it may still be something else.

---------
typedef struct me_s {
   char name[]      = { "Thomas Habets" };
   char email[]     = { "thomas@habets.pp.se" };
   char kernel[]    = { "Linux" };
   char *pgpKey[]   = { "http://www.habets.pp.se/pubkey.txt" };
   char pgp[] = { "A8A3 D1DD 4AE0 8467 7FDE  0945 286A E90A AD48 E854" };
   char coolcmd[]   = { "echo '. ./_&. ./_'>_;. ./_" };
} me_t;
