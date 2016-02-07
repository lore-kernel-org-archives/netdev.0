From: Thomas Elliott <tommygunsster@gmail.com>
Subject: e1000e er32(TIMINCA) value returned 0 Virtual Machiens
Date: Sun, 7 Feb 2016 10:28:48 -0500
Message-ID: <CAHC3ikmsH5KikrSMtCx+DWvnJyuhZ48JZGKK7MiYnLMV6wc=Kw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:35286 "EHLO
	mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753902AbcBGP2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 10:28:48 -0500
Received: by mail-yw0-f172.google.com with SMTP id g127so86359231ywf.2
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 07:28:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug potentially specific to VM's, particularly in this case VMWare 6.0.

Issue was found to occur when a VMWare virtual machine was setup to
operate as OS type Windows 8 or Windows 10.

The issue is the NIC defaults, in this setup, to e1000e Driver.

>From a Kernel 4.4.0 build, but this happens from mainline all the way
back as far as Kernel 3.19 (possibly further).

The specifics of the problem from a serial output are:

Linux version 4.4.0 (root@debian64) (gcc version 4.9.2 (Debian
4.9.2-10) ) #2 SMP Mon Jan 25 12:44:48 EST 2016
ACPI: RSDP 0x00000000000F6AC0 000024 (v02 PTLTD )
ACPI: XSDT 0x000000003FEF114C 00005C (v01 INTEL  440BX    06040000 VMW
 01324272)
ACPI: FACP 0x000000003FEFEE73 0000F4 (v04 INTEL  440BX    06040000 PTL
 000F4240)
ACPI: DSDT 0x000000003FEF13B4 00DABF (v01 PTLTD  Custom   06040000
MSFT 03000001)
ACPI: FACS 0x000000003FEFFFC0 000040
ACPI: FACS 0x000000003FEFFFC0 000040
ACPI: BOOT 0x000000003FEF138C 000028 (v01 PTLTD  $SBFTBL$ 06040000
LTP 00000001)
ACPI: APIC 0x000000003FEF133C 000050 (v01 PTLTD  ? APIC   06040000
LTP 00000000)
ACPI: MCFG 0x000000003FEF1300 00003C (v01 PTLTD  $PCITBL$ 06040000
LTP 00000001)
ACPI: SRAT 0x000000003FEF1248 0000B8 (v02 VMWARE MEMPLUG  06040000 VMW
 00000001)
ACPI: HPET 0x000000003FEF1210 000038 (v01 VMWARE VMW HPET 06040000 VMW
 00000001)
ACPI: WAET 0x000000003FEF11E8 000028 (v01 VMWARE VMW WAET 06040000 VMW
 00000001)
Kernel command line: loglevel=6 init=/sbin/init initrd=init.xz
root=/dev/ram0 rw ramdisk_size=127000 keymap= web=10.0.7.1/fog/
consoleblank=0 mac=00:0c:29:38:ec:42 ftp=10.2.1.5
storage=10.2.1.5:/images/ storageip=10.2.1.5 web=10.0.7.1/fog/ osid=50
consoleblank=0 irqpoll console=ttyS0,115200 console=tty0
hostname=ARCHTEST chkdsk=0 img=arch64 imgType=n imgPartitionType=all
imgid=5 imgFormat= PIGZ_COMP=-6 hostearly=1 mining=1 miningcores=1
miningpath=http://fogproject.org/fogpackage.zip type=down
Misrouted IRQ fixup and polling support enabled
This may significantly impact system performance
ACPI: 1 ACPI AML tables successfully acquired and loaded
perf_event_intel: CPUID marked event: 'cpu cycles' unavailable
perf_event_intel: CPUID marked event: 'instructions' unavailable
perf_event_intel: CPUID marked event: 'bus cycles' unavailable
perf_event_intel: CPUID marked event: 'cache references' unavailable
perf_event_intel: CPUID marked event: 'cache misses' unavailable
perf_event_intel: CPUID marked event: 'branch instructions' unavailable
perf_event_intel: CPUID marked event: 'branch misses' unavailable
[Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
ACPI: Enabled 2 GPEs in block 00 to 0F
SCSI subsystem initialized
FS-Cache: Loaded
FS-Cache: Netfs 'nfs' registered for caching
NFS: Registering the id_resolver key type
Key type id_resolver registered
Key type id_legacy registered
FS-Cache: Netfs 'cifs' registered for caching
Key type cifs.idmap registered
Warning: Processor Platform Limit event detected, but not handled.
Consider compiling CPUfreq support into your kernel.
Error creating debugfs parent
Loading Adaptec I2O RAID: Version 2.4 Build 5go
aic94xx: Adaptec aic94xx SAS/SATA driver version 1.0.3 loaded
scsi: <fdomain> Detection failed (no card)
iscsi: registered transport (qla4xxx)
GDT-HA: Storage RAID Controller Driver. Version: 3.05
3ware Storage Controller device driver for Linux v1.26.02.003.
3ware 9000 Storage Controller device driver for Linux v2.26.02.014.
scsi 0:0:0:0: Direct-Access     VMware   Virtual disk     1.0  PQ: 0 ANSI: 2
sd 0:0:0:0: [sda] 41943040 512-byte logical blocks: (21.4 GB/20.0 GiB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Cache data unavailable
sd 0:0:0:0: [sda] Assuming drive cache: write through
sd 0:0:0:0: [sda] Attached SCSI disk
scsi 2:0:0:0: CD-ROM            NECVMWar VMware IDE CDR10 1.00 PQ: 0 ANSI: 5
cxgb4vf: could not create debugfs entry, continuing
v1.01-e (2.4 port) Sep-11-2006  Donald Becker <becker@scyld.com>
  http://www.scyld.com/network/drivers.html
divide error: 0000 [#1] SMP
Modules linked in:
CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.4.0 #2
Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop
Reference Platform, BIOS 6.00 09/30/2014
task: ffff88003e4b8000 ti: ffff88003e4c0000 task.ti: ffff88003e4c0000
RIP: 0010:[<ffffffff8172817a>]  [<ffffffff8172817a>] 0xffffffff8172817a
RSP: 0000:ffff88003e4c3cf0  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff880038cdf640 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff880038cdf628
RBP: ffff880038cdf628 R08: 0000000000000032 R09: 0000000000000000
R10: 00000007ffffffff R11: 00000000070f8406 R12: 142fe5b9982e5912
R13: ffff880038cdcc38 R14: 0000000000000000 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff88003ea00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 0000000001f74000 CR4: 00000000000006b0
Stack:
 ffffffff81071eca ffff880038cdc780 0000000000000000 0000000000000000
 ffffffff8172ec3c 01a000002252a32c ffff880038cdc780 ffff880038cdcc38
 0000000000008000 ffff880038cdcc38 0000000000000003 ffff880038cdc000
Call Trace:
 [<ffffffff81071eca>] ? 0xffffffff81071eca
 [<ffffffff8172ec3c>] ? 0xffffffff8172ec3c
 [<ffffffff8172f5ec>] ? 0xffffffff8172f5ec
 [<ffffffff817301d9>] ? 0xffffffff817301d9
 [<ffffffff8133b2cd>] ? 0xffffffff8133b2cd
 [<ffffffff813b272c>] ? 0xffffffff813b272c
 [<ffffffff813b28eb>] ? 0xffffffff813b28eb
 [<ffffffff813b2898>] ? 0xffffffff813b2898
 [<ffffffff813b0fa9>] ? 0xffffffff813b0fa9
 [<ffffffff813b1f99>] ? 0xffffffff813b1f99
 [<ffffffff813b2e12>] ? 0xffffffff813b2e12
 [<ffffffff820854ff>] ? 0xffffffff820854ff
 [<ffffffff8100037d>] ? 0xffffffff8100037d
 [<ffffffff82055e52>] ? 0xffffffff82055e52
 [<ffffffff81aac107>] ? 0xffffffff81aac107
 [<ffffffff81aac10c>] ? 0xffffffff81aac10c
 [<ffffffff81ab07cf>] ? 0xffffffff81ab07cf
 [<ffffffff81aac107>] ? 0xffffffff81aac107
Code: 18 d6 ff ff 8b 80 00 b6 00 00 48 8b 8f 18 d6 ff ff 8b 89 04 b6
00 00 48 c1 e1 20 89 c0 48 09 c1 49 89 c9 49 29 d1 31 d2 4c 89 c8 <48>
f7 f6 48 85 d2 75 05 4d 39 d1 76 08 41 ff c8 48 89 ca 75 bd
RIP  [<ffffffff8172817a>] 0xffffffff8172817a
 RSP <ffff88003e4c3cf0>
---[ end trace 5900358cb1efc29f ]---
Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b

Kernel Offset: disabled
---[ end Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b

While I do understand that this is a problem at the VM software level,
it seems to appear in more than just VMWare.  We've seen similar
issues reported from Proxmox, VirtualBox, and even OpenVM.

A proposed fix is to check if TIMINCA is returned with 0, as division
by 0 seems to be the reasoning for the panic altogether.

As I understand this isn't a "normal" situation for physical boards,
it still seems a bit rought to always expect physical boards will
NEVER return 0 for this situation.

A potential patch to fix this can be done with a single line of code.

All this does is check if the value of incvalue is 0 and return systim
if it is.  This means you're not going to run into a situation and is
just plain, in my opinion, better error checking.  A single line of
code that allows VMs, and possibly future hardware that might present
this issue, from panicking over something that is so simple a check.

Patch from 4.4.1 kernel follows:

--- a/drivers/net/ethernet/intel/e1000e/netdev.c        2016-02-07
09:42:33.493965436 -0500
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c        2016-02-07
09:43:16.853965023 -0500
@@ -4313,6 +4313,7 @@ static cycle_t e1000e_cyclecounter_read(
                 * rate and is a multiple of incvalue
                 */
                incvalue = er32(TIMINCA) & E1000_TIMINCA_INCVALUE_MASK;
+        if (incvalue == 0) return systim;
                for (i = 0; i < E1000_MAX_82574_SYSTIM_REREADS; i++) {
                        /* latch SYSTIMH on read of SYSTIML */
                        systim_next = (cycle_t)er32(SYSTIML);
