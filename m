From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new]  [Bug 4027] New: assertion failed at
 net/ipv6/addrconf.c, plus halt fails
Date: Wed, 12 Jan 2005 15:57:41 -0800
Message-ID: <20050112155741.193e1f37.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgoerzen@complete.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Wed, 12 Jan 2005 15:38:23 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new]  [Bug 4027] New: assertion failed at net/ipv6/addrconf.c, plus halt fails


http://bugme.osdl.org/show_bug.cgi?id=4027

           Summary: assertion failed at net/ipv6/addrconf.c, plus halt fails
    Kernel Version: 2.6.9 & 2.6.10, kernel.org tree
            Status: NEW
          Severity: normal
             Owner: yoshfuji@linux-ipv6.org
         Submitter: jgoerzen@complete.org


Distribution:
Hardware Environment: Alpha 164LX 21164a 600MHz
Software Environment: Debian unstable
Problem Description:

During bootup, I am getting multiple instances ofitems like this, typically when
a daemon starts up:

Jan 12 17:23:38 erwin kernel: RTNL: assertion failed at net/ipv6/addrconf.c (1992)

Trace shows:

Jan 12 17:23:38 erwin kernel: Trace:
Jan 12 17:23:38 erwin kernel: [sk_free+324/336] sk_free+0x144/0x150
Jan 12 17:23:38 erwin kernel: [inet_release+128/160] inet_release+0x80/0xa0
Jan 12 17:23:38 erwin kernel: [sock_release+172/240] sock_release+0xac/0xf0
Jan 12 17:23:38 erwin kernel: [sock_close+48/112] sock_close+0x30/0x70
Jan 12 17:23:38 erwin kernel: [__fput+412/448] __fput+0x19c/0x1c0
Jan 12 17:23:38 erwin kernel: [fput+72/96] fput+0x48/0x60
Jan 12 17:23:38 erwin kernel: [filp_close+132/240] filp_close+0x84/0xf0
Jan 12 17:23:38 erwin kernel: [close_files+172/224] close_files+0xac/0xe0
Jan 12 17:23:38 erwin kernel: [put_files_struct+84/224] put_files_struct+0x54/0xe0
Jan 12 17:23:39 erwin kernel: [do_exit+508/1424] do_exit+0x1fc/0x590
Jan 12 17:23:39 erwin kernel: [do_group_exit+60/176] do_group_exit+0x3c/0xb0
Jan 12 17:23:39 erwin kernel: [entSys+164/192] entSys+0xa4/0xc0

The system appears to function normally after bootup.  

However, when it comes time to halt the system, I cannot.  It stalls with:

unregister_netdevice: waiting for sit1 to become free.  Usage count = 1

This machine is acting as a firewall.  I have two Ethernet devices in it; one
for the outside and one for the inside.  The outside speaks only IPv4.  Inside
speaks IPv4 and IPv6.  IPv6 is routed to the outside via sit1, using the public
6to4 router address.

I will attach dmesg logs, ksymoops output, configurations, etc.

This behavior was observed on both 2.6.9 and 2.6.10.

Please ask if there is any other information you would need to resolve this
problem.  I am quite happy to provide anything that may be of use.

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
