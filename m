From: Cheng Jin <chengjin@cs.caltech.edu>
Subject: RE: TxDescriptors -> 1024 default. Please not for every NIC!
Date: Wed, 2 Jun 2004 12:49:24 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0406021235200.17290-100000@fast2.cs.caltech.edu>
References: <Pine.LNX.4.58.0406022102360.1474@fcat>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Marc Herbert <marc.herbert@free.fr>
In-Reply-To: <Pine.LNX.4.58.0406022102360.1474@fcat>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Marc,

In general, I very much agree with what you have stated about not having
a large txqueuelen.  Txqueuelen should be something that alleviates
the mismatch between CPU speed and NIC transmission speed, temporarily.
As long as the txqueuelne is greater than zero, say 10 just to be safe,=20
NIC will be running at full speed (unless there were inefficiencies in=20
scheduling) so there is no incentive in setting it to be an excessively=20
large value like 1000.

> > I'm not sure that you could actually get the problem to occur on 100
> > or 10Mb/s hardware however because of TCP window size limitation and

With today's CPU, I think you will be able to fill up the txqueuelen
on a 10 or 100 Mbps NIC, assuming there is a large file transfer and
large window size and stuff. =20

> If there is a real-world, distance-caused latency between S and R,
> then having some equivalent amount of buffering in txqueuelen helps
> average performance, because the interface has then a backlog of
> packets to send while TCP takes time to ramp up its congestion window
> again a decrease, the former compensating the latter. (This may be
> what the e1000 guys observed in the first place, motivating the
> increase to 1000=A0? After all, 1.2ms of buffering was small) The
> txqueue may smooth the sawtooth evolution of TCP congestion window,
> minimizing the interface idle time.  But increased perceived latency
> is the price to pay for this nice damper. There is a tradeoff between
> latency and TCP=A0throughput _on wide area_ routes to tune here, but
> pushing it as far as storing in txqueuelen _multiple_ times any
> real-world latency (did I say "1.2s" already?) brings no benefit at
> all for throughput; it's just terribly harmful for perceived latency.
> No IP router does so much buffering. Besides linux :-> I don't think
> IP queues should be sized to cope with moon-earth latency by default.

Very much agree with this paragraph.  As long as the buffer is more
than one bandwidth delay product, for a single TCP flow, window halving=20
after each loss will still sustain a large enough window to maintain=20
packets in the buffer to have full utilization.  The downside is exactly
what Marc said, very very large queueing delay for a long time.

Going back to what Marc said in an earlier e-mail about having txqueuelen=
=20
in the unit of bytes rather than packets to provide a fixed queueing=20
delay in ms rather than packets.  Maintaining txqueuelen in ms would be
an ideal solution, but probably hard to achieve in practice.

Keeping txqueuelen in bytes may be a problem for senders that=20
wants to send many small pacekts.  While the byte count may be small, the=
=20
overhead of sending small packets may introduce large delays. =20

Cheng
