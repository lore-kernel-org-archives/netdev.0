From: John Heffner <jheffner@psc.edu>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Tue, 28 Sep 2004 08:53:03 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.NEB.4.33.0409280841400.23114-100000@dexter.psc.edu>
References: <4159117A.4010904@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, Andi Kleen <ak@suse.de>,
        <andy.grover@gmail.com>, <anton@samba.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <4159117A.4010904@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 28 Sep 2004, Nivedita Singhvi wrote:

> John Heffner wrote:
> >
> > More specifically, I think it is an interaction with delayed ack (acking
> > less than 1 virtual segment), and the small cwnd.  This works for me, but
> > I'm not sure that aren't some lurking problems still.
>
> In terms of what goes out over the wire from the
> sender, there is (or should be) no difference between
> the TSO and non-TSO case. The sequence of regular sized
> packets should be the same, and the only difference
> might be the delays between the frames, at most.
>
> So the sequence of acks coming back from the
> receiver should be the same, TSO and non-TSO case.
> If we've sent out say 44 1500MTU frames, we should
> probably see 22 acks back, roughly (acking every
> second packet if delayed acks are on) in both
> the TSO and non-TSO case.

I was referring to a problem I saw that had really terrible performance
(around 1 Mbit).  It would send out one virtual segment, and all but the
last of its real segments would be acked.  The receiver will wait for the
delayed ack timer to go off before acking the last segment, and the sender
will wait for that last segment to be acked before sending out the next
virtual segment if the cwnd is equal to 1 virtual segment.

Dave's patch seems to correct this problem for me, but I'm not convinced
this state could never occur.

  -John
