From: Sasha Levin <levinsasha928@gmail.com>
Subject: [BUG] net: WARNING: at fs/sysfs/dir.c:481 sysfs_add_one+0xb7/0xe0()
Date: Mon, 05 Dec 2011 15:01:37 +0200
Message-ID: <1323090097.9154.0.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@redhat.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: marcel@holtmann.org, padovan@profusion.mobi, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

When closing and opening a HCI device, a device id may be assigned
before the previous one was fully released. It manifests itself for
example in a warning when the new sysfs entry is being added before the
previous one was deleted:

[ 5711.916643] ------------[ cut here ]------------
[ 5711.918640] WARNING: at fs/sysfs/dir.c:481 sysfs_add_one+0xb7/0xe0()
[ 5711.920203] sysfs: cannot create duplicate filename '/devices/virtual/bluetooth/hci0'
[ 5711.921866] Pid: 20596, comm: trinity Not tainted 3.2.0-rc4-next-20111205-sasha-00003-gd1b8117 #48
[ 5711.923256] Call Trace:
[ 5711.923651]  [<ffffffff810aec45>] warn_slowpath_common+0x75/0xb0
[ 5711.924600]  [<ffffffff810aece1>] warn_slowpath_fmt+0x41/0x50
[ 5711.925503]  [<ffffffff812196d7>] sysfs_add_one+0xb7/0xe0
[ 5711.926357]  [<ffffffff81219785>] create_dir+0x85/0xe0
[ 5711.927267]  [<ffffffff812198fb>] sysfs_create_dir+0x7b/0xc0
[ 5711.928555]  [<ffffffff817a7201>] kobject_add_internal+0x121/0x200
[ 5711.929947]  [<ffffffff817a73dd>] kobject_add+0x6d/0xb0
[ 5711.931170]  [<ffffffff819f8e1b>] device_add+0xcb/0x700
[ 5711.932073]  [<ffffffff819f8c8c>] ? dev_set_name+0x3c/0x40
[ 5711.932911]  [<ffffffff821d166c>] ? hci_register_dev+0x56c/0x690
[ 5711.933859]  [<ffffffff821e23e2>] hci_add_sysfs+0x52/0x150
[ 5711.934733]  [<ffffffff821d16a6>] hci_register_dev+0x5a6/0x690
[ 5711.935678]  [<ffffffff81d423fb>] vhci_open+0xfb/0x190
[ 5711.936777]  [<ffffffff818a5cd1>] misc_open+0x81/0x110
[ 5711.937951]  [<ffffffff811a4f9f>] chrdev_open+0x7f/0x150
[ 5711.939152]  [<ffffffff811a4f20>] ? cdev_put+0x10/0x10
[ 5711.940410]  [<ffffffff8119e122>] __dentry_open+0x282/0x3b0
[ 5711.941513]  [<ffffffff8119f274>] nameidata_to_filp+0x74/0x80
[ 5711.942448]  [<ffffffff811aed2c>] do_last+0x1bc/0x940
[ 5711.943268]  [<ffffffff811af586>] path_openat+0xd6/0x440
[ 5711.944124]  [<ffffffff8104a1f3>] ? sched_clock+0x13/0x20
[ 5711.945104]  [<ffffffff810d6605>] ? sched_clock_local+0x25/0x90
[ 5711.946065]  [<ffffffff811af934>] do_filp_open+0x44/0xa0
[ 5711.947261]  [<ffffffff810a3a1d>] ? sub_preempt_count+0x9d/0xd0
[ 5711.948614]  [<ffffffff823db830>] ? _raw_spin_unlock+0x30/0x60
[ 5711.949917]  [<ffffffff811be6d5>] ? alloc_fd+0x185/0x1f0
[ 5711.951126]  [<ffffffff8119f79c>] do_sys_open+0xfc/0x1d0
[ 5711.951949]  [<ffffffff8119f88b>] sys_open+0x1b/0x20
[ 5711.952742]  [<ffffffff823dcf52>] system_call_fastpath+0x16/0x1b
[ 5711.953739] ---[ end trace 6eef4878a8c24f09 ]---

But it may also cause more things which are not as visible.

Please let me know if I can help with debugging this issue.

-- 

Sasha.
