From: Matthijs van Duin <matthijs@cds.nl>
Subject: minor issues in 2.6.1 networking + patches
Date: Sat, 31 Jan 2004 17:03:03 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040131160303.GD25922@cds.nl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="96dIhm/ZjrNld+BP"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--96dIhm/ZjrNld+BP
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline

Hi

I was studying the linux 2.6.1 networking code (via lxr.linux.no) and 
stumbled on three minor points.

1. fib_props[] in net/ipv4/fib_semantics.c has size determined by RTA_MAX, 
yet is indexed by RTN_* constants.  Patch included.

2. Two typos ("xrfm") in comments in include/net/xfrm.h.  Patch included.

3. I'm quite new to all this, so I might be missing something, but I 
think a dependency is reversed.  net/sched/Kconfig says:

config NET_CLS_ROUTE
	bool
	depends on NET_CLS_ROUTE4
	default y

Yet evidence seems to indicate NET_CLS_ROUTE4 actually depends on 
NET_CLS_ROUTE instead:

net/sched/Makefile:29:obj-$(CONFIG_NET_CLS_ROUTE4)	+= cls_route.o
net/sched/cls_route.c:153:	id = dst->tclassid;
include/net/dst.h:72:#ifdef CONFIG_NET_CLS_ROUTE
include/net/dst.h:73:	__u32			tclassid;
include/net/dst.h:74:#endif

Linux 2.4.22's net/sched/Config.in also seems to support this direction 
of the dependency.

regards,

-- 
Matthijs van Duin  --  May the Forth be with you!

--96dIhm/ZjrNld+BP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline; filename=patch

--- linux-2.6.1/net/ipv4/fib_semantics.c	2004-01-09 07:59:10.000000000 +0100
+++ linux/net/ipv4/fib_semantics.c	2004-01-31 16:34:13.000000000 +0100
@@ -83,7 +83,7 @@
 {
 	int	error;
 	u8	scope;
-} fib_props[RTA_MAX + 1] = {
+} fib_props[RTN_MAX + 1] = {
         {
 		.error	= 0,
 		.scope	= RT_SCOPE_NOWHERE,



--- linux-2.6.1/include/net/xfrm.h	2004-01-09 07:59:56.000000000 +0100
+++ linux/include/net/xfrm.h	2004-01-31 16:36:40.000000000 +0100
@@ -48,10 +48,10 @@
                      |---. child .-> dst -. xfrm .-> xfrm_state #3
                                       |---. child .-> NULL
 
-   Bundles are cached at xrfm_policy struct (field ->bundles).
+   Bundles are cached at xfrm_policy struct (field ->bundles).
 
 
-   Resolution of xrfm_tmpl
+   Resolution of xfrm_tmpl
    -----------------------
    Template contains:
    1. ->mode		Mode: transport or tunnel

--96dIhm/ZjrNld+BP--
