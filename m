From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP fast retransmit issues
Date: Wed, 26 Jul 2017 16:18:47 +0200
Message-ID: <20170726141847.GC1737@1wt.eu>
References: <200d9a12e9f2f5791d4c5ce2d47a1239@vsen.dk>
 <1501069756.12695.11.camel@edumazet-glaptop3.roam.corp.google.com>
 <a025f5b2ed6e1f287f68b6bb5137a988@vsen.dk>
 <1501075881.12695.15.camel@edumazet-glaptop3.roam.corp.google.com>
 <fd335e0a0c914b9c42a754da2d24b1c3@vsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Klavs Klavsen <kl@vsen.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:34239 "EHLO 1wt.eu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752094AbdGZOSu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 10:18:50 -0400
Content-Disposition: inline
In-Reply-To: <fd335e0a0c914b9c42a754da2d24b1c3@vsen.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 26, 2017 at 04:08:19PM +0200, Klavs Klavsen wrote:
> Grabbed on both ends.
> 
> http://blog.klavsen.info/fast-retransmit-problem-junos-linux (updated to new
> dump - from client scp'ing)
> http://blog.klavsen.info/fast-retransmit-problem-junos-linux-receiving-side
> (receiving host)

So bingo, Eric guessed right, the client's sequence numbers are translated
on their way to/from the server, but the SACK fields are not :

Server :
15:59:54.292867 IP (tos 0x8, ttl 64, id 15878, offset 0, flags [DF], proto TCP (6), length 64)
    192.168.32.44.22 > 62.242.222.50.35002: Flags [.], cksum 0xfe2b (incorrect -> 0xce0e), seq 1568063538, ack 3903858556,
    win 10965, options [nop,nop,TS val 529899820 ecr 774272020,nop,nop,sack 1 {3903859904:3903861252}], length 0

Client :
15:59:54.297388 IP (tos 0x8, ttl 56, id 15878, offset 0, flags [DF], proto TCP (6), length 64)
    192.168.32.44.22 > 62.242.222.50.35002: Flags [.], cksum 0xbb2c (correct), seq 1568063538, ack 2684453645,
    win 10965, options [nop,nop,TS val 529899820 ecr 774272020,nop,nop,sack 1 {3903859904:3903861252}], length 0

To there's very likely a broken firewall in the middle that is waiting for
a bug fix, or to have its feature disabled. Sometimes it can also happen
on firewalls performing some SYN proxying except that it would mangle the
server's sequence numbers instead of the client ones.

Willy
