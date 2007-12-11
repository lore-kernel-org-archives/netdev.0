From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9543] New: RTNL: assertion failed at
 net/ipv6/addrconf.c (2164)/RTNL: assertion failed at net/ipv4/devinet.c
 (1055)
Date: Tue, 11 Dec 2007 03:46:03 -0800
Message-ID: <20071211034603.cbcc4762.akpm@linux-foundation.org>
References: <bug-9543-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: olel@ans.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39399 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751803AbXLKLqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 06:46:49 -0500
In-Reply-To: <bug-9543-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Dec 2007 03:20:48 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9543
> 
>            Summary: RTNL: assertion failed at net/ipv6/addrconf.c
>                     (2164)/RTNL: assertion failed at net/ipv4/devinet.c
>                     (1055)
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.24-rc4-git7
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: olel@ans.pl
> 
> 
> Most recent kernel where this bug did not occur: 2.6.23
> Distribution: Gentoo
> 
> Problem Description:
> ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
> RTNL: assertion failed at net/ipv6/addrconf.c (2164)
> Pid: 9, comm: events/0 Not tainted 2.6.24-rc4-git7 #1
>  [<78402cfb>] addrconf_notify+0x5b4/0x7b7
>  [<7812203a>] finish_task_switch+0x0/0x8c
>  [<781346ff>] worker_thread+0x0/0x85
>  [<78438e23>] schedule+0x545/0x55f
>  [<781408d1>] print_lock_contention_bug+0x11/0xd2
>  [<783bfa72>] rt_run_flush+0x43/0x8b
>  [<783bfa93>] rt_run_flush+0x64/0x8b
>  [<7813ac54>] notifier_call_chain+0x2a/0x52
>  [<7813ac9e>] raw_notifier_call_chain+0x17/0x1a
>  [<783a3471>] netdev_state_change+0x18/0x29
>  [<783ac6a9>] __linkwatch_run_queue+0x150/0x17e
>  [<783ac6f4>] linkwatch_event+0x1d/0x22
>  [<78133cdf>] run_workqueue+0xdb/0x1b6
>  [<78133c8b>] run_workqueue+0x87/0x1b6
>  [<783ac6d7>] linkwatch_event+0x0/0x22
>  [<781346ff>] worker_thread+0x0/0x85
>  [<78134778>] worker_thread+0x79/0x85
>  [<781371ad>] autoremove_wake_function+0x0/0x35
>  [<781370f6>] kthread+0x38/0x5e
>  [<781370be>] kthread+0x0/0x5e
>  [<78104baf>] kernel_thread_helper+0x7/0x10
>  =======================
> RTNL: assertion failed at net/ipv6/addrconf.c (1610)


Hopefully this is due to the bug you reported in bug #9542.

Does this patch fix both issues?


From: Andrew Morton <akpm@linux-foundation.org>

Remove stray rtnl_unlock().

Addresses http://bugzilla.kernel.org/show_bug.cgi?id=9542

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
Cc: Krzysztof Oledzki <olel@ans.pl>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/bonding/bond_sysfs.c |    2 --
 1 file changed, 2 deletions(-)

diff -puN drivers/net/bonding/bond_sysfs.c~bonding-locking-fix drivers/net/bonding/bond_sysfs.c
--- a/drivers/net/bonding/bond_sysfs.c~bonding-locking-fix
+++ a/drivers/net/bonding/bond_sysfs.c
@@ -1111,8 +1111,6 @@ static ssize_t bonding_store_primary(str
 out:
 	write_unlock_bh(&bond->lock);
 
-	rtnl_unlock();
-
 	return count;
 }
 static DEVICE_ATTR(primary, S_IRUGO | S_IWUSR, bonding_show_primary, bonding_store_primary);
_

