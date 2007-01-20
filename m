From: Chris Rankin <rankincj@yahoo.com>
Subject: [BUG] Sleeping function called from invalid context (2.6.18.6)
Date: Sat, 20 Jan 2007 23:06:57 +0000 (GMT)
Message-ID: <957323.87386.qm@web52909.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750774AbXATXHA@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I have been testing my wireless zd1211rw driver with kismet, but have noticed my logs filling up
with these messages instead:

BUG: sleeping function called from invalid context at kernel/mutex.c:86
in_atomic():0, irqs_disabled():1
 [<c029688e>] mutex_lock+0x12/0x1a
 [<c02496ae>] netdev_run_todo+0x10/0x1f1
 [<c024a148>] dev_ioctl+0x465/0x497
 [<c01626ff>] d_rehash+0x47/0x78
 [<c0240379>] sock_attach_fd+0x6c/0xcb
 [<c023fc9d>] sock_ioctl+0x0/0x1b3
 [<c015e508>] do_ioctl+0x1c/0x5d
 [<c015e78a>] vfs_ioctl+0x241/0x254
 [<c015e7c9>] sys_ioctl+0x2c/0x43
 [<c0102c3f>] syscall_call+0x7/0xb

According to the comment in linux/net/core/dev.c

 * 2) Since we run with the RTNL semaphore not held, we can sleep
 *    safely in order to wait for the netdev refcnt to drop to zero.

Well, apparently we can't sleep safely after all because IRQs have been disabled.

Cheers,
Chris



	
	
		
___________________________________________________________ 
New Yahoo! Mail is the ultimate force in competitive emailing. Find out more at the Yahoo! Mail Championships. Plus: play games and win prizes. 
http://uk.rd.yahoo.com/evt=44106/*http://mail.yahoo.net/uk 
