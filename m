From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [BK PATCH] 2.4 SCTP updates
Date: Fri, 13 Feb 2004 16:07:29 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402131540330.2339@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

Please do a
	bk pull http://linux-lksctp.bkbits.net/lksctp-2.4.work
to get the following udpates to SCTP on top fo linux 2.4.25-rc2

These set of csets bring 2.4 in sync with 2.6 lksctp. I tried to keep
2.4 specific changes isolated to the following few files using #defines in
compat.h.
	- include/net/sctp/compat.h
	- include/net/sctp/sctp.h
	- include/net/sctp/structs.h
	- net/sctp/Config.in
	- net/sctp/Makefile
	- net/sctp/endpointola.c
	- net/sctp/input.c
	- net/sctp/inqueue.c
	- net/sctp/ipv6.c
	- net/sctp/objcnt.c
	- net/sctp/proc.c
	- net/sctp/protocol.c
	- net/sctp/socket.c
	- net/sctp/sysctl.c
	- net/sctp/ulpqueue.c
	- net/sctp/chunk.c
The rest of the files are identical to 2.6 sctp files.

I could not find an easy way to do the backport of choice construct to select
HMAC algorithm in 2.6 Kconfig to 2.4 Config.in. I did it in a convoluted
way with multiple choices nested in ifs. It may be possible to do the same in
a much simpler way.

# This patch includes the following deltas:
#	           ChangeSet	1.1308  -> 1.1312
#	 net/sctp/ulpqueue.c	1.1     -> 1.2
#	include/net/sctp/compat.h	1.2     -> 1.3
#	include/linux/sysctl.h	1.40    -> 1.41
#	include/net/sctp/constants.h	1.1     -> 1.2
#	net/sctp/sm_make_chunk.c	1.1     -> 1.2
#	   net/sctp/tsnmap.c	1.1     -> 1.2
#	net/sctp/primitive.c	1.1     -> 1.2
#	   net/sctp/sysctl.c	1.1     -> 1.2
#	     net/sctp/proc.c	1.1     -> 1.2
#	   net/sctp/socket.c	1.2     -> 1.5
#	include/net/sctp/sla1.h	1.1     ->         (deleted)
#	 net/sctp/outqueue.c	1.2     -> 1.3
#	include/net/sctp/sctp.h	1.3     -> 1.4
#	include/net/sctp/sm.h	1.1     -> 1.2
#	   net/sctp/objcnt.c	1.1     -> 1.2
#	   net/sctp/Makefile	1.1     -> 1.2
#	net/sctp/associola.c	1.2     -> 1.3
#	  net/sctp/inqueue.c	1.1     -> 1.2
#	    net/sctp/debug.c	1.1     -> 1.2
#	include/net/sctp/user.h	1.1     -> 1.2
#	net/sctp/sm_statefuns.c	1.1     -> 1.2
#	   net/sctp/output.c	1.1     -> 1.2
#	     net/sctp/sla1.c	1.1     ->         (deleted)
#	     net/sctp/ipv6.c	1.1     -> 1.2
#	net/sctp/transport.c	1.2     -> 1.3
#	 net/sctp/protocol.c	1.1     -> 1.2
#	include/linux/sctp.h	1.1     -> 1.2
#	net/sctp/bind_addr.c	1.1     -> 1.2
#	         MAINTAINERS	1.125   -> 1.126
#	net/sctp/sm_sideeffect.c	1.1     -> 1.2
#	net/sctp/sm_statetable.c	1.1     -> 1.2
#	    net/sctp/input.c	1.1     -> 1.2
#	 net/sctp/ulpevent.c	1.1     -> 1.2
#	include/net/sctp/structs.h	1.2     -> 1.3
#	  net/sctp/adler32.c	1.1     ->         (deleted)
#	include/net/sctp/tsnmap.h	1.1     -> 1.2
#	  net/sctp/Config.in	1.1     -> 1.2
#	include/net/sctp/command.h	1.1     -> 1.2
#	   net/sctp/ssnmap.c	1.1     -> 1.2
#	net/sctp/hashdriver.c	1.1     ->         (deleted)
#	Documentation/Configure.help	1.227   -> 1.228
#	include/net/sctp/ulpevent.h	1.1     -> 1.2
#	net/sctp/endpointola.c	1.1     -> 1.2
#	               (new)	        -> 1.1     net/sctp/chunk.c
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/02/12	sri@us.ibm.com	1.1309
# [SCTP] Sync with 2.6.2 SCTP.
# --------------------------------------------
# 04/02/12	sri@us.ibm.com	1.1310
# [SCTP] Use __get_free_pages() to allocate ssnmap.
#
# This is needed to avoid kmalloc()'s 128K limit when an association is
# initialized with a large no. of streams(more than 65000 inbound +
# outbound streams).
# --------------------------------------------
# 04/02/12	sri@us.ibm.com	1.1311
# [SCTP] Fix SCTP_INITMSG set socket option so that a parameter with 0
#        value will not change its current value.
# --------------------------------------------
# 04/02/13	sri@us.ibm.com	1.1312
# [SCTP] Fix sctp_getladdrs()/sctp_getpaddrs() API so that the port
#        value in the returned addresses is in network byte order.
# --------------------------------------------
#

Thanks
Sridhar
