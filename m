From: Josh Triplett <josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org>
Subject: Re: [PATCH 0/6] kernel tinification: optionally compile out splice
 family of syscalls (splice, vmsplice, tee and sendfile)
Date: Sun, 23 Nov 2014 11:43:26 -0800
Message-ID: <20141123194326.GB8517@thin>
References: <1416752468-1626-1-git-send-email-pieter@boesman.nl>
 <20141123.134623.2061031332250984539.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org, alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, beber-2YnHqweIUXrk1uMJSBkQmQ@public.gmane.org,
	catalina.mocanu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org,
	fuse-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org,
	hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, iulia.manda21-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, JBeulich-IBi9RG/b67k@public.gmane.org,
	bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mcgrof-IBi9RG/b67k@public.gmane.org, mattst88-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	mgorman-l3A5Bk7waGM@public.gmane.org, mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Paul.Durrant-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org,
	paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, pefoley2-lY0TAiDIAFlBDgjK7y7TUQ@public.gmane.org, tgraf-G/eBtMaohhA@public.gmane.org,
	therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	xiaoguangrong-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, zhenglong.cai-TJRtMXcVgQTM1kAEIRd3EQ@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20141123.134623.2061031332250984539.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 23, 2014 at 01:46:23PM -0500, David Miller wrote:
> Truly removing sendfile/sendpage means that you can't even compile NFS
> into the tree.

If you mean the in-kernel nfsd (CONFIG_NFSD), that already has a large
stack of "select" and "depends on", both directly and indirectly; adding
a "select SPLICE_SYSCALL" to it seems fine.  (That select does need
adding, though.  Pieter, you need to test-compile more than just
tinyconfig and defconfig.  Try an allyesconfig with *just* splice turned
off, and make sure that compiles.)

Given the requirements of running a file server in the kernel, I'd
expect CONFIG_NFSD to end up with several more selects of optional
functionality in the future.  It seems rather likely that the average
embedded system will be compiling out NFS. :)

Also, this patch series compiles out splice and sendfile, including
several *users* of sendpage; it doesn't compile out the sendpage
support/infrastructure itself.

- Josh Triplett
