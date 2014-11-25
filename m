From: josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org
Subject: Re: [PATCH v4 0/7] kernel tinification: optionally
 compile out splice family of syscalls (splice, vmsplice, tee and sendfile)
Date: Tue, 25 Nov 2014 11:00:28 -0800
Message-ID: <20141125190028.GB24891@cloud>
References: <1416870079-15254-1-git-send-email-pieter@boesman.nl>
	<5474ABB6.3030400@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	Bertrand Jacquin <beber-2YnHqweIUXrk1uMJSBkQmQ@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	=?utf-8?B?6JSh5q2j6b6Z?= <zhenglong.cai-TJRtMXcVgQTM1kAEIRd3EQ@public.gmane.org>,
	Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>, Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>,
	Peter Foley <pefoley2-lY0TAiDIAFlBDgjK7y7TUQ@public.gmane.org>, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Xiao Guangrong <xiaoguangrong-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>,
	Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>, Matt Turner <mattst88-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Pieter Smith <pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org>,
	"open list:FUSE: FILESYSTEM..." <fuse-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	"Luis R. Rod
To: Randy Dunlap <rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <fuse-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5474ABB6.3030400-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/fuse-devel>,
	<mailto:fuse-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=fuse-devel>
List-Post: <mailto:fuse-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:fuse-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/fuse-devel>,
	<mailto:fuse-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: fuse-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 25, 2014 at 08:17:58AM -0800, Randy Dunlap wrote:
> On 11/24/2014 03:00 PM, Pieter Smith wrote:
> >REPO: https://github.com/smipi1/linux-tinification.git
> >
> >BRANCH: tiny/config-syscall-splice
> >
> >BACKGROUND: This patch-set forms part of the Linux Kernel Tinification effort (
> >   https://tiny.wiki.kernel.org/).
> >
> >GOAL: Support compiling out the splice family of syscalls (splice, vmsplice,
> >   tee and sendfile) along with all supporting infrastructure if not needed.
> >   Many embedded systems will not need the splice-family syscalls. Omitting them
> >   saves space.
> 
> Hi,
> 
> Is the splice family of syscalls the only one that tiny has identified
> for optional building or can we expect similar treatment for other
> syscalls?

Pretty much any system call that you could conceive of writing a
userspace without.

There's a partial project list at https://tiny.wiki.kernel.org/projects.

> Why will many embedded systems not need these syscalls?  You know
> exactly what apps they run and you are positive that those apps do
> not use splice?

Yes, precisely.  We're talking about embedded systems small enough that
you're booting with init=/your/app and don't even call fork(), where you
know exactly what code you're putting in and what libraries you use.
And they're almost certainly not running glibc.

> >RESULTS: A tinyconfig bloat-o-meter score for the entire patch-set:
> >
> >add/remove: 0/41 grow/shrink: 5/7 up/down: 23/-8422 (-8399)
> 
> The summary is that this patch saves around 8 KB of code space --
> is that correct?

Right.  For reference, we're talking about kernels where the *total*
size is a few hundred kB.

> How much storage space do embedded systems have nowadays?

For the embedded systems we're targeting for the tinification effort, in
a first pass: 512k-2M of storage (often for an *uncompressed* kernel, to
support execute-in-place), and 128k-512k of memory.  We've successfully
built useful kernels and userspaces for such environments, and we'd like
to go even smaller.

- Josh Triplett

------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
