From: Christopher Chan <cchan@outblaze.com>
Subject: High number of concurrent connections causes 2.6.4 to go berserk
Date: Fri, 02 Apr 2004 08:57:05 +0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <406CBA60.50103@outblaze.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yusuf Goolamabbas <yusufg@outblaze.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

KERNEL: assertion (flags & MSG_PEEK) failed a[t net/ipv4/tcp.c (1571)
KERNEL: assertion (tp->copied_seq == tp->rcv_nxt || (flags & (MSG_PEEK | 
MSG_TRUNC))) failed at net/ipv4/tcp.c (1635)

These are repeated in the logs during kernel berserk period

postfix is running on this box.

It is set to spawn max 750 smtpd processes to handle incoming smtp sessions.

When tcp_max_syn_backlog is set to 4096 and
route.max_size = 131072
route.gc_thresh = 65536

the box goes berserk almost immediately after bootup due to a bounce 
flood hitting the box.

The below values seem to workaround whatever problem the kernel has.

tcp_max_syn_backlog = 2048
route.max_size = 1048576
route.gc_thresh = 65536
