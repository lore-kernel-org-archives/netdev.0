From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: RTNL: assertion failed at net/core/dev.c (4494) and RTNL: assertion failed at net/core/rtnetlink.c (940)
Date: Thu, 06 Feb 2014 13:48:38 -0800
Message-ID: <30988.1391723318@death.nxdomain>
References: <20140206205106.GA10488@glanzmann.de> <CAHA+R7OGS_KG1un36KBixbgs7LTPWGRYdJ+Vsn2iM0FzNV5FzA@mail.gmail.com>
Cc: Thomas Glanzmann <thomas@glanzmann.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Veaceslav Falico <vfalico@redhat.com>, andy@greyhouse.net,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:49640 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751637AbaBFVsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 16:48:43 -0500
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 6 Feb 2014 14:48:43 -0700
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 8AFD76E8055
	for <netdev@vger.kernel.org>; Thu,  6 Feb 2014 16:48:36 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s16Lme6s7143684
	for <netdev@vger.kernel.org>; Thu, 6 Feb 2014 21:48:41 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s16Lmd2i015469
	for <netdev@vger.kernel.org>; Thu, 6 Feb 2014 16:48:40 -0500
In-reply-to: <CAHA+R7OGS_KG1un36KBixbgs7LTPWGRYdJ+Vsn2iM0FzNV5FzA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <cwang@twopensource.com> wrote:

>On Thu, Feb 6, 2014 at 12:51 PM, Thomas Glanzmann <thomas@glanzmann.de> wrote:
>> Hello,
>> this morning I checked out Linus tip and compiled it after booting my
>> dmesg is full of:
>>
>> [    8.944991] RTNL: assertion failed at net/core/dev.c (4494)
>> [    8.950640] CPU: 3 PID: 388 Comm: kworker/u24:4 Not tainted 3.14.0-rc1+ #3
>> [    8.950642] Hardware name: Supermicro X9SRD-F/X9SRD-F, BIOS 1.0a 10/15/2012
>> [    8.950654] Workqueue: bond0 bond_3ad_state_machine_handler [bonding]
>> [    8.950658]  0000000000000000 ffff881020c88000 ffffffff8138e219 ffff881020c88000
>> [    8.950664]  ffffffff812d3091 ffff881023961040 ffffffff812e3132 0000000000000246
>> [    8.950670]  0000000000000020 ffff881020ab1be8 0000000020ab1ba8 0000000000000000
>> [    8.950675] Call Trace:
>> [    8.950686]  [<ffffffff8138e219>] ? dump_stack+0x41/0x51
>> [    8.950694]  [<ffffffff812d3091>] ? netdev_master_upper_dev_get+0x2a/0x4d
>> [    8.950699]  [<ffffffff812e3132>] ? rtnl_fill_ifinfo+0x2c/0xac4
>> [    8.950707]  [<ffffffff81072211>] ? print_time.part.5+0x50/0x54
>> [    8.950715]  [<ffffffff812caf94>] ? __kmalloc_reserve.isra.42+0x2a/0x6d
>> [    8.950721]  [<ffffffff81102040>] ? ksize+0x12/0x1e
>> [    8.950726]  [<ffffffff812cb2b7>] ? __alloc_skb+0xb5/0x1a9
>> [    8.950731]  [<ffffffff812e4626>] ? rtmsg_ifinfo+0x6c/0xd6
>> [    8.950739]  [<ffffffffa035f4f9>] ? __enable_port.isra.17+0x51/0x5a [bonding]
>> [    8.950747]  [<ffffffffa0360463>] ? ad_agg_selection_logic+0x3d3/0x3ed [bonding]
>> [    8.950754]  [<ffffffffa0360d40>] ? bond_3ad_state_machine_handler+0x555/0x918 [bonding]
>> [    8.950761]  [<ffffffff8104db2d>] ? process_one_work+0x191/0x293
>> [    8.950766]  [<ffffffff8104dfde>] ? worker_thread+0x121/0x1e7
>> [    8.950770]  [<ffffffff8104debd>] ? rescuer_thread+0x269/0x269
>> [    8.950777]  [<ffffffff810527b6>] ? kthread+0x99/0xa1
>> [    8.950782]  [<ffffffff8105271d>] ? __kthread_parkme+0x59/0x59
>> [    8.950789]  [<ffffffff8139733c>] ? ret_from_fork+0x7c/0xb0
>> [    8.950794]  [<ffffffff8105271d>] ? __kthread_parkme+0x59/0x59
>
>
>Hmm, rtmsg_ifinfo() should be called with rtnl lock, but
>__enable_port() is called
>with rcu_read_lock() which means we can't block inside it, therefore we probably
>should take rtnl lock outside:
>
>diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>index cce1f1b..3c09ffa 100644
>--- a/drivers/net/bonding/bond_3ad.c
>+++ b/drivers/net/bonding/bond_3ad.c
>@@ -2065,6 +2065,7 @@ void bond_3ad_state_machine_handler(struct
>work_struct *work)
>        struct slave *slave;
>        struct port *port;
>
>+       rtnl_lock();
>        read_lock(&bond->lock);
>        rcu_read_lock();
>
>@@ -2123,6 +2124,7 @@ void bond_3ad_state_machine_handler(struct
>work_struct *work)
> re_arm:
>        rcu_read_unlock();
>        read_unlock(&bond->lock);
>+       rtnl_unlock();
>        queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
> }

	That would eliminate the warning, but is suboptimal.  Acquiring
RTNL is not necessary on the vast majority of state machine runs
(because no state changes take place, i.e., no ports are disabled or
enabled).  The above change would add 10 round trips per second to RTNL,
which seems excessive.

	Also, we cannot unconditionally acquire RTNL in this function,
as it would race with the call to cancel_delayed_work_sync from
bond_close (via bond_work_cancel_all).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
