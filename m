From: Esben Nielsen <simlo@phys.au.dk>
Subject: Re: [patch 1/9] arcnet fixes
Date: Fri, 29 Oct 2004 16:46:28 +0200 (METDST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.OSF.4.05.10410291603000.5037-100000@da410.ifa.au.dk>
References: <20041028164111.5ffaca70.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: akpm@osdl.org, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20041028164111.5ffaca70.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 28 Oct 2004, David S. Miller wrote:

> On Thu, 28 Oct 2004 00:19:38 -0700
> akpm@osdl.org wrote:
> 
> I don't know what to do with this kind of thing.
> Jeff, what do you think?  Do we have anyone in any
> way active with Arcnet other than this guy?
>

I know others probably haven't used ArcNet under the 2.6 kernel lately
since it was completely broken in 2.6.8.1 (fixed in 2.6.9) and have been
for some time when I try to trace it back. This means this patch will have
a hard time breaking anything for anybody! It does fix the preemptive
problem. I have even used it under Igno Molnar's realtime-patch which must
be the ultimate check for preemptiveness :-)

Seen from the Linux community point of view: The patch can't hurt anybody
but ArcNet users but add to the value of Linux. There are very few people
using these drivers and all the rest can just ignore them (especially if
the below mistake is fixed *blush*) The more drivers Linux has the more
attractive Linux is when you have to pick an OS. In fact I am telling
others at work about how it only took me 2 hours to make ArcNet run under
Linux on our StrongARM processor board whereas it took my co-worker
month to make an driver for the commercial OS we usually run on the
boards :-) (Ofcourse making the patch isn't included in the 2 hours.)

> One problem with the patch though.
> 
> > diff -puN include/linux/if_ether.h~arcnet-fixes include/linux/if_ether.h
> > --- 25/include/linux/if_ether.h~arcnet-fixes	2004-10-28 00:17:07.230704752 -0700
> > +++ 25-akpm/include/linux/if_ether.h	2004-10-28 00:17:07.247702168 -0700
> > @@ -91,6 +91,7 @@
> >  #define ETH_P_IRDA	0x0017		/* Linux-IrDA			*/
> >  #define ETH_P_ECONET	0x0018		/* Acorn Econet			*/
> >  #define ETH_P_HDLC	0x0019		/* HDLC frames			*/
> > +#define ETH_P_ARCNET	0x0020		/* ArcNet			*/
> 
> You should use 0x001a or similar, so you don't have
> to do this next part of your patch, bumping NPROTO
> in net.h
> 

Doh! I can't count in hex it seems. This would probably also mean I won't
have to recompile the whole kernel but just the modules and I don't have 
to reboot to make it work on a new machine - but just until somebody else
picks the same protocol number ofcourse.

Do I have to fix the problem and resubmit? The number does itself
does ofcourse matter to me - it is just used to avoid listening to
ETH_P_ALL such the IP-frames are filtered out on the raw-socket I used to
connect to user-space.

Esben (="this guy":-)

> [...]
