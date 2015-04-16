From: Bryan O'Donoghue <pure.logic@nexus-software.ie>
Subject: [PATCH v3 0/1] stmmac: rmmod oops after ifconfig
Date: Thu, 16 Apr 2015 17:56:02 +0100
Message-ID: <1429203363-10919-1-git-send-email-pure.logic@nexus-software.ie>
Cc: andriy.shevchenko@linux.intel.com, hock.leong.kweh@intel.com,
	boon.leong.ong@intel.com, dan.odonovan@emutex.com,
	linux-kernel@vger.kernel.org,
	Bryan O'Donoghue <pure.logic@nexus-software.ie>
To: peppe.cavallaro@st.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-smtp03.blacknight.com ([81.17.249.16]:54414 "EHLO
	outbound-smtp03.blacknight.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752855AbbDPQ4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 12:56:05 -0400
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 3094F98E36
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2015 16:56:04 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have an oops with stmmac on Quark X1000/Galileo, triggered by rmmod after
ifconfig. Fix for issue contained in next mail against
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git


root@clanton:~# ifconfig eth0 192.168.0.1
root@clanton:~# rmmod stmmac_pci
[   39.257871] stmmac_dvr_remove:
        removing driver
[   39.263618] BUG: unable to handle kernel NULL pointer dereference at
00000060
[   39.271030] IP: [<c1254192>] phy_ethtool_get_wol+0x2/0x20
[   39.272391] *pdpt = 000000000e682001 *pde = 0000000000000000 
[   39.272391] Oops: 0000 [#1] 
[   39.272391] Modules linked in: evdev usbhid btusb bluetooth iwlwifi
cfg80211 rfkill ad7298 industrialio_triggered_buffer kfifo_buf industrialio
spi_s
[   39.272391] CPU: 0 PID: 1245 Comm: rmmod Not tainted 4.0.0 #26
[   39.272391] Hardware name: Intel Corp. QUARK/Galileo, BIOS 0x00000350
01/01/2014
[   39.272391] task: ce52a9e0 ti: cea64000 task.ti: cea64000
[   39.272391] EIP: 0060:[<c1254192>] EFLAGS: 00010292 CPU: 0
[   39.272391] EIP is at phy_ethtool_get_wol+0x2/0x20
[   39.272391] EAX: ce59e400 EBX: ce59e400 ECX: 00000000 EDX: cea65ddc
[   39.272391] ESI: 00000000 EDI: cea65e80 EBP: cea65df8 ESP: cea65dd8
[   39.272391]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
[   39.272391] CR0: 8005003b CR2: 00000060 CR3: 0e641000 CR4: 00100030
[   39.272391] Stack:
[   39.272391]  c1255908 00000005 00000000 00000000 00000000 00000000
ce59e400 ce85b4e0
[   39.272391]  cea65e04 c125597c ce59e400 cea65e10 c12559cf ce85b000
cea65e24 e07a9dd8
[   39.272391]  cea65e38 ce85b000 cea65e80 cea65e44 c12a7639 cea0cc60
cdd4a180 c009ad00
[   39.272391] Call Trace:
[   39.272391]  [<c1255908>] ? phy_suspend+0x38/0x70
[   39.272391]  [<c125597c>] phy_detach+0x3c/0x60
[   39.272391]  [<c12559cf>] phy_disconnect+0x2f/0x40
[   39.272391]  [<e07a9dd8>] stmmac_release+0x38/0x150 [stmmac]
[   39.272391]  [<c12a7639>] __dev_close_many+0x69/0xb0
[   39.272391]  [<c12a76dd>] dev_close_many+0x5d/0xd0
[   39.272391]  [<c12a859a>] rollback_registered_many+0xda/0x240
[   39.272391]  [<c12a871f>] rollback_registered+0x1f/0x30
[   39.272391]  [<c12a93b7>] unregister_netdevice_queue+0x47/0xb0
[   39.272391]  [<c132bb1b>] ? mutex_lock+0xb/0x19
[   39.272391]  [<c12a9434>] unregister_netdev+0x14/0x20
[   39.272391]  [<e07a695d>] stmmac_dvr_remove+0x6d/0xb0 [stmmac]
[   39.272391]  [<e074e02e>] stmmac_pci_remove+0xe/0x10 [stmmac_pci]
[   39.272391]  [<c1196c48>] pci_device_remove+0x28/0xa0
[   39.272391]  [<c121d8ea>] __device_release_driver+0x5a/0xb0
[   39.272391]  [<c121df4f>] driver_detach+0x6f/0x80
[   39.272391]  [<c121d68b>] bus_remove_driver+0x3b/0x80
[   39.272391]  [<c121e4c3>] driver_unregister+0x23/0x60
[   39.272391]  [<c10726da>] ? find_module_all+0x5a/0x80
[   39.272391]  [<c11968df>] pci_unregister_driver+0xf/0x50
[   39.272391]  [<e074e3d3>] stmmac_pci_driver_exit+0xd/0xc3a [stmmac_pci]
[   39.272391]  [<c1073f5c>] SyS_delete_module+0x15c/0x1b0
[   39.272391]  [<c132d19d>] syscall_call+0x7/0x7
[   39.272391] Code: 42 12 31 c0 c3 8d 74 26 00 8b 08 8b 49 5c 85 c9 74 07
55 89 e5 ff d1 5d c3 b8 a1 ff ff ff c3 8d 76 00 8d bc 27 00 00 00 00 8b 08
<0
[   39.272391] EIP: [<c1254192>] phy_ethtool_get_wol+0x2/0x20 SS:ESP
0068:cea65dd8
[   39.272391] CR2: 0000000000000060
[   39.551363] ---[ end trace 98d1260353bf4fec ]---
Killed

Bryan O'Donoghue (1):
  stmmac: fix oops on rmmod after assigning ip addr

 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

-- 
1.9.1
