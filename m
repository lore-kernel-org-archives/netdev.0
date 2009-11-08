From: Philippe De Muyter <phdm@macqel.be>
Subject: tulip : kernel BUG in tulip_up/tulip_resume
Date: Sun, 8 Nov 2009 23:33:05 +0100
Message-ID: <20091108223305.GA21072@frolo.macqel>
References: <20090127165727.GA25748@frolo.macqel> <20090129210701.GA8092@frolo.macqel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: grundler@parisc-linux.org, kyle@mcmartin.ca,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay007.isp.belgacom.be ([195.238.6.173]:14735 "EHLO
	mailrelay007.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755501AbZKHWdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 17:33:08 -0500
Content-Disposition: inline
In-Reply-To: <20090129210701.GA8092@frolo.macqel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have just installed 2.6.31 (from opensuse 11.2) one a tulip-equipped
computer and I get the following error message from the kernel :

[ 2495.526390] ------------[ cut here ]------------
[ 2495.526390] kernel BUG at /usr/src/packages/BUILD/kernel-default-2.6.31.5/linux-2.6.31/include/linux/netdevice.h:439!
[ 2495.526390] invalid opcode: 0000 [#1] SMP 
[ 2495.526390] last sysfs file: /sys/devices/pci0000:00/0000:00:07.1/host0/target0:0:0/0:0:0:0/block/sda/uevent
[ 2495.526390] Modules linked in: ohci_hcd raw1394 ohci1394 ieee1394 acpi_cpufreq speedstep_lib processor thermal_sys hwmon edd ipv6 af_packet fuse loop dm_mod rtc_cmos rtc_core rtc_lib apm pcspkr sg tulip uhci_hcd ehci_hcd reiserfs ata_piix ahci libata
[ 2495.526390] 
[ 2495.526390] Pid: 339, comm: kapmd Not tainted (2.6.31.5-0.1-default #1) 
[ 2495.526390] EIP: 0060:[<c3d6045d>] EFLAGS: 00010246 CPU: 0
[ 2495.526390] EIP is at tulip_up+0xa2d/0xa80 [tulip]
[ 2495.526390] EAX: 00000000 EBX: c1cd7000 ECX: c022af50 EDX: 0001ec00
[ 2495.526390] ESI: c1cd7340 EDI: 00000000 EBP: c20bde44 ESP: c20bddfc
[ 2495.526390]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[ 2495.526390] Process kapmd (pid: 339, ti=c20bc000 task=c25a32c0 task.ti=c20bc000)
[ 2495.526390] Stack:
[ 2495.526390]  0000000b c20bde44 c02acf76 2caa9a94 c2481800 c20bde38 c043ca4a c20bde27
[ 2495.526390] <0> 069ee44b c20ec120 c087c020 0001ec00 c1cd7000 c3d5c720 2caa9a94 c1cd7000
[ 2495.526390] <0> c2480000 00000000 c20bde68 c3d60555 00000080 c1cd7000 c1cd7000 2caa9a94
[ 2495.526390] Call Trace:
[ 2495.526390]  [<c3d60555>] tulip_resume+0xa5/0xd0 [tulip]
[ 2495.526390]  [<c043dd65>] pci_legacy_resume+0x35/0x60
[ 2495.526390]  [<c043df2f>] pci_pm_resume+0x7f/0xb0
[ 2495.526390]  [<c04d82f2>] pm_op+0xd2/0x180
[ 2495.526390]  [<c04d91ee>] device_resume+0x5e/0x1a0
[ 2495.526390]  [<c04d93dd>] dpm_resume+0xad/0x140
[ 2495.526390]  [<c04d948b>] dpm_resume_end+0x1b/0x40
[ 2495.526390]  [<c3db1978>] check_events+0x148/0x240 [apm]
[ 2495.526390]  [<c3db23a2>] apm_mainloop+0x82/0x130 [apm]
[ 2495.526390]  [<c3db28fe>] apm+0x10e/0x3d0 [apm]
[ 2495.526390]  [<c026bef4>] kthread+0x84/0x90
[ 2495.526390]  [<c0204db7>] kernel_thread_helper+0x7/0x10
[ 2495.526390] Code: 45 e4 e8 37 ce 6c fc 8b 4d e8 89 5c 24 10 89 7c 24 0c 89 4c 24 04 89 44 24 08 c7 04 24 4c 4e d6 c3 e8 86 f7 89 fc e9 f4 f8 ff ff <0f> 0b eb fe 0f be 96 16 09 00 00 b9 01 00 00 00 8b 45 e8 e8 fb 
[ 2495.526390] EIP: [<c3d6045d>] tulip_up+0xa2d/0xa80 [tulip] SS:ESP 0068:c20bddfc
[ 2495.534162] ---[ end trace 609ed25c95a75fa1 ]---

This comes from a BUG_ON in napi_enable in netdevice.h.

napi_enable itself is called by tulip_up as such :

#ifdef CONFIG_TULIP_NAPI
	napi_enable(&tp->napi);
#endif

At first reading, a matching napi_disable is called in tulip_down.

Does someone know what could be wrong and have a fix or should I look myself ?

Thanks in advance

Philippe
