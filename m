From: Valdis.Kletnieks@vt.edu
Subject: mmotm 2010-11-23 - lockdep whinge in e1000e driver
Date: Tue, 23 Nov 2010 23:52:34 -0500
Message-ID: <5622.1290574354@localhost>
References: <201011240045.oAO0jYQ5016010@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1290574354_5261P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: akpm@linux-foundation.org, Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Your message of "Tue, 23 Nov 2010 16:13:06 PST."
             <201011240045.oAO0jYQ5016010@imap1.linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1290574354_5261P
Content-Type: text/plain; charset=us-ascii

On Tue, 23 Nov 2010 16:13:06 PST, akpm@linux-foundation.org said:
> The mm-of-the-moment snapshot 2010-11-23-16-12 has been uploaded to
> 
>    http://userweb.kernel.org/~akpm/mmotm/

Whinges during boot while bringing up the ethernet interface:

[    1.081504] ===================================================
[    1.081507] [ INFO: suspicious rcu_dereference_check() usage. ]
[    1.081509] ---------------------------------------------------
[    1.081512] include/linux/inetdevice.h:208 invoked rcu_dereference_check() without protection!
[    1.081514] 
[    1.081515] other info that might help us debug this:
[    1.081516] 
[    1.081518] 
[    1.081518] rcu_scheduler_active = 1, debug_locks = 1
[    1.081521] 3 locks held by swapper/1:
[    1.081523]  #0:  (&__lockdep_no_validate__){+.+.+.}, at: [<ffffffff812d0b57>] device_lock+0xf/0x11
[    1.081534]  #1:  (&__lockdep_no_validate__){+.+.+.}, at: [<ffffffff812d0b57>] device_lock+0xf/0x11
[    1.081541]  #2:  (rtnl_mutex){+.+.+.}, at: [<ffffffff8142dee8>] rtnl_lock+0x12/0x14
[    1.081549] 
[    1.081550] stack backtrace:
[    1.081553] Pid: 1, comm: swapper Not tainted 2.6.37-rc3-mmotm1123 #3
[    1.081555] Call Trace:
[    1.081562]  [<ffffffff81069580>] lockdep_rcu_dereference+0x9d/0xa5
[    1.081567]  [<ffffffff8147b235>] __in_dev_get_rcu.clone.12+0x3f/0x47
[    1.081571]  [<ffffffff8147b24d>] inet_get_link_af_size+0x10/0x1f
[    1.081575]  [<ffffffff8142ce16>] if_nlmsg_size+0xd5/0x111
[    1.081579]  [<ffffffff8142ecf6>] rtmsg_ifinfo+0x1f/0xeb
[    1.081584]  [<ffffffff8105d78e>] ? raw_notifier_call_chain+0xf/0x11
[    1.081589]  [<ffffffff81421ee7>] register_netdevice+0x3ea/0x410
[    1.081593]  [<ffffffff81421f47>] register_netdev+0x3a/0x4c
[    1.081599]  [<ffffffff81551cc2>] e1000_probe+0x986/0xb6f
[    1.081604]  [<ffffffff81237b2e>] local_pci_probe+0x3f/0x70
[    1.081608]  [<ffffffff81237eae>] pci_device_probe+0x65/0x96
[    1.081614]  [<ffffffff8115a82a>] ? sysfs_create_link+0xe/0x10
[    1.081617]  [<ffffffff812d0fe0>] driver_probe_device+0xe8/0x182
[    1.081621]  [<ffffffff812d10c4>] __driver_attach+0x4a/0x6b
[    1.081625]  [<ffffffff812d107a>] ? __driver_attach+0x0/0x6b
[    1.081629]  [<ffffffff812d01cf>] bus_for_each_dev+0x57/0x83
[    1.081633]  [<ffffffff812d0ca5>] driver_attach+0x19/0x1b
[    1.081637]  [<ffffffff812d08e7>] bus_add_driver+0xae/0x205
[    1.081641]  [<ffffffff812d1324>] driver_register+0xb5/0x122
[    1.081646]  [<ffffffff81b455cb>] ? e1000_init_module+0x0/0x3e
[    1.081650]  [<ffffffff812380e4>] __pci_register_driver+0x61/0xcd
[    1.081654]  [<ffffffff81b455cb>] ? e1000_init_module+0x0/0x3e
[    1.081658]  [<ffffffff81b45607>] e1000_init_module+0x3c/0x3e
[    1.081663]  [<ffffffff810002ff>] do_one_initcall+0x7a/0x12f
[    1.081668]  [<ffffffff81b1fd08>] kernel_init+0x15d/0x1e7
[    1.081672]  [<ffffffff810035d4>] kernel_thread_helper+0x4/0x10
[    1.081678]  [<ffffffff8102f845>] ? finish_task_switch+0x3f/0xe3
[    1.081682]  [<ffffffff8155b5c0>] ? restore_args+0x0/0x30
[    1.081686]  [<ffffffff81b1fbab>] ? kernel_init+0x0/0x1e7
[    1.081690]  [<ffffffff810035d0>] ? kernel_thread_helper+0x0/0x10
[    1.081731] e1000e 0000:00:19.0: eth0: (PCI Express:2.5GB/s:Width x1) 00:24:e8:c6:ad:17


--==_Exmh_1290574354_5261P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFM7JoScC3lWbTT17ARAub5AKCMW0SAbmgnBhEFO4yeESALSwXuAgCggcyd
AZWiMkMs8rtx3Vkay8tm8Wg=
=GBVK
-----END PGP SIGNATURE-----

--==_Exmh_1290574354_5261P--
