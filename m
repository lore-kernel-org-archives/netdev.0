From: Donald Becker <becker@scyld.com>
Subject: Re: NAPI-ized tulip patch against 2.4.20-rc1
Date: Wed, 6 Nov 2002 13:31:09 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0211061319220.13934-100000@beohost.scyld.com>
References: <3DC95631.6030001@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
   Jeff Garzik <jgarzik@mandrakesoft.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3DC95631.6030001@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 6 Nov 2002, Ben Greear wrote:

> >  I see you increased the RX-ring to 1024 pkts. 
> >  Did you really see any improvement with this?
> 
> It helped drop fewer packets when running 4 ports at 92Mbps+
> However, the difference between that and 512 is not large.

Using 512 Rx buffers at 100Mbps seem like a pretty silly default.

> I would really like to make that size adjustable at module load
> time and/or runtime, but I'm not sure how easy that would be.

It's trivial for many (but not all) drivers.
I've been considering doing that with my driver release.
There is no longer a CPU cycle cost issue with ring-wrapping on an
arbitrary ring size.

> Imagine being able to crank up your receive buffers when running at
> very high speeds (and/or when you start dropping packets).  At lower speeds,
> shrink things down and free up resources....

Being that dynamic involves writing code and extensive testing with all
of the different chips.

The trivial case is a module option that sets a variable replacing
RX_RING_SIZE / TX_RING_SIZE..
The passed-in value shouldn't be used directly:
 - many drivers have upper and lower bounds
 - the size can only be changed when the rings are initialized,
   which occurs when the interface starts.
 - users thinking "if 32 is good, 32000 is better"

> >  Also I would be interested if you have any numbers for recycling patch? 

interest++

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Scyld Beowulf cluster system
Annapolis MD 21403			410-990-9993
