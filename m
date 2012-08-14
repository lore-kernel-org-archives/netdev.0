From: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH v3 0/6]  cgroup cls & netprio 'cleanups'
Date: Tue, 14 Aug 2012 11:37:01 -0400
Message-ID: <20120814153701.GE18731@hmsreliant.think-freely.org>
References: <1344949343-26090-1-git-send-email-wagi@monom.org>
 <20120814131035.GC18731@hmsreliant.think-freely.org>
 <502A51DE.7040809@monom.org>
 <20120814133053.GD18731@hmsreliant.think-freely.org>
 <502A56C9.8070701@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Tim Chen <tim.c.chen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <502A56C9.8070701-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 14, 2012 at 03:46:49PM +0200, Daniel Wagner wrote:
> Hi Neil,
> 
> On 14.08.2012 15:30, Neil Horman wrote:
> > On Tue, Aug 14, 2012 at 03:25:50PM +0200, Daniel Wagner wrote:
> >> On 14.08.2012 15:10, Neil Horman wrote:
> >>> On Tue, Aug 14, 2012 at 03:02:16PM +0200, Daniel Wagner wrote:
> >>>> From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
> >>>>
> >>>> Hi,
> >>>>
> >>>> Sorry for the delay on updating this series. The usual
> >>>> excuse apply here.
> >>>>
> >>>> I saw that John is busy improving net_prio so I took the
> >>>> liberty to port his changes to net_cls (#1-3). Patch #3 will
> >>>> collide with John's unapplied patches. I am happy
> >>>> to rebase this series if needed.
> >>>>
> >>>> Patch #4 and #5 improve the readability with using
> >>>> IS_MODULE/BUILTIN macros. This patches prepare the last
> >>>> patch.
> >>>>
> >>>> Patch #6 removes support for assigning subsystem IDs during
> >>>> runtime. As it turns out this is not really needed. By doing
> >>>> so we are able to free some unused memory.
> >>>>
> >>>> The patches are against net-next.
> >>>>
> >>>> cheers,
> >>>> daniel
> >>>>
> >>> These aren't so much 'cleanups' as feature enhancements and fixes for the first
> >>> pass of those enhancements (at least in the case of the net_prio cgroup).
> >>
> >> Sorry about that. I wanted to keep the series title, so that someone
> >> looking up older versions find it.
> >>
> > That makes sense, but it would be best until we acked the the version going into
> > net_prio, otherwise we maybe tracking regressions in two places rather than one.
> 
> I agree, let's wait until net_prio gets stable.
>  
> >>> I've nothing against them, but since we're still going through some churn on the
> >>> net_prio variant, it may be best to wait until thats settled before moving them
> >>> over to net_cls.
> >>
> >> Sure, I can update this series when the net_prio controller changes
> >> have settled down.
> >>
> > Thank you, I think thats a good idea.
> > 
> >> I just wonder if it wouldn't make sense to merge them together.
> >> Obviously, that will break the user space which is not a good thing
> >> but having a controller per socket option is not good either.
> >>
> > This has been discussed (although perhaps not on list) before.  I don't think
> > we're going to see lots of cgroups for socket options.  most of them have proc
> > tunables, priroity and classification dont.
> 
> Well, I'll would like to able to set SO_MARK via a controller [1][2]. The use
> case is that I'd like to set the routing table per application. As it turns
> out the kernel has almost all bits and pieces to get this working. The only
> missing thing is setting SO_MARK without touching the application. For which
> the net cgroup controllers seem to be the perfect match.
> 
Ok, I stand corrected, there are other things that might be good for using with
cgroups in the networking space.

> > We could merge the two controllers,
> > but as you said it breaks users space which is a non-starter.  It also doesn't
> > really buy us anything, as people want to be able to set priority and
> > classification independently, so we either use two controllers, or one
> > controller with twice as many cgroup instances (one for each combination of
> > priroity/class that an admin wants).
> 
> Okay, I see your point. What is your standpoint concerning SO_MARK? Following
> your logic, we would need another controller for this which is what I rather
> have avoided. But I am more than happy to send patches for this :)
> 
Others may well have differing opinions, but my feeling is separate controllers
for separate functions.  As noted, while you could merge all the controllers, it
doesn't buy you much, and convolutes the meaning of a particular cgroup instance
(i.e. with a merged controller, a given cgroup instance owuld enforce
clasification A, priority B and mark value C, while another could enforce class
D priority B and mark C.  With separate controllers, admins can independently
select which class/priority and mark value to apply orthogonally.

So I'd vote for separate controllers.

> > I'll ping you when the net_prio stuff settles out.
> 
> Great, thanks.
> 
> cheers,
> daniel
> 
> [1] http://lists.connman.net/pipermail/connman/2012-August/010716.html
> [2] http://lists.connman.net/pipermail/connman/2012-August/010715.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
