From: Donald Becker <becker@scyld.com>
Subject: Re: Must dev->set_multicast_list() complete before returning?
Date: Wed, 2 Apr 2003 14:40:24 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0304021352440.1685-100000@beohost.scyld.com>
References: <3E8B0D43.2000003@pacbell.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Rask Ingemann Lambertsen <rask@sygehus.dk>, <linux-net@vger.kernel.org>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Brownell <david-b@pacbell.net>
In-Reply-To: <3E8B0D43.2000003@pacbell.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2 Apr 2003, David Brownell wrote:

> Donald Becker wrote:
> > 
> > I have not seen hardware where setting promiscuous mode is a queued
> > command.  If you have such hardware, you may have to do some extra
> > software filtering and accept missing some packets during transitions.
> 
> Every USB network adapter will need to queue such commands,
> unless they don't support such operations at all.  So you
> have probably seen such hardware, without realizing it!

Errrm, a previous message pointed out to me that there were several
other Intel chips that _I had written drivers for_ that queue commands.
And yes, I had also forgotten about bridged NICs such as USB (which I've
also written drivers for).

> I just looked ... none of them do any extra filtering.

I've not added extra filtering to any driver USB or otherwise.

It may be that there is a problem here that is rarely encountered and
never identified as a problem.  A filter change from promiscuous to
normal mode is at worst a narrow window.
The atp.c driver is special because it put the hardware into promiscuous
mode for allmulti, and thus any potential problem became a continuous
issue.

Alan, do you remember what piece of code had a problem with unicast
packets to other hosts that would normally be filtered out by the
hardware?  It may be that issue is gone with 2.4 and later kernels.
(Multicast is not an issue because most chips use an imperfect hash
filter and thus the kernel has always needed additional filtering.)

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Scyld Beowulf cluster system
Annapolis MD 21403			410-990-9993
