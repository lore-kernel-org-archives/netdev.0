From: John Fraizer <atm@EnterZone.Net>
Subject: Re: [Linux-ATM-General] Neighbor Table Overflow? (fwd)
Date: Fri, 29 Aug 2003 18:24:57 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.21.0308291823440.4766-100000@Overkill.EnterZone.Net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


It would appear that there is a bug in part of the linux IP stack.  I was
told that this might be the correct address to send the information to
regarding tickling the bug.

---
John Fraizer              | High-Security Datacenter Services |
President                 | Dedicated circuits 64k - 155M OC3 |
EnterZone, Inc            | Virtual, Dedicated, Colocation    |
http://www.enterzone.net/ | Network Consulting Services       |


---------- Forwarded message ----------
Date: Fri, 29 Aug 2003 10:26:23 -0400 (EDT)
From: John Fraizer <atm@EnterZone.Net>
To: Mike Westall <westall@cs.clemson.edu>
Cc: Linux-atm-general <linux-atm-general@lists.sourceforge.net>
Subject: Re: [Linux-ATM-General] Neighbor Table Overflow?

Perhaps someone can pass this up to the right people who do the IP
stack.  It would appear to be a bug.


---
John Fraizer              | High-Security Datacenter Services |
President                 | Dedicated circuits 64k - 155M OC3 |
EnterZone, Inc            | Virtual, Dedicated, Colocation    |
http://www.enterzone.net/ | Network Consulting Services       |


On Fri, 29 Aug 2003, Mike Westall wrote:

> The interactions between routing and arp are somewhat
> complex. This problem seems to have been triggered by
> an attempt to route the sunk packets.  The message
> "overflow" message is issued by rt_intern_hash which
> calls arp_bind_neighbour()
> 
>    634    if (rt->rt_type == RTN_UNICAST || rt->key.iif == 0) {
>    635       int err = arp_bind_neighbour(&rt->u.dst);
> 
> Apparently arp_bind_neighbour() fails to check for the
> NOARP condition.
> 
> 
> John Fraizer wrote:
> 
> 
> > Well, in the face of the local microsoft exploits and the worm effects on
> > the arp caches of many layer-3 switches and access concentrators, that
> > doesn't terribly surprise me.  I figured this might be the case but, I
> > wasn't sure.  The strange part is that "arp -n" doesn't show too aweful
> > many entries total.  With the typical backscatter we see 24x7 on the net,
> > I'll always see a few "incomplete" entries in the arp cache.
> > 
> > The machine in question has a /27 bound up on lec0, a couple of /30's on
> > GigE interfaces and a /32 "loopback" address bound up on dummy0.
> > 
> > I do have a sinkhole route for a /19 destined to dummy0.  Is it possible
> > that the stack is still trying to do ARP when a packet arrives for an
> > address in the /19 that doesn't have a more specific route in our IGP and
> > it gets dumped to dummy0?
> > 
> > The interface shows:
> > 
> > 4: dummy0: <BROADCAST,NOARP,UP> mtu 1500 qdisc noqueue
> >     link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
> > 
> > 
> > I just removed the static sinkhole route from that route and started
> > sinking that traffic (traffic destined for addresses we don't have bound
> > up yet) on one of our core routers and the messages went away.
> > 
> > Strange that we would fill the arp cache sinking "garbage" traffic to a
> > dummy interface that is set NOARP.
> > 
> > Can anyone explain this to me?
> > 
> > I appreciate it!
> > 
> > ---
> > John Fraizer              | High-Security Datacenter Services |
> > President                 | Dedicated circuits 64k - 155M OC3 |
> > EnterZone, Inc            | Virtual, Dedicated, Colocation    |
> > http://www.enterzone.net/ | Network Consulting Services       |
> > 
> > 
> > On Thu, 28 Aug 2003, Mike Westall wrote:
> > 
> > 
> >>Appears to be generated because the ARP cache is full.
> >>Since the size limits there default to 512 and 1024 entries
> >>that would be pretty unusual in most environments unless
> >>something else was screwed up in some major way.
> >>
> >>Hard to say what the something else might be though.
> >>
> >>MIke
> >>
> >>
> >>John Fraizer wrote:
> >>
> >>
> >>>Can someone tell me specificly what causes the following messages?
> >>>
> >>>Aug 28 14:27:37 Router kernel: NET: 124 messages suppressed.
> >>>Aug 28 14:27:37 Router kernel: Neighbour table overflow.
> >>>Aug 28 14:27:37 Router last message repeated 2 times
> >>>Aug 28 14:27:39 Router kernel: NET: 207 messages suppressed.
> >>>Aug 28 14:27:39 Router kernel: Neighbour table overflow.
> >>>
> >>>This is Linux kernel 2.4.18, running linux-atm-2.4.0 with Fore LE155 NICs
> >>>using LANE.
> >>>
> >>>Thanks,
> >>>
> >>>---
> >>>John Fraizer              | High-Security Datacenter Services |
> >>>President                 | Dedicated circuits 64k - 155M OC3 |
> >>>EnterZone, Inc            | Virtual, Dedicated, Colocation    |
> >>>http://www.enterzone.net/ | Network Consulting Services       |
> >>>
> > 
> > 
> > 
> 
> 
> 
> 
> 
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> Linux-atm-general mailing list
> Linux-atm-general@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/linux-atm-general
> 
