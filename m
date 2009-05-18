From: Sergey Kononenko <sergk@sergk.org.ua>
Subject: WARNING at dev_disable_lro when enabling ip_forward
Date: Tue, 19 May 2009 01:01:47 +0300
Message-ID: <20090519010147.772f0bff@vingilot.sergknet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.hqhost.net ([80.77.80.130]:47005 "EHLO mail.hqhost.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754300AbZERWPy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2009 18:15:54 -0400
Received: from vingilot.sergknet ([80.77.82.87])
	(authenticated bits=0)
	by mail.hqhost.net (8.14.3/8.14.3/Debian-5) with ESMTP id n4IM1mdY006206
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 18 May 2009 22:01:51 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have system with two Intel 82575EB 1Gb/s NICs and two Intel 82598EB
10Gb/s NICs (motherboard Supermicro X7DWU). I'm using kernel 2.6.29.3
with compiled in drivers for both types of NICs with LRO enabled:
CONFIG_INET_LRO=y
CONFIG_IGB=y
CONFIG_IGB_LRO=y
CONFIG_IGB_DCA=y
CONFIG_IXGBE=y
CONFIG_IXGBE_DCA=y

After boot process is completed according to ethtool LRO is disabled on igb
and enabled on ixgbe. After I'm trying to turn on forwarding by
sysctl -w net.ipv4.ip_forward=1 I get following in dmesg:
------------[ cut here ]------------
WARNING: at net/core/dev.c:1199 dev_disable_lro+0x7c/0x80()
Hardware name: X7DWU
Modules linked in: ipt_REJECT ipt_ttl xt_multiport xt_hashlimit xt_length xt_NOTRACK xt_tcpudp xt_state ipt_set ip_set_i
ptree ip_set iptable_raw iptable_filter ip_tables x_tables nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 8021q msr cpuid
 ipmi_devintf ipmi_si ipmi_msghandler coretemp w83793 hwmon_vid i2c_dev loop i2c_i801 psmouse pcspkr i2c_core evdev i5k_
amb i5400_edac edac_core container button usbhid hid usb_storage sg sr_mod cdrom ehci_hcd uhci_hcd usbcore thermal proce
ssor fan thermal_sys hwmon
Pid: 5869, comm: sysctl Not tainted 2.6.29.3 #1
Call Trace:
 [<ffffffff8023b5d0>] warn_slowpath+0xd0/0x130
 [<ffffffff802872b3>] ? __alloc_pages_internal+0xe3/0x4f0
 [<ffffffff8028a3b0>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff802a12d5>] ? page_add_new_anon_rmap+0x85/0x90
 [<ffffffff80298003>] ? handle_mm_fault+0x553/0x770
 [<ffffffff8029c9bc>] ? vma_adjust+0xfc/0x4e0
 [<ffffffff804c4e8c>] dev_disable_lro+0x7c/0x80
 [<ffffffff8051c2e0>] devinet_sysctl_forward+0x140/0x160
 [<ffffffff8030b7c7>] proc_sys_call_handler+0xc7/0xe0
 [<ffffffff8030b7ef>] proc_sys_write+0xf/0x20
 [<ffffffff802b3f2b>] vfs_write+0xcb/0x190
 [<ffffffff802b40e0>] sys_write+0x50/0x90
 [<ffffffff8020b9db>] system_call_fastpath+0x16/0x1b
---[ end trace 2907c917776795f3 ]---
------------[ cut here ]------------
WARNING: at net/core/dev.c:1199 dev_disable_lro+0x7c/0x80()
Hardware name: X7DWU
Modules linked in: ipt_REJECT ipt_ttl xt_multiport xt_hashlimit xt_length xt_NOTRACK xt_tcpudp xt_state ipt_set ip_set_iptree ip_set iptable_raw iptable_filter ip_tables x_tables nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 8021q msr cpuid ipmi_devintf ipmi_si ipmi_msghandler coretemp w83793 hwmon_vid i2c_dev loop i2c_i801 psmouse pcspkr i2c_core evdev i5k_amb i5400_edac edac_core container button usbhid hid usb_storage sg sr_mod cdrom ehci_hcd uhci_hcd usbcore thermal processor fan thermal_sys hwmon
Pid: 5869, comm: sysctl Tainted: G        W  2.6.29.3 #1
Call Trace:
 [<ffffffff8023b5d0>] warn_slowpath+0xd0/0x130
 [<ffffffff802872b3>] ? __alloc_pages_internal+0xe3/0x4f0
 [<ffffffff8028a3b0>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff802a12d5>] ? page_add_new_anon_rmap+0x85/0x90
 [<ffffffff80298003>] ? handle_mm_fault+0x553/0x770
 [<ffffffff8029c9bc>] ? vma_adjust+0xfc/0x4e0
 [<ffffffff804c4e8c>] dev_disable_lro+0x7c/0x80
 [<ffffffff8051c2e0>] devinet_sysctl_forward+0x140/0x160
 [<ffffffff8030b7c7>] proc_sys_call_handler+0xc7/0xe0
 [<ffffffff8030b7ef>] proc_sys_write+0xf/0x20
 [<ffffffff802b3f2b>] vfs_write+0xcb/0x190
 [<ffffffff802b40e0>] sys_write+0x50/0x90
 [<ffffffff8020b9db>] system_call_fastpath+0x16/0x1b
---[ end trace 2907c917776795f4 ]---


Disabling ethtool -K eth0 lro off (and eth1 too) before turning on
forwarding don't help. I still get this warning but looks like kernel
works normally after it. I don't want jsut to disable LRO in kernel
config because I use same build of kernel on another machines there are
no need in ip forwarding. So may be this warning can be fixed somehow?

With best regards,
Sergey Kononenko.
