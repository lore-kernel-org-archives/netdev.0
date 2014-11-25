From: josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org
Subject: Re: [PATCH v4 0/7] kernel tinification: optionally compile out
 splice family of syscalls (splice, vmsplice, tee and sendfile)
Date: Tue, 25 Nov 2014 14:08:41 -0800
Message-ID: <20141125220841.GB25683@cloud>
References: <1416870079-15254-1-git-send-email-pieter@boesman.nl>
 <5474ABB6.3030400@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pieter Smith <pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org>,
	Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Bertrand Jacquin <beber-2YnHqweIUXrk1uMJSBkQmQ@public.gmane.org>,
	Catalina Mocanu <catalina.mocanu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Fabian Frederick <fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>,
	"open list:FUSE: FILESYSTEM..." <fuse-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>,
	Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Iulia Manda <iulia.manda21-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Jan Beulich <JBeulich-IBi9RG/b67k@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	open list <linux-kernel-u79uwXL29TasMV2rI37PzA@public.gmane.org
To: Randy Dunlap <rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5474ABB6.3030400-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

[Resending this mail due to some email encoding brokenness that
prevented it from reaching LKML the first time; sorry to anyone who
receives two copies.]

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
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
