From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH][RFC] Re: high latency with TCP connections
Date: Wed, 6 Sep 2006 02:13:28 +0400
Message-ID: <20060905221328.GA32293@ms2.inr.ac.ru>
References: <20060830100734.GA22235@isil.ipib.msu.ru> <20060904160045.GA15599@ms2.inr.ac.ru> <44FDBA04.3080104@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Vodomerov <alex@sectorb.msk.ru>, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:23515 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S965204AbWIEWOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2006 18:14:06 -0400
To: Rick Jones <rick.jones2@hp.com>
Content-Disposition: inline
In-Reply-To: <44FDBA04.3080104@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Is this really necessary?

No, of course. We lived for ages without this, would live for another age.



>			I thought that the problems with ABC were in 
> trying to apply byte-based heuristics from the RFC(s) to a 
> packet-oritented cwnd in the stack?

It was just the last drop.

Even with disabled ABC, that test shows some gaps in latency summed
up to ~300 msec. Almost invisible, but not good.

Too aggressive delack has many other issues. Even without ABC
we have quadratically suppressed cwnd on TCP_NODELAY connections
comparing to BSD: at sender side we suppress it by counting
cwnd in packets, at receiver side by ACKing by byte counter.

Each time when another victim sees artificial latencies introduced
by agressive delayed acks, even though he requested TCP_NODELAY,
our best argument is "Stupid, you do all wrong, how could you get
a decent performance?" :-). 

Probably, we stand for a feature which really does not worth
to stand for and causes nothing but permanent pain in ass.

Alexey
