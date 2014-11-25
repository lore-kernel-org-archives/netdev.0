From: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Subject: Re: [PATCH v4 0/7] kernel tinification: optionally
 compile out splice family of syscalls (splice, vmsplice, tee and sendfile)
Date: Tue, 25 Nov 2014 13:58:06 -0500
Message-ID: <20141125185806.GA28116@thunk.org>
References: <5474ABB6.3030400@infradead.org>
	<20141125.121305.2094097848188324942.davem@davemloft.net>
	<20141125181032.GJ5050@linux.vnet.ibm.com>
	<20141125.132445.152609149279137368.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org, beber-2YnHqweIUXrk1uMJSBkQmQ@public.gmane.org,
	oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, zhenglong.cai-TJRtMXcVgQTM1kAEIRd3EQ@public.gmane.org,
	jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org, therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org,
	miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org, pefoley2-lY0TAiDIAFlBDgjK7y7TUQ@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	xiaoguangrong-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org,
	mgorman-l3A5Bk7waGM@public.gmane.org, mattst88-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org,
	fuse-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, mcgrof-IBi9RG/b67k@public.gmane.org,
	josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, catalina.mocanu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org,
	tgraf-G/eBtMaohhA@public.gmane.org, Paul.Durrant-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org,
	JBeulich-IBi9RG/b67k@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	iulia.manda21-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdeve
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <fuse-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20141125.132445.152609149279137368.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/fuse-devel>,
	<mailto:fuse-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=fuse-devel>
List-Post: <mailto:fuse-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:fuse-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/fuse-devel>,
	<mailto:fuse-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: fuse-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 25, 2014 at 01:24:45PM -0500, David Miller wrote:
> 
> And then if some fundamental part of userland (glibc, klibc, etc.) finds
> a useful way to use splice for a fundamental operation, we're back to
> square one.

I'll note that the applications for these super-tiny kernels are
places where it's not likely they would be using glibc at all; think
very tiny embedded systems.  The userspace tends to be highly
restricted for the same space reasons why there is an effort to make
the kernel as small as possible.

In these places, they are using Linux already, but they're using a 2.2
or 2.4 kernel because 3.0 is just too damned big.  So the goal is to
try to provide them an alternative which allows them to use a modern,
but stripped down kernel.  If glibc or klibc isn't going to work
without splice, then it's not going to work on a pre 2.6 kernel
anyway, so things are no worse with these systems anyway.

After all, if we can get these systems to using a 3.x kernel w/o
splice, that's surely better than their using a 2.2 or 2.4 kernel w/o
the splice system, isn't it?

Cheers,

					- Ted

------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
