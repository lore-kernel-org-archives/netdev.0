From: Andrew Morton <akpm@osdl.org>
Subject: Fw: kernel 2.6 libipq kernel hang
Date: Wed, 6 Apr 2005 15:58:28 -0700
Message-ID: <20050406155828.1584d7cd.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mailinglist.chris@gmail.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Wed, 6 Apr 2005 15:12:05 -0400
From: Mailing List <mailinglist.chris@gmail.com>
To: linux-kernel@vger.kernel.org
Subject: kernel 2.6 libipq kernel hang


All,
     I am having a kernel hang with all the latest versions of the 2.6
kernel (2.6.8.1, 2.6.9, 2.6.10, and 2.6.12-rc2).  Basically, my test
is this:  I have a simple ipq program that just takes packets in,
makes a copy of them (using memcpy), then accepts the packets with the
new buffer (which happens to be a copy of the old buffer).  I run this
program on two machines, with the following iptables rules:

/sbin/iptables -t mangle -A POSTROUTING -d 192.168.3.0/24 -j QUEUE
/sbin/iptables -t mangle -A PREROUTING -s 192.168.3.0/24 -j QUEUE

I then have a simple server and client program; the server just
accepts a connection, recv's some data, and then closes the connection
(in a while(1) loop).  The client connects to the server, send's some
data, then closes the connection (in a while(1) loop).  With this test
running, on all of the kernels mentioned above, the kernel will always
hang after some length of time (it seems to be more or less random). 
No oops, no stack trace, just a hard kernel lock.  I saw in the
ChangeLog for 2.6.12-rc2 that they may have fixed a race condition in
netlink; however, 2.6.12-rc2 still did not work for me.  I have also
tried running a server program that just accepts a connection, and
recv's data forever, with a client that connects once, and send's data
forever.  This also locked up the machine, although with slightly
different behavior (basically the queue program sucked up 100% of the
processor for a while, then the whole kernel hung).

All of the code I am using, along with the scripts can be found at

http://www.ontologistics.net/OpenSource/libipq

If anyone has any suggestions about what I am doing wrong in either
the libipq program or the client or server programs, or any ideas
about what is going on with netlink, please let me know.

Thank you,
Chris Lalancette
