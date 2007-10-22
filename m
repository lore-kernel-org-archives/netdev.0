From: Gabriel C <nix.or.die@googlemail.com>
Subject: appletalk bugs
Date: Mon, 22 Oct 2007 16:19:05 +0200
Message-ID: <471CB159.1070706@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.226]:64149 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751617AbXJVOTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 10:19:25 -0400
Received: by wr-out-0506.google.com with SMTP id 36so777364wra
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 07:19:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

modprobing appletalk on current git gives a warning in dmesg :

[38506.600269] sysctl table check failed: /net/appletalk .3.7 procname does not match binary path procname

on rmmod appletalk I get an Oops :


[38541.525258] BUG: unable to handle kernel NULL pointer dereference at virtual address 0000000c
[38541.525266] printing eip: c011d4f0 *pde = 00000000 
[38541.525274] Oops: 0000 [#1] PREEMPT SMP 
[38541.525282] Modules linked in: appletalk psnap llc pc87360 hwmon_vid eeprom adm1021 sr_mod shpchp pci_hotplug iTCO_wdt iTCO_vendor_support intel_agp i82860_edac i2c_i801 edac_core cdrom agpgart 3c59x mii ext4dev jbd2 crc16 loop lp parport_pc parport evdev
[38541.525312] 
[38541.525316] Pid: 28887, comm: rmmod Not tainted (2.6.23-gcfa76f02 #341)
[38541.525321] EIP: 0060:[<c011d4f0>] EFLAGS: 00010202 CPU: 0
[38541.525334] EIP is at unregister_sysctl_table+0x11/0x70
[38541.525339] EAX: 00000001 EBX: e8ef2180 ECX: 00000002 EDX: 00000000
[38541.525343] ESI: 00000000 EDI: 00000880 EBP: cc094000 ESP: cc095f38
[38541.525347]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[38541.525352] Process rmmod (pid: 28887, ti=cc094000 task=e0da0560 task.ti=cc094000)
[38541.525355] Stack: 00000001 00000296 cebf5020 fffffff5 00000880 e8ef2180 00000000 e8eed5b1 
[38541.525367]        c01353b2 6c707061 6c617465 b7ee006b e0da0560 c01101fd 00000000 c2bf3a50 
[38541.525378]        c0148684 ffffffff b7fd5000 c31a2004 b7fd4000 b7fd5000 00000004 00095fb8 
[38541.525389] Call Trace:
[38541.525395]  [<e8eed5b1>] atalk_exit+0x5/0x4b [appletalk]
[38541.525410]  [<c01353b2>] sys_delete_module+0x187/0x1b5
[38541.525420]  [<c01101fd>] do_page_fault+0x18b/0x51a
[38541.525426]  [<c0148684>] do_munmap+0x19b/0x1b4
[38541.525437]  [<c01026fa>] sysenter_past_esp+0x5f/0x85
[38541.525448]  =======================
[38541.525450] Code: ff ff ff f7 d8 eb 06 c7 03 00 00 00 00 e8 65 df ff ff 89 07 31 c0 5b 5e 5f c3 56 53 83 ec 14 89 c6 b8 b8 1c 3c c0 e8 c6 42 1f 00 <83> 7e 0c 00 74 2e c7 04 24 00 00 00 00 8d 44 24 04 e8 66 a2 00 
[38541.525502] EIP: [<c011d4f0>] unregister_sysctl_table+0x11/0x70 SS:ESP 0068:cc095f38
[38541.525513] note: rmmod[28887] exited with preempt_count 1

Regards,

Gabriel C

