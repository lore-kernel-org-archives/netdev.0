From: Matthias Urlichs <smurf@smurf.noris.de>
Subject: Re: TCP send/ack lockstep problem
Date: Sat, 2 Sep 2006 07:53:17 +0200
Message-ID: <20060902055317.GA5567@kiste.smurf.noris.de>
References: <eda9s9$bgq$1@sea.gmane.org> <E1GJLWk-0006P6-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smurf.noris.de ([192.109.102.42]:36785 "EHLO smurf.noris.de")
	by vger.kernel.org with ESMTP id S1750805AbWIBFy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2006 01:54:29 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1GJLWk-0006P6-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Herbert Xu:
> Matthias Urlichs <matthias@urlichs.de> wrote:
> > 
> > Any ideas? Is the sending program doing something stupid? If so, what?
> 
> Probably.  Since you're on the sender's side (192.109.x.x I presume) why
> don't you do a strace on the sending process and tell us?
> 
The stuff I see in there doesn't look stupid to me.

accept(...) = 216
setsockopt(216, SOL_IP, IP_TOS, [8], 4) = 0
setsockopt(216, SOL_TCP, TCP_NODELAY, [1], 4) = 0
setsockopt(216, SOL_SOCKET, SO_KEEPALIVE, [1], 4) = 0
followed by a bunch of "interactive" read() and write() calls, and then
a rather long sequence of 16384-byte writes (all of which end up being
partial because the send buffer size is 12k).

so if one of these is the cause for the observed lockstep behavior when
the send buffer is *full*, I'd consider that to be a bug.

Interestingly, the *sender* advertizes window that's (a bit more than) one MTU:

07:47:03.204939 IP (tos 0x38, ttl  64, id 41217, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.53138: . 167089:168505 (1416) ack 0 win 1424 <nop,nop,timestamp 218027038 834794727>

but that's the other direction -- is something in the kernel confused about
which window variable to use ??

-- 
Matthias Urlichs   |   {M:U} IT Design @ m-u-it.de   |  smurf@smurf.noris.de

-- 
VGER BF report: U 0.499405
