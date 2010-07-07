From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH] ixgbe: fix crashing with ixgbe_vlan_filter_enable
Date: Wed, 7 Jul 2010 17:31:35 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FF492082D@rrsmsx501.amr.corp.intel.com>
References: <4C350991.6080002@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: NetDev <netdev@vger.kernel.org>
To: Yinghai Lu <yinghai@kernel.org>,
	David Miller <davem@davemloft.net>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:39261 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757929Ab0GGXbi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jul 2010 19:31:38 -0400
In-Reply-To: <4C350991.6080002@kernel.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yinghai Lu wrote:
> happens with reboot or call kexec on system with ixgbe.
> 
> [ 4912.773390] BUG: unable to handle kernel NULL pointer dereference
> [ 4912.785756] IP: [<ffffffff81691600>]
> ixgbe_vlan_filter_enable+0x74/0xda [ 4912.794084] PGD 10391a0067 PUD
> 1022e3c067 PMD 0 [ 4912.805976] Oops: 0000 [#1] SMP
> [ 4912.809312] last sysfs file:
> /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/host4/target4:2:0/4:2:0:0/vendor
> [ 4912.828965] CPU 1 [ 4912.830533] Modules linked in:
> [ 4912.834366]
> [ 4912.835288] Pid: 25366, comm: reboot Not tainted
> 2.6.34-rc4-tip-yh-04420-g4537151-dirty #70 [ 4912.854250] RIP:
> 0010:[<ffffffff81691600>]  [<ffffffff81691600>]
> ixgbe_vlan_filter_enable+0x74/0xda [ 4912.870439] RSP:
> 0018:ffff88203de49d08  EFLAGS: 00010287 [ 4912.885521] RAX:
> 0000000000000000 RBX: ffff88703d5d8900 RCX: ffff88703d5d8900 [
> 4912.896225] RDX: 0000000000000000 RSI: 0000000000000040 RDI:
> ffff88703d5d8900 [ 4912.908265] RBP: ffff88203de49d08 R08:
> ffffc90047280000 R09: ffff88203de49b98 [ 4912.915174] R10:
> 0000000000000000 R11: ffff88203de49d38 R12: ffff88703d5d8000 [
> 4912.936333] R13: ffff88703d5d9e80 R14: 0000000000000000 R15:
> 0000000000000000 [ 4912.947284] FS:  00007f91db5a36f0(0000)
> GS:ffff880079e00000(0000) knlGS:0000000000000000 [ 4912.965019] CS: 
> 0010 DS: 0000 ES: 0000 CR0: 000000008005003b [ 4912.970282] CR2:
> 000000000000002e CR3: 0000001021d27000 CR4: 00000000000006e0 [
> 4912.986573] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000 [ 4912.997240] DR3: 0000000000000000 DR6:
> 00000000ffff0ff0 DR7: 0000000000000400 [ 4913.012609] Process reboot
> (pid: 25366, threadinfo ffff88203de48000, task ffff88203d902340) [
> 4913.028237] Stack: [ 4913.030121]  ffff88203de49d38 ffffffff81697d16
> ffff88703d5d8900 ffff88503ed00000 [ 4913.045165] <0> 000000000000001e
> ffff88703d5d8000 ffff88203de49d98 ffffffff81697e46 [ 4913.053297] <0>
> ffff88203d902340 ffffffff81bd9fc4 ffff88203de49db7 0000000000000000 [
> 4913.070554] Call Trace: [ 4913.074948]  [<ffffffff81697d16>]
> ixgbe_set_rx_mode+0x137/0x17e [ 4913.086386]  [<ffffffff81697e46>]
> __ixgbe_shutdown+0xe9/0x1a6 [ 4913.092895]  [<ffffffff81bd9fc4>] ?
> _raw_spin_unlock_irq+0x30/0x36 [ 4913.108970]  [<ffffffff81697f1d>]
> ixgbe_shutdown+0x1a/0x43 [ 4913.113514]  [<ffffffff813e3bea>]
> pci_device_shutdown+0x2c/0x40 [ 4913.128080]  [<ffffffff81489e25>]
> device_shutdown+0x53/0x74 [ 4913.135736]  [<ffffffff8108dd91>]
> kernel_restart_prepare+0x2c/0x33 [ 4913.147206]  [<ffffffff8108dddb>]
> kernel_restart+0x16/0x48 [ 4913.154807]  [<ffffffff8108df6f>]
> sys_reboot+0x150/0x196 [ 4913.167525]  [<ffffffff810a4891>] ?
> trace_hardirqs_on+0xd/0xf [ 4913.175020]  [<ffffffff811430c2>] ?
> mntput_no_expire+0x2c/0xf5 [ 4913.191952]  [<ffffffff8112da8c>] ?
> __fput+0x1d8/0x1e7 [ 4913.197452]  [<ffffffff81033b8c>] ?
> sysret_check+0x27/0x62 [ 4913.207708]  [<ffffffff81bd9472>] ?
> trace_hardirqs_on_thunk+0x3a/0x3f [ 4913.212377] 
> [<ffffffff81033b5b>] system_call_fastpath+0x16/0x1b [ 4913.230877]
> Code: 00 00 00 40 48 8b 97 80 15 00 00 25 ff ff ff df 89 82 88 50 00
> 00 31 d2 48 89 f9 eb 6a 48 8b 81 40 0e 00 00 4c 8b 87 80 15 00 00
> <0f> b7 40 2e 83 f8 3f 7f 0d 89 c6 c1 e6 06 81 c6 28 10 00 00 eb [
> 4913.268163] RIP  [<ffffffff81691600>]
> ixgbe_vlan_filter_enable+0x74/0xda [ 4913.273435]  RSP
> <ffff88203de49d08> [ 4913.285451] CR2: 000000000000002e [
> 4913.290668] ---[ end trace 0aaa048b0b730b65 ]---       
> 
> add checking before reference them.
> 
> Signed-off-by: Yinghai Lu <yinghai@kernel.org>

There should be a patch in net-2.6 that fixes this issue:

http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commitdiff;h=fa37813401ff52d78591c262d6542e4d5d935584

Thanks,
Emil
