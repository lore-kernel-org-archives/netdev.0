From: David Mosberger <davidm@napali.hpl.hp.com>
Subject: SOMAXCONN too low
Date: Tue, 28 Oct 2003 22:58:00 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310290658.h9T6w04k015302@napali.hpl.hp.com>
Reply-To: davidm@hpl.hp.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I was a bit surprised to find that listen() is still capping at the
hard limit of SOMAXCONN (which is still 128).  This is ridiculously
low for high-performance servers.  Today's severs can do easily in
excess of 10,000 TCP connections/second so a queue length of 128
corresponds to just about 10ms, so it doesn't take much of bad
scheduling etc. to overflow the queue.

You obviously want some control over how big the listen queue can
grow, but it seems to me that a sysctl would be in place.  I found
this patch to do that, but no reaction to it:

  http://www.ussg.iu.edu/hypermail/linux/kernel/0205.0/1287.html

I also found this message:

  http://marc.theaimsgroup.com/?l=linux-net&m=98745977620384&w=2

but the argument makes little sense, because TUX bypasses sys_listen()
alltogether and therefore can set the listen queue length to anything
it wants.  In fact, tux2 defaults to a listen-queue size of 2048, so
if anything it is an argument _for_ increasing the max. listen-queue
size.

Also, it appears that current SuSE kernels do indeed have a
net.core.somaxconn sysctl to let a sysadmin choose a larger SOMAXCONN
value.

	--david
