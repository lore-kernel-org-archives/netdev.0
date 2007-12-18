From: Chuck Ebbert <cebbert@redhat.com>
Subject: Nested VLAN causes recursive locking error
Date: Tue, 18 Dec 2007 18:03:55 -0500
Message-ID: <476851DB.5080107@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52207 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753904AbXLRXD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2007 18:03:56 -0500
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.1) with ESMTP id lBIN3tdb026248
	for <netdev@vger.kernel.org>; Tue, 18 Dec 2007 18:03:55 -0500
Received: from mail.boston.redhat.com (mail.boston.redhat.com [172.16.76.12])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id lBIN3tX4023790
	for <netdev@vger.kernel.org>; Tue, 18 Dec 2007 18:03:55 -0500
Received: from [172.16.83.145] (dhcp83-145.boston.redhat.com [172.16.83.145])
	by mail.boston.redhat.com (8.13.1/8.13.1) with ESMTP id lBIN3tcJ008212
	for <netdev@vger.kernel.org>; Tue, 18 Dec 2007 18:03:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From:
https://bugzilla.redhat.com/show_bug.cgi?id=426164


kernel version is 2.6.24-0.107.rc5.git3.fc9

>From boot log on serial console:
(full log attached)

Added VLAN with VID == 2 to IF -:eth0.1568:-

=============================================
[ INFO: possible recursive locking detected ]
2.6.24-0.107.rc5.git3.fc9 #1
---------------------------------------------
ifconfig/15011 is trying to acquire lock:
 (&vlan_netdev_xmit_lock_key){-+..}, at: [<c05d9450>] dev_mc_sync+0x1c/0x102

but task is already holding lock:
 (&vlan_netdev_xmit_lock_key){-+..}, at: [<c05d51bd>] dev_set_rx_mode+0x14/0x3c

other info that might help us debug this:
2 locks held by ifconfig/15011:
 #0:  (rtnl_mutex){--..}, at: [<c05de4f7>] rtnl_lock+0xf/0x11
 #1:  (&vlan_netdev_xmit_lock_key){-+..}, at: [<c05d51bd>] dev_set_rx_mode+0x14/0x3c

stack backtrace:
Pid: 15011, comm: ifconfig Not tainted 2.6.24-0.107.rc5.git3.fc9 #1
 [<c040649a>] show_trace_log_lvl+0x1a/0x2f
 [<c0406d41>] show_trace+0x12/0x14
 [<c0407061>] dump_stack+0x6c/0x72
 [<c044cfb3>] __lock_acquire+0x815/0xb5f
 [<c044d6f5>] lock_acquire+0x7b/0x9e
 [<c063dcf5>] _spin_lock_bh+0x33/0x5d
 [<c05d9450>] dev_mc_sync+0x1c/0x102
 [<f8b24c96>] vlan_dev_set_multicast_list+0x15/0x17 [8021q]
 [<c05d5107>] __dev_set_rx_mode+0x7e/0x81
 [<c05d51d0>] dev_set_rx_mode+0x27/0x3c
 [<c05d749e>] dev_open+0x61/0x7b
 [<c05d60b0>] dev_change_flags+0xa4/0x152
 [<c0616b8d>] devinet_ioctl+0x211/0x518
 [<c061723b>] inet_ioctl+0x86/0xa4
 [<c05caf0b>] sock_ioctl+0x1ca/0x1eb
 [<c049cdf2>] do_ioctl+0x22/0x67
 [<c049d080>] vfs_ioctl+0x249/0x25c
 [<c049d0d5>] sys_ioctl+0x42/0x5d
 [<c0405252>] syscall_call+0x7/0xb
 =======================
