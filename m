From: Dave Young <hidave.darkstar@gmail.com>
Subject: Re: [BUG net-2.6] bluetooth/rfcomm : sleeping function called from
	invalid context at mm/slub.c:1719
Date: Sat, 3 Oct 2009 15:06:22 +0800
Message-ID: <20091003070622.GA4110@darkstar>
References: <4AC59D8A.6000102@hartkopp.net> <a8e1da0910020401m2fb8493ax95ff55a3b66131a5@mail.gmail.com> <4AC6247E.7050308@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-bluetooth@vger.kernel.org
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f199.google.com ([209.85.210.199]:46886 "EHLO
	mail-yx0-f199.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001AbZJCHGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2009 03:06:44 -0400
Content-Disposition: inline
In-Reply-To: <4AC6247E.7050308@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 02, 2009 at 06:04:14PM +0200, Oliver Hartkopp wrote:
> Dave Young wrote:
> > On Fri, Oct 2, 2009 at 2:28 PM, Oliver Hartkopp <oliver@hartkopp.net> wrote:
> >> Hello Marcel,
> >>
> >> with current net-2.6 tree ...
> >>
> >> While starting my PPP Bluetooth dialup networking, i got this:
> > 
> > Hi, oliver
> > 
> > please try following patch:
> > http://patchwork.kernel.org/patch/51326/
> 
> Hi Dave,
> 
> that fixed it at ppp startup!
> 
> Tested-by: Oliver Hartkopp <oliver@hartkopp.net>
> 
> Btw. when shutting down the ppp connection i still get this:
> 
> [  361.996887] INFO: trying to register non-static key.
> [  361.996897] the code is fine but needs lockdep annotation.
> [  361.996902] turning off the locking correctness validator.
> [  361.996912] Pid: 0, comm: swapper Not tainted 2.6.31-08939-gdb8abec-dirty #22
> [  361.996919] Call Trace:
> [  361.996933]  [<c12e4fb2>] ? printk+0xf/0x11
> [  361.996947]  [<c1042214>] register_lock_class+0x5a/0x295
> [  361.996957]  [<c1043af2>] __lock_acquire+0x9b/0xc03
> [  361.996967]  [<c104464b>] ? __lock_acquire+0xbf4/0xc03
> [  361.996985]  [<fa59a168>] ? l2cap_get_chan_by_scid+0x35/0x43 [l2cap]
> [  361.996995]  [<c104491f>] ? lock_release_non_nested+0x17b/0x1db
> [  361.997008]  [<fa59a168>] ? l2cap_get_chan_by_scid+0x35/0x43 [l2cap]
> [  361.997018]  [<c10426fd>] ? trace_hardirqs_off+0xb/0xd
> [  361.997028]  [<c10446b6>] lock_acquire+0x5c/0x73
> [  361.997039]  [<c124cd14>] ? skb_dequeue+0x12/0x4c
> [  361.997049]  [<c12e6e23>] _spin_lock_irqsave+0x24/0x34
> [  361.997058]  [<c124cd14>] ? skb_dequeue+0x12/0x4c
> [  361.997066]  [<c124cd14>] skb_dequeue+0x12/0x4c
> [  361.997075]  [<c124d579>] skb_queue_purge+0x14/0x1b
> [  361.997088]  [<fa59ce3f>] l2cap_recv_frame+0xe9e/0x129a [l2cap]
> [  361.997099]  [<c10421d1>] ? register_lock_class+0x17/0x295
> [  361.997110]  [<c104464b>] ? __lock_acquire+0xbf4/0xc03
> [  361.997128]  [<c104464b>] ? __lock_acquire+0xbf4/0xc03
> [  361.997139]  [<c120de74>] ? uhci_giveback_urb+0xf2/0x162
> [  361.997163]  [<f8bb4c45>] ? hci_rx_task+0xfe/0x1f8 [bluetooth]
> [  361.997177]  [<fa59d2e4>] l2cap_recv_acldata+0xa9/0x1be [l2cap]
> [  361.997190]  [<fa59d23b>] ? l2cap_recv_acldata+0x0/0x1be [l2cap]
> [  361.997208]  [<f8bb4c77>] hci_rx_task+0x130/0x1f8 [bluetooth]
> [  361.997219]  [<c102a098>] tasklet_action+0x6b/0xb2
> [  361.997228]  [<c102a46b>] __do_softirq+0x82/0x101
> [  361.997237]  [<c102a515>] do_softirq+0x2b/0x43
> [  361.997246]  [<c102a619>] irq_exit+0x35/0x68
> [  361.997256]  [<c1004513>] do_IRQ+0x80/0x96
> [  361.997265]  [<c10030ae>] common_interrupt+0x2e/0x34
> [  361.997275]  [<c104007b>] ? tick_device_uses_broadcast+0x71/0x7c
> [  361.997286]  [<c11747a8>] ? acpi_idle_enter_simple+0x103/0x12e
> [  361.997296]  [<c1174515>] acpi_idle_enter_bm+0xc3/0x253
> [  361.997306]  [<c1238b6f>] cpuidle_idle_call+0x60/0x91
> [  361.997315]  [<c1001d44>] cpu_idle+0x49/0x65
> [  361.997324]  [<c12e2f0e>] start_secondary+0x190/0x195
> 
> 
> Thanks,
> Oliver
> 

Oliver, does following patch fix the non-static lock problem?
--

now l2cap conn locks will be initialized after setup l2cap conn timer,
it will introduce following problem:

[  361.996887] INFO: trying to register non-static key.
[  361.996897] the code is fine but needs lockdep annotation.
[  361.996902] turning off the locking correctness validator.
[  361.996912] Pid: 0, comm: swapper Not tainted 2.6.31-08939-gdb8abec-dirty #22
[  361.996919] Call Trace:
[  361.996933]  [<c12e4fb2>] ? printk+0xf/0x11
[  361.996947]  [<c1042214>] register_lock_class+0x5a/0x295
[  361.996957]  [<c1043af2>] __lock_acquire+0x9b/0xc03
[  361.996967]  [<c104464b>] ? __lock_acquire+0xbf4/0xc03
[  361.996985]  [<fa59a168>] ? l2cap_get_chan_by_scid+0x35/0x43 [l2cap]
[  361.996995]  [<c104491f>] ? lock_release_non_nested+0x17b/0x1db
[  361.997008]  [<fa59a168>] ? l2cap_get_chan_by_scid+0x35/0x43 [l2cap]
[  361.997018]  [<c10426fd>] ? trace_hardirqs_off+0xb/0xd
[  361.997028]  [<c10446b6>] lock_acquire+0x5c/0x73
[  361.997039]  [<c124cd14>] ? skb_dequeue+0x12/0x4c
[  361.997049]  [<c12e6e23>] _spin_lock_irqsave+0x24/0x34
[  361.997058]  [<c124cd14>] ? skb_dequeue+0x12/0x4c
[  361.997066]  [<c124cd14>] skb_dequeue+0x12/0x4c
[  361.997075]  [<c124d579>] skb_queue_purge+0x14/0x1b
[  361.997088]  [<fa59ce3f>] l2cap_recv_frame+0xe9e/0x129a [l2cap]
[  361.997099]  [<c10421d1>] ? register_lock_class+0x17/0x295
[  361.997110]  [<c104464b>] ? __lock_acquire+0xbf4/0xc03
[  361.997128]  [<c104464b>] ? __lock_acquire+0xbf4/0xc03
[  361.997139]  [<c120de74>] ? uhci_giveback_urb+0xf2/0x162
[  361.997163]  [<f8bb4c45>] ? hci_rx_task+0xfe/0x1f8 [bluetooth]
[  361.997177]  [<fa59d2e4>] l2cap_recv_acldata+0xa9/0x1be [l2cap]
[  361.997190]  [<fa59d23b>] ? l2cap_recv_acldata+0x0/0x1be [l2cap]
[  361.997208]  [<f8bb4c77>] hci_rx_task+0x130/0x1f8 [bluetooth]
[  361.997219]  [<c102a098>] tasklet_action+0x6b/0xb2
[  361.997228]  [<c102a46b>] __do_softirq+0x82/0x101
[  361.997237]  [<c102a515>] do_softirq+0x2b/0x43
[  361.997246]  [<c102a619>] irq_exit+0x35/0x68
[  361.997256]  [<c1004513>] do_IRQ+0x80/0x96
[  361.997265]  [<c10030ae>] common_interrupt+0x2e/0x34
[  361.997275]  [<c104007b>] ? tick_device_uses_broadcast+0x71/0x7c
[  361.997286]  [<c11747a8>] ? acpi_idle_enter_simple+0x103/0x12e
[  361.997296]  [<c1174515>] acpi_idle_enter_bm+0xc3/0x253
[  361.997306]  [<c1238b6f>] cpuidle_idle_call+0x60/0x91
[  361.997315]  [<c1001d44>] cpu_idle+0x49/0x65
[  361.997324]  [<c12e2f0e>] start_secondary+0x190/0x195

Here move lock init things before setup_timer to avoid misuse
uninitialized locks.

Reported-by: Oliver Hartkopp <oliver@hartkopp.net>
Signed-off-by: Dave Young <hidave.darkstar@gmail.com>
---
net/bluetooth/l2cap.c |    6 +++---
1 file changed, 3 insertions(+), 3 deletions(-)

--- linux-2.6.31.orig/net/bluetooth/l2cap.c	2009-09-30 16:36:10.000000000 +0800
+++ linux-2.6.31/net/bluetooth/l2cap.c	2009-10-03 14:44:51.000000000 +0800
@@ -555,12 +555,12 @@ static struct l2cap_conn *l2cap_conn_add
 
 	conn->feat_mask = 0;
 
-	setup_timer(&conn->info_timer, l2cap_info_timeout,
-						(unsigned long) conn);
-
 	spin_lock_init(&conn->lock);
 	rwlock_init(&conn->chan_list.lock);
 
+	setup_timer(&conn->info_timer, l2cap_info_timeout,
+						(unsigned long) conn);
+
 	conn->disc_reason = 0x13;
 
 	return conn;
