From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Wed, 19 Jul 2006 17:19:15 +0400
Message-ID: <20060719131915.GA21942@ms2.inr.ac.ru>
References: <20060718081625.GA13830@2ka.mipt.ru> <20060718230121.GA31474@ms2.inr.ac.ru> <20060719053841.GA24744@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:46501 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S964800AbWGSNXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2006 09:23:11 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20060719053841.GA24744@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> There is no socket spinlock anymore.
> Above lock is skb_queue lock which is held inside
> skb_dequeue/skb_queue_tail calls.

Lock is named differently, but it is still here.
BTW for UDP even the name is the same.

 
> > Equivalent of socket user lock.
> 
> No, it is an equivalent for hash lock in socket table.

OK. But you have to introduce socket mutex somewhere in any case.
Even in ATCP.


> Just an example - tcp_established() can be called with bh disabled under
> the socket lock.

When we have a process context in hands, it is not.

Did you ask youself, why do not we put all the packets to backlog/prequeue
and just wait when user will read the data? It would be 100% equivalent
to "netchannels".

The answer is simple: because we cannot wait. If user delays for 200msec,
wait for connection collapse due to retransmissions. If the segment is
out of order, immediate attention is required. Any scheme, which tries
to wait for user unconditionally, at least has to run a watchdog timer,
which fires before sender senses the gap.

And this is what we do for ages. Grep for "VJ" in sources. :-)

netchannels have nothing to do with it, it is much elder idea.



> In that case one copies the whole data into userspace, so access for 20
> bytes of headers completely does not matter.

For short packets it matters.

But I said not this. I said it looks _worse_. A bit, but worse.


> Hmm, for 80 bytes sized packets win was about 2.5 times. Could you
> please show me lines inside existing code, which should be commented, so
> I got 50Mbyte/sec for that?

If I knew it would be done. :-)

Actually, it is the action, which I would expect. This, but
not dropping all the TCP stack.


> I showed there, that using existing stack it is imposible

Please, understand, it is such statements that compromise your work.
If it is impossible then it is not interesting.

Alexey
