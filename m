From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Fri, 21 Jul 2006 02:59:08 +0400
Message-ID: <20060720225908.GA18362@ms2.inr.ac.ru>
References: <20060719131915.GA21942@ms2.inr.ac.ru> <20060720073223.GA15567@tservice.net.ru> <20060720164100.GA9213@ms2.inr.ac.ru> <20060720210849.GA28715@tservice.net.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:5855 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1030399AbWGTW7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2006 18:59:41 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20060720210849.GA28715@tservice.net.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Moving protocol (no matter if it is TCP or not) closer to user allows
> naturally control the dataflow - when user can read that data(and _this_
> is the main goal), user acks, when it can not - it does not generate
> ack. In theory

To all that I rememeber, in theory absence of feedback leads
to loss of control yet. The same is in practice, unfortunately.
You must say that window is closed, otherwise sender is totally
confused.


> There is one problem in your logic.
> RTT will not be so small, since acks are not sent when user does not
> read data.

It is arithmetics: rtt = window/rate.

And rto stays rounded up to 200 msec, unless you messed the connection
so hard that it is not alive. Check.


> > Simplify protocol, move all the processing (even memory copies) to softirq,
> > leave to user space only feeding pages to copy and you will have unbeatable
> > performance. Been there, done that, not with TCP of course, but if you do not
> > care about losses and ACK clocking and send an ACK once per window,
> > I do not see how it can spoil the situation.
> 
> Do you live in a perfect world, where user does not want what was
> requested?

All the time I am trying to bring you attention that you read to sink. :-)
At least, read to disk to move it a little closer to reality.
Or at least do it from terminal and press ^Z sometimes.


> > You deal with 80 byte packets, to all that I understand.
> > If you lose one cacheline per packet, it is a big problem.
> 
> So actual netchannels speed is even better? :)

atcp. If you get rid of netchannels, leave only atcp, the speed will
be at least not worse. No doubts.


> tell me, why we should keep (enabled) that redundant functionality?
> Because it can work better in some other places, and that is correct,
> but why it should be enabled then in majority of the cases?

Did not I tell you something like that? :-) Optimize real thing,
even trying to detect the situations when retransmissions are redundant
and eliminate the code.


> Let's draw the line.
...
> That was my opinion on the topic. It looks like neither you, nor me will
> not change our point of view about that right now :)

I agree. :)

Alexey
