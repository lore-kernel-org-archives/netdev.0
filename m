From: Thayne Harbaugh <tharbaugh@lnxi.com>
Subject: RE: [PATCH] abysmal e1000 performance (DITR)
Date: Mon, 30 Aug 2004 11:06:46 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1093885606.20769.235.camel@tubarao>
References: <468F3FDA28AA87429AD807992E22D07EAF76C5@orsmsx408>
Reply-To: tharbaugh@lnxi.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, hadi@cyberus.ca,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>, netdev@oss.sgi.com,
        "Feldman, Scott" <scott.feldman@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Ronciak, John" <john.ronciak@intel.com>
In-Reply-To: <468F3FDA28AA87429AD807992E22D07EAF76C5@orsmsx408>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-08-27 at 15:41 -0700, Ronciak, John wrote:
> Thayne,
> 
> I can't speak to what happened previously, only what's going on now.
> You need to be careful about basing any tuning on any one single test.
> For each one of these test you find that have performance problems I can
> show you where it works just fine and most cases works better.  So let
> be careful about making judgements like this.

I would agree with you if the problem was only apparent with a
benchmark.  The incident that started the investigation was due to real-
world workloads on a cluster - a newer cluster that should have been
significantly faster, but was many times slower than an older cluster.
That is why customers can't use the e1000 with the stock 5.x e1000
driver (or without changing the DITR value as a module option).  When
the default setup is anywhere from 10 to 30 percent of the expected
performance then it becomes very difficult to justify shipping a NIC
that will likely be incorrectly configured when the driver or kernel is
changed - too many support problems.

I see that as a wise judgment based on the real usage patterns of
customers - not a knee-jerk reaction based on a simplistic benchmark.
At the time that I investigated this problem I looked at other
benchmarks that *didn't* exhibit this problem.  The question was why our
customers had this problem but it didn't show up when we tested the
cluster.

It's a perfect example of the classic problem: benchmarks aren't always
representative of real-world loads.  This is a case where a real-world
load exposed a deficiency of the driver - a deficiency that wasn't
exposed by benchmarks but becomes quite obvious when the driver is
scrutinized and understood.

> We are going to look at this and make some changes based on what we
> find.

Wonderful.

>   I already said that we probably won't be ripping out the DITR as
> some people really make a lot of use out of it.

That's what I'm hoping you can help me with: why is DITR so useful?  I
just can't see why:

NAPI does the same thing and can work with *any* card (provided the
driver is written correctly).  I'd much rather deal with something
universal than have to deal with something unique to a card.

The DITR algorithm doesn't consider packet backlog nor system load.  Why
reduce the interrupt rate when the load is low?  When the interrupt rate
is reduced when the load is low then unnecessary latency is added.  The
DITR may work fine with an old system with an e1000, but a dual Opteron
with an e1000 has plenty of horsepower to perform calculations *and*
push packets.  For DITR to correctly work, it needs to consider much
more than the number of packets received and transmitted - the current
algorithm is overly simplistic (it also doesn't correctly consider
symmetric vs asymmetric receive/transmit loads).

Please provide details so that I can become one of those that can ". . .
make a lot of use out of [DITR]."

> It may be off by
> default or have some default setting which doesn't hurt test cases.

What about settings that don't hurt real-world fluid dynamics
calculations?  I couldn't care less about benchmarks that aren't
representative of the real-world load.  The Netpipe program was used
because it reasonably resembles the traffic flow of real-world cases
that didn't work with DITR.  Netpipe is much easier to provide and
configure than a fluid dynamics cluster program that would necessitate
licensing and other infrastructure for use as a testing tool.

> Since Netpipe is a relatively unused test for performance (not really
> it's purpose, it was developed to find "holes" in internet packets
> lengths), it's not part of our normal testing.

Well, maybe I can interest you in buying a small cluster with some fluid
dynamics software that has packet flow similar to what Netpipe produces?

> Like I said, we are looking at it and will come up with a more robust
> solution.

Wonderful.  I hope you can find a good solution.  I do prefer being able
to use all those e1000 NICs rather than replace them.  Yes, really.  I
significantly prefer using good products that perform as expected than
spending my time whining, complaining and carrying on.  Yes, really, I
prefer to have happy customers, happy vendors and be happy myself.  I
only bring this up because I care and I hope someone else cares, and I
want everyone to get back to being happy.
