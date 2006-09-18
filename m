From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH][RFC] Re: high latency with TCP connections
Date: Tue, 19 Sep 2006 00:41:05 +0400
Message-ID: <20060918204105.GA31333@ms2.inr.ac.ru>
References: <20060830100734.GA22235@isil.ipib.msu.ru> <20060904160045.GA15599@ms2.inr.ac.ru> <44FDBA04.3080104@hp.com> <20060918.003938.26278728.davem@davemloft.net> <450ED337.8000700@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, alex@sectorb.msk.ru,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:16294 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S964959AbWIRUlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2006 16:41:49 -0400
To: Rick Jones <rick.jones2@hp.com>
Content-Disposition: inline
In-Reply-To: <450ED337.8000700@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

Of course, number of ACK increases. It is the goal. :-)


> unpleasant increase in service demands on something like a "burst 
> enabled" (./configure --enable-burst) netperf TCP_RR test:
> 
> netperf -t TCP_RR -H foo -- -b N   # N > 1

foo=localhost

b	patched		orig
2	105874.83	105143.71
3	114208.53	114023.07
4	120493.99	120851.27
5	128087.48	128573.33
10	151328.48	151056.00

Probably, the test is done wrong. But I see no difference.


> to increase as a result.   Pipelined HTTP would be like that, some NFS 
> over TCP stuff too, maybe X traffic,

X will be excited about better latency.

What's about protocols not interested in latency, they will be a little
happier, if transactions are processed asynchronously.

But actually, it is not about increasing/decreasing number of ACKs.
It is about killing that pain in ass which we used to have because
we pretended to be too smart.

Alexey
