From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH] ucc_geth: Fix half-duplex operation for non-MII/RMII
 interfaces
Date: Thu, 25 Jun 2009 15:17:25 +0400
Message-ID: <20090625111725.GA30165@oksana.dev.rtsoft.ru>
References: <20090624174557.GA31479@oksana.dev.rtsoft.ru>
 <4A4306F2.3070909@mvista.com>
 <20090625070236.GA27711@oksana.dev.rtsoft.ru>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>,
	Kumar Gala <galak@kernel.crashing.org>,
	Li Yang <leoli@freescale.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: Mark Huth <mhuth@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ru.mvista.com ([213.79.90.228]:7853 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751084AbZFYLRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 07:17:23 -0400
Content-Disposition: inline
In-Reply-To: <20090625070236.GA27711@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 25, 2009 at 11:02:36AM +0400, Anton Vorontsov wrote:
[...]
> Of course, it could be that the root cause of the problems
> I observe is weird NIC on my host. Well, then QA team should
> have used the same broken NIC on their hosts. :-)
> 
> I can easily test it by interconnecting two targets though.
[...]
> Definitely. Though I'm out of ideas if it's NOT host-side issue.

Two boards interconnected work fine. eTSEC + SKY2 NIC also work
OK. I'll test some more NICs, known to not work is 3Com
Corporation 3c905C-TX/TX-M [Tornado] (rev 74).


After some netperf tests, statistic on a gianfar board:

# ethtool -S eth0 | grep -v ": 0"
NIC statistics:
     rx-dropped-by-kernel: 2
     tx-rx-64-frames: 52
     tx-rx-65-127-frames: 20668
     tx-rx-128-255-frames: 10343
     tx-rx-256-511-frames: 113
     tx-rx-512-1023-frames: 147
     tx-rx-1024-1518-frames: 45965
     rx-bytes: 45075782
     rx-packets: 50300
     rx-carrier-sense-error: 1
     rx-fragmented-frames: 7600
     tx-byte-counter: 27401677
     tx-packets: 34618
     tx-broadcast-packets: 3
     tx-deferral-packets: 5
     tx-single-collision-packets: 4039
     tx-multiple-collision-packets: 1943
     tx-excessive-collision-packets: 30
     tx-total-collision: 785


Thanks for the ideas, Mark.

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
