From: Stephen Hemminger <shemminger@osdl.org>
Subject: pktgen: causing lots of errors in console log
Date: Tue, 8 Mar 2005 14:08:26 -0800
Message-ID: <20050308140826.451435e5@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Robert Olsson <Robert.Olsson@data.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Getting two types of console messages when using pktgen and 2.6.11 and the
pktgen-conf-1-1 script.

1. Errors from IPV4

KERNEL: assertion (!idev->ifa_list) failed at net/ipv4/devinet.c (122)
KERNEL: assertion (!idev->mc_list) failed at net/ipv4/devinet.c (123)
Freeing alive in_device ffff81007e96a400

2. Cliff is getting this with e1000 and pktgen-conf-1-2
 looks like calling schedule_timeout with lock held.

scheduling while atomic: pktgen.conf-2-1/0x00000001/3772
 [<c0366f02>] schedule+0x672/0x680
 [<c01891fa>] dnotify_parent+0x3a/0xb0
 [<c0367fa6>] _spin_lock+0x16/0x90
 [<c036843f>] _spin_unlock_irqrestore+0xf/0x30
 [<c01285d9>] __mod_timer+0xe9/0x130
 [<c0367822>] schedule_timeout+0x72/0xd0
 [<c0129190>] process_timeout+0x0/0x10
 [<c0367fa6>] _spin_lock+0x16/0x90
 [<e09926ea>] proc_thread_write+0x20a/0x2f0 [pktgen]
 [<c0367fa6>] _spin_lock+0x16/0x90
 [<c018c727>] proc_file_write+0x37/0x50
 [<c015ca4e>] vfs_write+0xae/0x130
 [<c015cba1>] sys_write+0x51/0x80
 [<c010290f>] syscall_call+0x7/0xb
