From: Jeff Garzik <jgarzik@pobox.com>
Subject: Network interface synchronization docs
Date: Mon, 02 Dec 2002 22:33:20 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DEC2600.2070306@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050300030504070804060609"
Cc: netdev@oss.sgi.com, akpm@zip.com.au
Return-path: <netdev-bounce@oss.sgi.com>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050300030504070804060609
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

I just updated Documentation/networking/netdevices.txt locally to the 
attached file, which describes the synchronization rules for net drivers 
in the 2.4.x and 2.5.x kernels.  (Astute readers will notice a striking 
similarity to 2.2.x locking rules as well)

Comments and corrections to the attached doc requested.  I realize it's 
not much right now, but this is core info I want to make sure is 
correct, and that everyone agrees on.

Thanks to Robert Olsson for a pointer about dev->poll().

Future notes:  this doc will hopefully expand in time to describe not 
only the netdevice API but also standard ethernet and net driver 
practices.  Patches welcome!

	Jeff



--------------050300030504070804060609
Content-Type: text/plain;
 name="netdevices.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netdevices.txt"


Network Devices, the Kernel, and You!


Introduction
============
The following is a random collection of documentation regarding
network devices.



struct net_device synchronization rules
=======================================
dev->open:
	Synchronization: rtnl_lock() semaphore.
	Context: process

dev->stop:
	Synchronization: rtnl_lock() semaphore.
	Context: process
	Notes: netif_running() is guaranteed false when this is called

dev->do_ioctl:
	Synchronization: rtnl_lock() semaphore.
	Context: process

dev->get_stats:
	Synchronization: dev_base_lock rwlock.
	Context: nominally process, but don't sleep inside an rwlock

dev->hard_start_xmit:
	Synchronization: dev->xmit_lock spinlock.
	Context: BHs disabled

dev->tx_timeout:
	Synchronization: dev->xmit_lock spinlock.
	Context: BHs disabled

dev->set_multicast_list:
	Synchronization: dev->xmit_lock spinlock.
	Context: BHs disabled

dev->poll:
	Synchronization: __LINK_STATE_RX_SCHED bit in dev->state.  See
		dev_close code and comments in net/core/dev.c for more info.
	Context: softirq


--------------050300030504070804060609--
