From: Donald Becker <becker@scyld.com>
Subject: Re: NAPI-ized tulip patch against 2.4.20-rc1
Date: Wed, 6 Nov 2002 15:47:43 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0211061458310.13934-100000@beohost.scyld.com>
References: <3DC96301.7070602@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3DC96301.7070602@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 6 Nov 2002, Ben Greear wrote:

> > The trivial case is a module option that sets a variable replacing
> > RX_RING_SIZE / TX_RING_SIZE..
> > The passed-in value shouldn't be used directly:
> >  - many drivers have upper and lower bounds
> >  - the size can only be changed when the rings are initialized,
> >    which occurs when the interface starts.
> 
> So, adjusting the ring size would require stopping and starting the
> NIC?  Is that a full bounce (including auto-negotiation)?

Most chips do not require bouncing the link when the interface is cycled
down/up.  That's not to say that some drivers don't reset the link --
it's easier for the driver writer to write the code that way, and doing
the link reset can mask other problems.

> >  - users thinking "if 32 is good, 32000 is better"
> 
> The sad truth is, most NICs/drivers do not perform at high
> speeds w/out hacking them in various ways.  Where to lay the
> blame (VM, shitty hardware, etc) is debatable, but it doesn't
> change the results.  I do know that 1024 is better than 32 for
> high speeds on muliple ports, on my NICs.

I can see that changing the parameters is a quick, ad hoc solution.
This list should focus on identifying the problems, rather than just
patching in work-arounds.

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Scyld Beowulf cluster system
Annapolis MD 21403			410-990-9993
