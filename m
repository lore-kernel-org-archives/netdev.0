From: Jeff Garzik <jgarzik@pobox.com>
Subject: qdisc_restart locking bug?
Date: Fri, 15 Nov 2002 14:01:22 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DD54482.802@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When qdisc_restart() is called from qdisc_run(), dev->queue_lock is 
obtained via spin_lock_bh().

When dev->hard_start_xmit() is called from qdisc_restart(), 
dev->queue_lock is dropped, and then re-acquired using only spin_lock().

So, doesn't qdisc_restart need s/spin_lock/spin_lock_bh/ for 
dev->queue_lock?

When looking at the dev_queue_xmit -> qdisc_run -> qdisc_restart call 
path, it seems so to me.

	Jeff
