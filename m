From: Jamie Lokier <jamie@shareable.org>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover, performance.
Date: Wed, 14 May 2008 22:57:06 +0100
Message-ID: <20080514215704.GE23758@shareable.org>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org> <20080513205114.GA16489@2ka.mipt.ru> <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net> <20080514135156.GA23131@2ka.mipt.ru> <482B378C.5070807@garzik.org> <20080514193843.GB10165@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, Sage Weil <sage@newdream.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080514193843.GB10165@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> > Quite true, but IMO single-node performance is largely an academic 
> > exercise today.  What production system is run without backups or 
> > replication?
> 
> If cluster is made out of 2-3-4-10 machines, it does want to get maximum
> single node performance. But I agree that in some cases we have to
> sacrifice of something in order to find something new. And the larger
> cluster becomes, for more things we can close eyes on.

With the right topology and hardware, you can get _faster_ than single
node performance with as many nodes as you like, except when there is
a node/link failure and the network pauses briefly to reorganise - and
even that is solvable.

Consider:

    Client <-> A <-> B <-> C <-> D

A to D are servers.  <-> are independent network links.  Each server
has hardware which can forward a packet at the same time it's being
received like the best switches (wormhole routing), while performing
minor transformations on it (I did say the right hardware ;-)

Client sends a request message.  It is forwarded along the whole
chain, and reaches D with just a few microseconds of delay compared
with A.

All servers process the message, and produce a response in about the
same time.  However, (think of RAID) they don't all process all data
in the message, just part they are responsible for, so they might do
it faster than a single node would processing the whole message.

The aggregate response is a function of all of them.  D sends its
response.  C forwards that packet while modifying the answer to
include its own response.  B, A do the same.  The answer at Client
arrives just a few microseconds later than it would have with just a
single server.

If desired, arrange it in a tree to reduce even the microseconds.

Such network hardware is quite feasible, indeed quite easy with an
FPGA based NIC.

Enjoy the speed :-)

-- Jamie
