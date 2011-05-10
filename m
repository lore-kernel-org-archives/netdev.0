From: Valdis.Kletnieks@vt.edu
Subject: 2.6.39-rc6-mmotm0506 - another lockdep splat (networking this time)
Date: Mon, 09 May 2011 21:05:23 -0400
Message-ID: <6954.1304989523@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1304989523_5294P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lennier.cc.vt.edu ([198.82.162.213]:55229 "EHLO
	lennier.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752560Ab1EJBFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 21:05:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1304989523_5294P
Content-Type: text/plain; charset=us-ascii

Seen during boot this afternoon:

[   43.309549] 
[   43.309550] ===================================================
[   43.309553] [ INFO: suspicious rcu_dereference_check() usage. ]
[   43.309555] ---------------------------------------------------
[   43.309558] include/linux/inetdevice.h:226 invoked rcu_dereference_check() without protection!
[   43.309560] 
[   43.309561] other info that might help us debug this:
[   43.309561] 
[   43.309563] 
[   43.309564] rcu_scheduler_active = 1, debug_locks = 1
[   43.309567] 2 locks held by ip/1193:
[   43.309568]  #0:  (nlk->cb_mutex){+.+...}, at: [<ffffffff81426c1d>] netlink_dump+0x45/0x1d0
[   43.309579]  #1:  (rcu_read_lock){.+.+..}, at: [<ffffffff8141b9b9>] rtnl_dump_ifinfo+0x0/0x156
[   43.309587] 
[   43.309587] stack backtrace:
[   43.309590] Pid: 1193, comm: ip Not tainted 2.6.39-rc6-mmotm0506 #1
[   43.309592] Call Trace:
[   43.309599]  [<ffffffff81066b6e>] lockdep_rcu_dereference+0x9a/0xa2
[   43.309604]  [<ffffffff81468d41>] __in_dev_get_rtnl+0x3c/0x47
[   43.309607]  [<ffffffff81468ef0>] inet_fill_link_af+0x12/0x5b
[   43.309611]  [<ffffffff8141b8fc>] rtnl_fill_ifinfo+0x665/0x710
[   43.309616]  [<ffffffff8141ba76>] rtnl_dump_ifinfo+0xbd/0x156
[   43.309620]  [<ffffffff81426c37>] netlink_dump+0x5f/0x1d0
[   43.309624]  [<ffffffff81404e3e>] ? consume_skb+0x8a/0x8f
[   43.309628]  [<ffffffff81426fc8>] netlink_recvmsg+0x1dd/0x31d
[   43.309632]  [<ffffffff813ff21f>] ? rcu_read_unlock+0x21/0x23
[   43.309636]  [<ffffffff813fab57>] sock_recvmsg+0xed/0x112
[   43.309641]  [<ffffffff810d1ebf>] ? might_fault+0x4e/0x9e
[   43.309645]  [<ffffffff81068816>] ? __lock_release+0x93/0x9c
[   43.309649]  [<ffffffff810d1ebf>] ? might_fault+0x4e/0x9e
[   43.309652]  [<ffffffff810d1f08>] ? might_fault+0x97/0x9e
[   43.309656]  [<ffffffff814065f8>] ? copy_from_user+0x3c/0x44
[   43.309660]  [<ffffffff813fc047>] __sys_recvmsg+0x16c/0x224
[   43.309665]  [<ffffffff81059240>] ? up_read+0x23/0x27
[   43.309669]  [<ffffffff81065165>] ? arch_local_irq_save+0x9/0xc
[   43.309673]  [<ffffffff810f736b>] ? fcheck_files+0xb4/0xeb
[   43.309676]  [<ffffffff810f79f3>] ? fget_light+0x35/0x96
[   43.309680]  [<ffffffff813fdded>] sys_recvmsg+0x3d/0x5b
[   43.309686]  [<ffffffff815705bb>] system_call_fastpath+0x16/0x1b
[   44.437679] e1000e 0000:00:19.0: irq 46 for MSI/MSI-X
[   44.488363] e1000e 0000:00:19.0: irq 46 for MSI/MSI-X
[   44.494680] ADDRCONF(NETDEV_UP): eth0: link is not ready



--==_Exmh_1304989523_5294P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFNyI9TcC3lWbTT17ARAiazAKCwBtiY3kI8n2VHTBfIyq8yMujczwCgqaXO
qIO0BoK0g8BXHzKM0Kk6cxg=
=IWq5
-----END PGP SIGNATURE-----

--==_Exmh_1304989523_5294P--

