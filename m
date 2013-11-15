From: Honggang LI <honli@redhat.com>
Subject: Re: [PATCH] rds: Error on offset mismatch if not loopback
Date: Fri, 15 Nov 2013 10:32:48 +0800
Message-ID: <528587D0.5060105@redhat.com>
References: <20120921213239.GJ14393@linux-tkdk.sfcn.org>	<20120922.152524.1294103117346567757.davem@davemloft.net>	<CAKA=qzac9=UhLF_Z4FnnH+sR7xvkDux4oayC6dPYe=hMLsDxRg@mail.gmail.com>	<CAKA=qzYpd7Wo9XdU16TEhnbm5dPJjOZMhAY1jA7N+YFBWz5pzw@mail.gmail.com>	<23964ca1-e7cb-41c3-9da2-5bc1b2b0c014@default> <CAKA=qzbK1YX5OrVQbwM=1xM6Si=GKv0UDofULkOC7RNo08zZPw@mail.gmail.com> <52841F95.7040204@redhat.com> <41aa904c-6707-4c74-ae72-96e401c68e13@default>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040501020003090303020603"
Cc: David Miller <davem@davemloft.net>, jjolly@suse.com,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	Josh Hunt <joshhunt00@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56453 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753213Ab3KOCdG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Nov 2013 21:33:06 -0500
In-Reply-To: <41aa904c-6707-4c74-ae72-96e401c68e13@default>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040501020003090303020603
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 11/14/2013 09:43 PM, Venkat Venkatsubra wrote:
>
> -----Original Message-----
> From: Honggang LI [mailto:honli@redhat.com] 
> Sent: Wednesday, November 13, 2013 6:56 PM
> To: Josh Hunt; Venkat Venkatsubra
> Cc: David Miller; jjolly@suse.com; LKML; netdev@vger.kernel.org
> Subject: Re: [PATCH] rds: Error on offset mismatch if not loopback
>
> On 11/14/2013 01:40 AM, Josh Hunt wrote:
>> On Wed, Nov 13, 2013 at 9:16 AM, Venkat Venkatsubra 
>> <venkat.x.venkatsubra@oracle.com> wrote:
>>> -----Original Message-----
>>> From: Josh Hunt [mailto:joshhunt00@gmail.com]
>>> Sent: Tuesday, November 12, 2013 10:25 PM
>>> To: David Miller
>>> Cc: jjolly@suse.com; LKML; Venkat Venkatsubra; netdev@vger.kernel.org
>>> Subject: Re: [PATCH] rds: Error on offset mismatch if not loopback
>>>
>>> On Tue, Nov 12, 2013 at 10:22 PM, Josh Hunt <joshhunt00@gmail.com> wrote:
>>>> On Sat, Sep 22, 2012 at 2:25 PM, David Miller <davem@davemloft.net> wrote:
>>>>> From: John Jolly <jjolly@suse.com>
>>>>> Date: Fri, 21 Sep 2012 15:32:40 -0600
>>>>>
>>>>>> Attempting an rds connection from the IP address of an IPoIB 
>>>>>> interface to itself causes a kernel panic due to a BUG_ON() being triggered.
>>>>>> Making the test less strict allows rds-ping to work without 
>>>>>> crashing the machine.
>>>>>>
>>>>>> A local unprivileged user could use this flaw to crash the system.
>>>>>>
>>>>>> Signed-off-by: John Jolly <jjolly@suse.com>
>>>>> Besides the questions being asked of you by Venkat Venkatsubra, 
>>>>> this patch has another issue.
>>>>>
>>>>> It has been completely corrupted by your email client, it has 
>>>>> turned all TAB characters into spaces, making the patch useless.
>>>>>
>>>>> Please learn how to send a patch unmolested in the body of your 
>>>>> email.  Test it by emailing the patch to yourself, and verifying 
>>>>> that you can in fact apply the patch you receive in that email.
>>>>> Then, and only then, should you consider making a new submission of 
>>>>> this patch.
>>>>>
>>>>> Use Documentation/email-clients.txt for guidance.
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe 
>>>>> linux-kernel" in the body of a message to majordomo@vger.kernel.org 
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>> Please read the FAQ at  http://www.tux.org/lkml/
>>>> I think this issue was lost in the shuffle. It appears that redhat, 
>>>> ubuntu, and oracle are maintaining local patches to resolve this:
>>>>
>>>> https://oss.oracle.com/git/?p=redpatch.git;a=commit;h=c7b6a0a1d8d636
>>>> 85
>>>> 2be130fa15fa8be10d4704e8
>>>> https://bugzilla.redhat.com/show_bug.cgi?id=822754
>>>> http://ubuntu.5.x6.nabble.com/CVE-2012-2372-RDS-local-ping-DOS-td498
>>>> 53
>>>> 88.html
>>>>
>>>> Given that Oracle has applied it I'll make the assumption that 
>>>> Venkat's question was answered at some point.
>>>>
>>>> David - I can resubmit the patch with the proper signed-off-by and 
>>>> formatting if you are willing to apply it unless John wants to try 
>>>> again. I think it's time this got upstream.
>>>>
>>>> --
>>>> Josh
>>> Ugh.. hopefully resending with all the html crap removed...
>>>
>>> --
>>> Josh
>>>
>>> Hi Josh,
>>>
>>> No, I still didn't get an answer for how "off" could be non-zero in case of rds-ping to hit BUG_ON(off % RDS_FRAG_SIZE).
>>> Because, rds-ping uses zero byte messages to ping.
>>> If you have a test case that reproduces the kernel panic I can try it out and see how that can happen.
>>> The Oracle's internal code I checked doesn't have that patch applied.
>>>
>>> Venkat
>> No I don't have a test case. I came across this CVE while doing an 
>> audit and noticed it was patched in Ubuntu's kernel and other distros, 
>> but was not in the upstream kernel yet. Quick googling of lkml showed 
>> that there were at least two attempts to get this patch upstream, but 
>> both had issues due to not following the proper submission process:
>>
>> https://lkml.org/lkml/2012/10/22/433
>> https://lkml.org/lkml/2012/9/21/505
>>
>> From my searching it appears the initial bug was found by someone at redhat:
>> https://bugzilla.redhat.com/show_bug.cgi?id=822754
>>
>> I've added Li Honggang the reporter of this issue from Redhat to the 
>> mail. Hopefully he can share his testcase.
> The test case is very simple:
> Steps to Reproduce:
> 1. yum install -y rds-tools
>
> 2. [root@rdma3 ~]# ifconfig ib0 | grep 'inet addr'
>           inet addr:172.31.0.3  Bcast:172.31.0.255  Mask:255.255.255.0
>
> 3. [root@rdma3 ~]# /usr/bin/rds-ping 172.31.0.3  <<<< kernel panic (You may need to wait for a few seconds before the kernel panic.)
>> and possibly requires certain hardware as Jay writes in the first link above:
>> "...some Infiniband HCAs(QLogic, possibly others) the machine will panic..."
> This bug can be reproduced with Mellanox HCAs (mlx4_ib.ko and mthca.ko), QLogic HCA (ib_qib.ko). I did not test the QLogic HCA running "ib_ipath.ko".
>
> As I know the upstream code of RDS is broken. There are *many* RDS bugs.
>
> Best regards.
> Honggang
>> I was referring to this oracle commit:
>> https://oss.oracle.com/git/?p=redpatch.git;a=commit;h=c7b6a0a1d8d63685
>> 2be130fa15fa8be10d4704e8
>>
>> I have no experience with this code. There were a few comments around 
>> the reset and xmit fns about making sure the caller did certain things 
>> if not they were racy, but I have no idea if that's coming into play 
>> here.
>>
> Hi Honggang,
>
> I ran rds-ping over local interface for 30 minutes. I stopped it after that.
> It didn't hit any panic.
>
> # ip addr show dev ib0
> 6: ib0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 2044 qdisc pfifo_fast qlen 1024
>     link/infiniband 80:00:00:48:fe:80:00:00:00:00:00:00:00:21:28:00:01:cf:63:db brd 00:ff:ff:ff:ff:12:40:1b:ff:ff:00:00:00:00:00:00:ff:ff:ff:ff
>     inet 10.196.4.125/30 brd 10.196.4.127 scope global ib0
>     inet6 fe80::221:2800:1cf:63db/64 scope link
>        valid_lft forever preferred_lft forever
> #
>
> # rds-ping  10.196.4.125
>     1: 170 usec
>     2: 171 usec 
>    ....
>    ....
>    ....
>  1860: 173 usec
>  1861: 171 usec
>  1862: 177 usec
>  1863: 168 usec
>  1864: 171 usec
>  1865: 175 usec
> ^C#
>
> I tested with Oracle UEK2 which is based on 2.6.39 kernel. Mellanox IB adaptor.
> 19:00.0 InfiniBand: Mellanox Technologies MT26428 [ConnectX VPI PCIe 2.0 5GT/s - IB QDR / 10GigE] (rev b0)
>
> There is something about your setup that must be causing it for you.
> Can I work with you offline if you are available ?
>
> The panic you are hitting is not making sense to me.
>
> Venkat
Hi, Venkat
 It seems we are in different time zone. Please contact me via email if
you need I do something for this bug. Could you please try upstream
kernel 2.6.39. I confirmed that the bug can be reproduced with Mellanox
and QLogic HCA when running  upstream kernel-2.6.39.

[root@rdma01 ~]# ifconfig mlx4_ib1
Ifconfig uses the ioctl access method to get the full address
information, which limits hardware addresses to 8 bytes.
Because Infiniband address has 20 bytes, only the first 8 bytes are
displayed correctly.
Ifconfig is obsolete! For replacement check ip.
mlx4_ib1  Link encap:InfiniBand  HWaddr
80:00:00:48:FE:80:00:00:00:00:00:00:00:00:00:00:00:00:00:00 
          inet addr:172.31.2.1  Bcast:172.31.2.255  Mask:255.255.255.0
          inet6 addr: fe80::7ae7:d1ff:ff6b:b01/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:65520  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:5 overruns:0 carrier:0
          collisions:0 txqueuelen:256
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)

[root@rdma01 ~]# rpm -qf /usr/bin/rds-ping
rds-tools-2.0.6-3.el6.x86_64
[root@rdma01 ~]# uname -a
Linux rdma01.rhts.eng.nay.redhat.com 2.6.39 #1 SMP Thu Nov 14 20:25:45
EST 2013 x86_64 x86_64 x86_64 GNU/Linux
[root@rdma01 ~]# ibstat
CA 'mlx4_0'
    CA type: MT26428
    Number of ports: 2
    Firmware version: 2.8.600
    Hardware version: b0
    Node GUID: 0x78e7d1ffff6b0b00
    System image GUID: 0x78e7d1ffff6b0b03
    Port 1:
        State: Active
        Physical state: LinkUp
        Rate: 40
        Base lid: 1
        LMC: 0
        SM lid: 4
        Capability mask: 0x02510868
        Port GUID: 0x78e7d1ffff6b0b01
        Link layer: InfiniBand
    Port 2:
        State: Down
        Physical state: Polling
        Rate: 70
        Base lid: 0
        LMC: 0
        SM lid: 0
        Capability mask: 0x02510868
        Port GUID: 0x78e7d1ffff6b0b02
        Link layer: InfiniBand
[root@rdma01 ~]# lspci | grep Mellanox
1f:00.0 InfiniBand: Mellanox Technologies MT26428 [ConnectX VPI PCIe 2.0
5GT/s - IB QDR / 10GigE] (rev b0)
[root@rdma01 ~]# ssh 172.31.2.2 hostname   (make sure the IPoIB
interface works)
rdma02.rhts.eng.nay.redhat.com
[root@rdma01 ~]# ssh 172.31.2.1 hostname
rdma01.rhts.eng.nay.redhat.com
[root@rdma01 ~]# /usr/bin/rds-ping 172.31.2.1 (kernel panic, please see
the attachment for console log)








--------------040501020003090303020603
Content-Type: text/x-log;
 name="upstream-kernel-2.6.39-rds-ping-panic.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="upstream-kernel-2.6.39-rds-ping-panic.log"

RDS/IB: connected to 172.31.2.1 version 3.1
RDS/IB: connected to 172.31.2.1 version 3.1
------------[ cut here ]------------
kernel BUG at net/rds/ib_send.c:547!
invalid opcode: 0000 [#1] SMP 
last sysfs file: /sys/devices/system/cpu/online
CPU 6 
Modules linked in: ib_iser libiscsi scsi_transport_iscsi ib_srp scsi_transport_srp scsi_tgt rds_rdma rds_tcp rds ib_ipoib rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm ib_addr ipv6 ib_sa microcode cdc_ether usbnet mii serio_raw pcspkr i2c_i801 i2c_core iTCO_wdt iTCO_vendor_support sg shpchp ioatdma dca i7core_edac edac_core cxgb3 mdio mlx4_ib ib_mad mlx4_en mlx4_core ib_core cxgb4 bnx2 ext4 mbcache jbd2 sd_mod crc_t10dif pata_acpi ata_generic ata_piix megaraid_sas dm_mirror dm_region_hash dm_log dm_mod [last unloaded: scsi_wait_scan]

Pid: 136, comm: kworker/u:1 Not tainted 2.6.39 #1 IBM System x3650 M3 -[7945O63]-/00D4062
RIP: 0010:[<ffffffffa036d7f9>]  [<ffffffffa036d7f9>] rds_ib_xmit+0xa69/0xaf0 [rds_rdma]
RSP: 0018:ffff880271b51c50  EFLAGS: 00010202
RAX: ffff880266dc2000 RBX: ffff880271639a00 RCX: 0000000000000000
RDX: 0000000000000030 RSI: ffff880471e81000 RDI: ffff880270997cf0
RBP: ffff880271b51d30 R08: 0000000000000fd0 R09: ffff880471e81190
R10: 00000000ffffffff R11: 0000000000000001 R12: ffff880471e81000
R13: ffff880471e81000 R14: 0000000000000000 R15: ffff880271b51d90
FS:  0000000000000000(0000) GS:ffff88047fc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00002b302d2aa080 CR3: 0000000001a03000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kworker/u:1 (pid: 136, threadinfo ffff880271b50000, task ffff880271ae60c0)
Stack:
 0000000000000400 0000000000000001 0000000000000001 0000000a0000000a
 0000000000000128 ffffffff8114747c 0000000000000002 0000000000000001
 ffff880271ae60c0 ffffffff812402f0 ffff880471e81000 0000003000000002
Call Trace:
 [<ffffffff8114747c>] ? __kmalloc+0x21c/0x230
 [<ffffffff812402f0>] ? sg_init_table+0x30/0x50
 [<ffffffffa0340df2>] ? rds_message_alloc_sgs+0x62/0xa0 [rds]
 [<ffffffffa0341224>] ? rds_message_map_pages+0xa4/0x110 [rds]
 [<ffffffffa0342f5b>] rds_send_xmit+0x38b/0x6e0 [rds]
 [<ffffffffa0344010>] ? rds_recv_worker+0xc0/0xc0 [rds]
 [<ffffffffa0344045>] rds_send_worker+0x35/0xc0 [rds]
 [<ffffffff8107d0f9>] process_one_work+0x129/0x430
 [<ffffffff8107f4ab>] worker_thread+0x17b/0x3c0
 [<ffffffff8107f330>] ? manage_workers+0x120/0x120
 [<ffffffff81084566>] kthread+0x96/0xa0
 [<ffffffff814e4104>] kernel_thread_helper+0x4/0x10
 [<ffffffff810844d0>] ? kthread_worker_fn+0x1a0/0x1a0
 [<ffffffff814e4100>] ? gs_change+0x13/0x13
Code: ff ff e9 b1 fe ff ff 48 8b 0d c4 fe 69 e1 48 89 8d 70 ff ff ff e9 71 ff ff ff 83 bd 7c ff ff ff 00 0f 84 f4 f5 ff ff 0f 0b eb fe <0f> 0b eb fe 44 8b 8d 48 ff ff ff 41 b7 01 e9 51 f6 ff ff 0f 0b 
RIP  [<ffffffffa036d7f9>] rds_ib_xmit+0xa69/0xaf0 [rds_rdma]
 RSP <ffff880271b51c50>
---[ end trace de7f8972e25cd611 ]---
BUG: unable to handle kernel paging request at fffffffffffffff8
IP: [<ffffffff810840c0>] kthread_data+0x10/0x20
PGD 1a05067 PUD 1a06067 PMD 0 
Oops: 0000 [#2] SMP 
last sysfs file: /sys/devices/system/cpu/online
CPU 6 
Modules linked in: ib_iser libiscsi scsi_transport_iscsi ib_srp scsi_transport_srp scsi_tgt rds_rdma rds_tcp rds ib_ipoib rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm ib_addr ipv6 ib_sa microcode cdc_ether usbnet mii serio_raw pcspkr i2c_i801 i2c_core iTCO_wdt iTCO_vendor_support sg shpchp ioatdma dca i7core_edac edac_core cxgb3 mdio mlx4_ib ib_mad mlx4_en mlx4_core ib_core cxgb4 bnx2 ext4 mbcache jbd2 sd_mod crc_t10dif pata_acpi ata_generic ata_piix megaraid_sas dm_mirror dm_region_hash dm_log dm_mod [last unloaded: scsi_wait_scan]

Pid: 136, comm: kworker/u:1 Tainted: G      D     2.6.39 #1 IBM System x3650 M3 -[7945O63]-/00D4062
RIP: 0010:[<ffffffff810840c0>]  [<ffffffff810840c0>] kthread_data+0x10/0x20
RSP: 0018:ffff880271b51918  EFLAGS: 00010096
RAX: 0000000000000000 RBX: 0000000000000006 RCX: ffff880271ae60c0
RDX: 0000000000009bf5 RSI: 0000000000000006 RDI: ffff880271ae60c0
RBP: ffff880271b51918 R08: ffff880271ae6570 R09: dead000000200200
R10: 00000000ffffffff R11: 0000000000000007 R12: ffff880271ae6658
R13: 0000000000000006 R14: 0000000000000006 R15: 0000000000000006
FS:  0000000000000000(0000) GS:ffff88047fc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: fffffffffffffff8 CR3: 0000000001a03000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kworker/u:1 (pid: 136, threadinfo ffff880271b50000, task ffff880271ae60c0)
Stack:
 ffff880271b51938 ffffffff8107e385 ffff880272d67b40 ffff88047fc150c0
 ffff880271b519d8 ffffffff814d882e ffff880271b51978 ffff880271ae60c0
 ffff880271ae60c0 00000000000150c0 ffff880271b51fd8 ffff880271b50010
Call Trace:
 [<ffffffff8107e385>] wq_worker_sleeping+0x15/0xa0
 [<ffffffff814d882e>] schedule+0x49e/0x9c0
 [<ffffffff810675d1>] do_exit+0x271/0x430
 [<ffffffff814dc08b>] oops_end+0xab/0xf0
 [<ffffffff8100e7cb>] die+0x5b/0x90
 [<ffffffff814db994>] do_trap+0xc4/0x170
 [<ffffffff8100c695>] do_invalid_op+0x95/0xb0
 [<ffffffffa036d7f9>] ? rds_ib_xmit+0xa69/0xaf0 [rds_rdma]
 [<ffffffff814e3f7b>] invalid_op+0x1b/0x20
 [<ffffffffa036d7f9>] ? rds_ib_xmit+0xa69/0xaf0 [rds_rdma]
 [<ffffffff8114747c>] ? __kmalloc+0x21c/0x230
 [<ffffffff812402f0>] ? sg_init_table+0x30/0x50
 [<ffffffffa0340df2>] ? rds_message_alloc_sgs+0x62/0xa0 [rds]
 [<ffffffffa0341224>] ? rds_message_map_pages+0xa4/0x110 [rds]
 [<ffffffffa0342f5b>] rds_send_xmit+0x38b/0x6e0 [rds]
 [<ffffffffa0344010>] ? rds_recv_worker+0xc0/0xc0 [rds]
 [<ffffffffa0344045>] rds_send_worker+0x35/0xc0 [rds]
 [<ffffffff8107d0f9>] process_one_work+0x129/0x430
 [<ffffffff8107f4ab>] worker_thread+0x17b/0x3c0
 [<ffffffff8107f330>] ? manage_workers+0x120/0x120
 [<ffffffff81084566>] kthread+0x96/0xa0
 [<ffffffff814e4104>] kernel_thread_helper+0x4/0x10
 [<ffffffff810844d0>] ? kthread_worker_fn+0x1a0/0x1a0
 [<ffffffff814e4100>] ? gs_change+0x13/0x13
Code: 1f 44 00 00 65 48 8b 04 25 80 cc 00 00 48 8b 80 40 05 00 00 8b 40 f0 c9 c3 66 90 55 48 89 e5 0f 1f 44 00 00 48 8b 87 40 05 00 00 
 8b 40 f8 c9 c3 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 0f 
RIP  [<ffffffff810840c0>] kthread_data+0x10/0x20
 RSP <ffff880271b51918>
CR2: fffffffffffffff8
---[ end trace de7f8972e25cd612 ]---
Fixing recursive fault but reboot is needed!



--------------040501020003090303020603--
