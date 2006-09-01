From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: high latency with TCP connections
Date: Fri, 1 Sep 2006 13:47:15 +0400
Message-ID: <20060901094715.GB13855@ms2.inr.ac.ru>
References: <20060831151456.12a4e080@dxpl.pdx.osdl.net> <20060831.154428.35684218.davem@davemloft.net> <20060831232923.GA10036@ms2.inr.ac.ru> <20060831.165701.104033558.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, alex@sectorb.msk.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:61911 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1751374AbWIAJrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 05:47:47 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060831.165701.104033558.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> problem.  The problem is really at the receiver because we only
> ACK every other full sized frame.  I had the idea to ACK every 2
> frames, regardless of size,

This would solve lots of problems.


>			 but that might have other problems.

BSD used to do this, everyone is happy.

It could disclose some new problems in our stack, because we have
quite a lot of code to mitigate problems caused by ACK each 2*MSS.
But they should not be essential. Actually, we could have it adjustable:
normally each 2 frames, but apply efforts to coarsen ACKs up to 2*MSS,
when lots of small frames are ACKed back to back.


> There is an assymetry between how we do congestion control on
> sending (packet counting) and our ACK policy on receive (packet
> sized based).

It is curious fact: BSD has exactly opposite assymetry.
ACK are sent each second packet, but congestion avoidance is made by size. :-)


> turn it off by default.

Yes.

Alexey

