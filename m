From: Josh Triplett <josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org>
Subject: Re: [PATCH 0/6] kernel tinification: optionally compile out splice
 family of syscalls (splice, vmsplice, tee and sendfile)
Date: Sun, 23 Nov 2014 16:32:51 -0800
Message-ID: <20141124003251.GA13590@thin>
References: <1416752468-1626-1-git-send-email-pieter@boesman.nl>
 <20141123.134623.2061031332250984539.davem@davemloft.net>
 <20141123194326.GB8517@thin>
 <20141123203040.GB26749@smipidev>
 <20141123233637.GC12456@thin>
 <20141123192810.682a223e@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pieter Smith <pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org,
	ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, beber-2YnHqweIUXrk1uMJSBkQmQ@public.gmane.org,
	catalina.mocanu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org,
	fuse-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org,
	hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, iulia.manda21-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, JBeulich-IBi9RG/b67k@public.gmane.org,
	bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	mcgrof-IBi9RG/b67k@public.gmane.org, mattst88-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, mgorman-l3A5Bk7waGM@public.gmane.org,
	mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Paul.Durrant-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org,
	paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, pefoley2-lY0TAiDIAFlBDgjK7y7TUQ@public.gmane.org, tgraf-G/eBtMaohhA@public.gmane.org,
	therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	xiaoguangrong-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, zhenglong.cai-TJRtMXcVgQTM1kAEIRd3EQ@public.gmane.org
To: Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20141123192810.682a223e-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 23, 2014 at 07:28:10PM -0500, Jeff Layton wrote:
> On Sun, 23 Nov 2014 15:36:37 -0800
> Josh Triplett <josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org> wrote:
> 
> > On Sun, Nov 23, 2014 at 09:30:40PM +0100, Pieter Smith wrote:
> > > On Sun, Nov 23, 2014 at 11:43:26AM -0800, Josh Triplett wrote:
> > > > On Sun, Nov 23, 2014 at 01:46:23PM -0500, David Miller wrote:
> > > > > Truly removing sendfile/sendpage means that you can't even compile NFS
> > > > > into the tree.
> > > > 
> > > > If you mean the in-kernel nfsd (CONFIG_NFSD), that already has a large
> > > > stack of "select" and "depends on", both directly and indirectly; adding
> > > > a "select SPLICE_SYSCALL" to it seems fine.  (That select does need
> > > > adding, though.  Pieter, you need to test-compile more than just
> > > > tinyconfig and defconfig.  Try an allyesconfig with *just* splice turned
> > > > off, and make sure that compiles.)
> > > 
> > > Did exacly that. Took forever on my hardware, but no problems.
> > 
> > Ah, I see.  Looking more closely at nfsd, it looks like it already has a
> > code path for filesystems that don't do splice.  I think, rather than
> > making nfsd select SPLICE_SYSCALL, that it would suffice to change the
> > "rqstp->rq_splice_ok = true;" in svc_process_common (net/sunrpc/svc.c)
> > to:
> > 
> > rqstp->rq_splice_ok = IS_ENABLED(CONFIG_SPLICE_SYSCALL);
> > 
> > Then nfsd should simply *always* fall back to its non-splice support.
> > 
> 
> I'd probably prefer the above, actually. We have to keep supporting
> non-splice enabled fs' for the forseeable future, so we may as well
> allow people to run nfsd in such configurations. It could even be
> useful for testing the non-splice-enabled codepaths.

Good point!

- Josh Triplett
