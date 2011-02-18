From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Netconsole crash on 2.6.38-rc3
Date: Thu, 17 Feb 2011 17:28:47 -0800
Message-ID: <20110218012847.GA8980@xanatos>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="6c2NcOVqGQ03X4Wi"
Cc: netdev@vger.kernel.org, Greg KH <gregkh@suse.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28866 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754345Ab1BRB24 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Feb 2011 20:28:56 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--6c2NcOVqGQ03X4Wi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

I'm trying to debug an xHCI driver crash on 2.6.38-rc3, and netconsole
is crashing when I try to load it.  I will try to update to 2.6.38-rc5,
but I'm sort of stuck on rc3 since Greg KH's USB tree is based on that.

Attached is the two scripts I use to set up my box and call netconsole.
netconsole-on-network.sh is called first, followed by
netconsole-ending-on-network.sh.

When I invoked the netconsole-ending-on-network.sh script, netconsole
failed to load with an error about having the wrong ethernet device.  My
ethernet device apparently migrated from eth1 to eth0 on that box.

After modifying my script, unloading the netconsole driver, and
re-running netconsole-ending-on-network.sh, I got a "Killed" message
with the attached trace in dmesg.

Is this a known bug on 2.6.38-rc3?

Sarah Sharp

--6c2NcOVqGQ03X4Wi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="netconsole-crash.txt"

[   30.336011] eth0: no IPv6 routers present
[   62.165508] netconsole: local port 6665
[   62.165512] netconsole: local IP 0.0.0.0
[   62.165513] netconsole: interface 'eth1'
[   62.165514] netconsole: remote port 6666
[   62.165515] netconsole: remote IP 192.168.1.138
[   62.165517] netconsole: remote ethernet address ff:ff:ff:ff:ff:ff
[   62.165518] netconsole: eth1 doesn't exist, aborting.
[   62.165520] netconsole: cleaning up
[   98.791662] netconsole: local port 6665
[   98.791666] netconsole: local IP 0.0.0.0
[   98.791667] netconsole: interface 'eth0'
[   98.791668] netconsole: remote port 6666
[   98.791669] netconsole: remote IP 192.168.1.138
[   98.791671] netconsole: remote ethernet address ff:ff:ff:ff:ff:ff
[   98.791673] netconsole: local IP 192.168.1.8
[   98.791690] BUG: unable to handle kernel NULL pointer dereference at           (null)
[   98.791693] IP: [<ffffffff81131977>] d_delete+0x47/0x180
[   98.791698] PGD 221b45067 PUD 221bce067 PMD 0 
[   98.791701] Oops: 0000 [#1] SMP 
[   98.791702] last sysfs file: /sys/devices/pci0000:00/0000:00:1f.2/host1/target1:0:0/1:0:0:0/block/sda/sda1/stat
[   98.791705] CPU 0 
[   98.791706] Modules linked in: netconsole(+) i915 drm_kms_helper drm binfmt_misc i2c_algo_bit ppdev bridge stp bnep video lp parport snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device snd soundcore usbhid pcspkr snd_page_alloc intel_agp intel_gtt iTCO_wdt iTCO_vendor_support ehci_hcd uhci_hcd usbcore floppy
[   98.791726] 
[   98.791728] Pid: 3337, comm: modprobe Not tainted 2.6.38-rc3+ #179 P5Q-EM/System Product Name
[   98.791730] RIP: 0010:[<ffffffff81131977>]  [<ffffffff81131977>] d_delete+0x47/0x180
[   98.791732] RSP: 0018:ffff880221b8fe68  EFLAGS: 00010246
[   98.791734] RAX: 0000000000000202 RBX: ffff8802255e2180 RCX: ffffffff81ababe0
[   98.791735] RDX: 0000000000000000 RSI: ffff8802255e21b8 RDI: ffff8802255e21dc
[   98.791737] RBP: ffff880221b8fe88 R08: ffff8800cda14420 R09: 0000000000000000
[   98.791738] R10: 0000000000000000 R11: 0000000000000001 R12: 0000000000000000
[   98.791740] R13: ffff8802255e21dc R14: 0000000000000000 R15: ffff880221b8fee8
[   98.791742] FS:  00007fa4795896f0(0000) GS:ffff8800cda00000(0000) knlGS:0000000000000000
[   98.791744] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   98.791745] CR2: 0000000000000000 CR3: 0000000221b98000 CR4: 00000000000406b0
[   98.791747] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   98.791749] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   98.791750] Process modprobe (pid: 3337, threadinfo ffff880221b8e000, task ffff88021cc243b0)
[   98.791752] Stack:
[   98.791752]  ffff8802255e2180 00000000ffffffef ffffffffa01b80a0 ffff880221bd9c68
[   98.791755]  ffff880221b8fec8 ffffffff8118bf33 0000000a685497ea ffffffffa01b80a8
[   98.791758]  ffff880221b8fec8 ffff880221bd9c00 0000000000000000 0000000000000000
[   98.791760] Call Trace:
[   98.791765]  [<ffffffff8118bf33>] configfs_register_subsystem+0x103/0x1c0
[   98.791768]  [<ffffffffa0006260>] init_netconsole+0x260/0x1000 [netconsole]
[   98.791771]  [<ffffffffa0006000>] ? init_netconsole+0x0/0x1000 [netconsole]
[   98.791775]  [<ffffffff810001de>] do_one_initcall+0x3e/0x170
[   98.791778]  [<ffffffff81086e26>] sys_init_module+0x106/0x280
[   98.791780]  [<ffffffff81002dbb>] system_call_fastpath+0x16/0x1b
[   98.791781] Code: 84 83 00 00 00 49 8d 7c 24 20 e8 45 c4 3f 00 85 c0 0f 1f 00 75 6e 41 fe 45 00 f3 90 4c 89 ef 45 31 f6 e8 5d c4 3f 00 4c 8b 63 30 <41> 0f b7 04 24 25 00 f0 00 00 3d 00 40 00 00 41 0f 94 c6 83 7b 
[   98.791799] RIP  [<ffffffff81131977>] d_delete+0x47/0x180
[   98.791801]  RSP <ffff880221b8fe68>
[   98.791802] CR2: 0000000000000000
[   98.791804] ---[ end trace 0bbba7195aad7eaa ]---

--6c2NcOVqGQ03X4Wi
Content-Type: application/x-sh
Content-Disposition: attachment; filename="netconsole-on-network.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/sh=0A#/sbin/ifconfig eth1=0A# Modified /etc/udev/rules.d/70-persista=
nt-net.rules to rename it to eth0=0A/sbin/ifconfig eth0=0Asudo dmesg -n 8=0A
--6c2NcOVqGQ03X4Wi
Content-Type: application/x-sh
Content-Disposition: attachment; filename="netconsole-ending-on-network.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/sh=0Asudo dmesg -n 8=0Asudo modprobe netconsole netconsole=3D@/eth0,=
@192.168.1.138/=0A
--6c2NcOVqGQ03X4Wi--
