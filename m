From: Stephen Hemminger <shemminger@osdl.org>
Subject: Fw: [Bug 3419] New: kernel BUG at net/ipv4/fib_semantics.c:1039!
Date: Wed, 22 Sep 2004 09:23:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922092319.4ba5b8fb@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: j@lumiere.net, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Is this fixed with the more recent version of 2.6.9?
Dave Miller fixed up several initialization bugs from his earlier
change.

Begin forwarded message:

Date: Sat, 18 Sep 2004 03:21:09 -0700
From: bugme-daemon@osdl.org
To: shemminger@osdl.org
Subject: [Bug 3419] New: kernel BUG at net/ipv4/fib_semantics.c:1039!


http://bugme.osdl.org/show_bug.cgi?id=3419

           Summary: kernel BUG at net/ipv4/fib_semantics.c:1039!
    Kernel Version: 2.6.9-rc2-bk3
            Status: NEW
          Severity: normal
             Owner: shemminger@osdl.org
         Submitter: j@lumiere.net


Distribution: Fedora Core 2 (i686)
Hardware Environment:
P4 3.2GHz 1MB cache, SuperMicro P4SCT+, 1 GB ECC RAM (2 x 512), 4 x SATA HD.
Onboard components include two gigabit ethernet controllers, LAN1/eth0 in use
(100Mbps, e1000). LAN1: Intel 82547GI (uses CSA), LAN2: (82541GI). Hance Rapids
(6300ESB) ICH, Marvell 88SX5041 SATA controller.

Software Environment:
Fedora Core 2, updated to latest standard updates. Vanilla 2.6.9-rc2-bk3 kernel.

Problem Description:
During kudzu running on bootup, kernel BUG at net/ipv4/fib_semantics.c:1039!
occurs. Boot continues until "Bringing up loopback interface:" at which point it
gets stuck. Can still scroll up/down. Does NOT occur on 2.6.9-rc2.

Steps to reproduce:
Boot with 2.6.9-rc2-bk3 kernel and wait for 'Checking for new hardware'. 

Here's output... possibly with a few typos, as it's copied by hand.
Checking for new hardware-------------[ cut here ]--------------
kernel BUG at net/ipv4/fib_semantics.c:1039!
invalid operand: 0000 [#1]
SMP
Modules linked in: e1000 floppy sg microcode uhci_hcd ehci_hcd button battery
asus_acpi ac ext3 jbd dm_mod ata_piix libata sd_mod linuxIAL scsi_mod raid5 xor
raid1
CPU:    1
EIP:    0060:[<c02be5c1>]    Tainted: P   VLI
EFLAGS: 00010246   (2.6.9-rc2-bk3-leaf)
EIP is at fib_sync_down+0x197/0x1a4
eax: ffffffff   ebx: 00000000   ecx: 00000002   edx: f7395000
esi: 00000000   edi: 00000006   ebp: f6395028   esp: f640dea8
ds: 007b   es: 007b   ss: 0068
Process modprobe (pid: 924, threadinfo=f640d000 task=f7c38550)
Stack: 00000282 c0104fd0 ffffffff 00000000 00000002 f6395000 f6395000 f6395000
       00000006 f6395028 c02bcb35 c03455fc c02bcc14 c03455fc f6395000 c012ac76
       f6395000 f6395000 c0339da8 c027bf23 00000000 c016c13a c014adda 00000292
Call Trace:
 [<c0104fd0>]__down_trylock+0x3e/0x62
 [<c02bcb35>] fib_disable_ip+0xe/0x28
 [<c02bcc14>] fib_netdev_event+0x72/0x7e
 [<c012ac76>] notifier_call_chain+0x17/0x2b
 [<c027bf23>] unregister_netdevice+0x137/0x249
 [<c016c13a>] wake_up_inode+0xc/0x3b
 [<c016adda>] clear_inode+0x8/0xe2
 [<c0221051>] unregister_netdev+0xf/0x15
 [<f8c0394e>] e1000_remove+0x4c/0x7e [e1000]
 [<c01bd396>] pci_device_remove+0x28/0x2a
 [<c0212fd2>] device_release_driver+0x56/0x58
 [<c0212fea>] driver_detach+0x16/0x21
 [<c02133bc>] bus_remove_driver+0x43/0x74
 [<c02137da>] driver_unregister+0x8/0x19
 [<c01bd471>] pci_unregister_driver+0xb/0x13
 [<c0133232>] sys_delete_module+0x121/0x150
 [<c0149868>] unmap_vma_list+0xe/0x17
 [<c0149bac>] do_munmap+0x11c/0x15f
 [<c0118de0>] do_page_fault+0x0/0x54b
 [<c0105e1d>] sysenter_past_esp+0x52/0x71
Code: e8 5b t1 01 00 83 04 24 01 8b 4f 5c eb 89 0f 0b 2a 04 1c b9 30 c0 e9 3a ff
ff ff 83 48 1c 01 83 44 24 0c 01 8b 11 e9 dd fe ff ff <0f> 0b 0f 04 1c b9 30 c0
e9 9b fe ff ff 55 57 56 53 83 ec 10 89
  [  OK  ]
Updating /etc/fstab [  OK  ]
Setting network parameters:  [  OK  ]
Bringing up loopback interface:

------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.
