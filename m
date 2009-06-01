From: Minoru Usui <usui@mxm.nes.nec.co.jp>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Mon, 1 Jun 2009 18:12:01 +0900
Message-ID: <20090601181201.ca1c2832.usui@mxm.nes.nec.co.jp>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: containers@lists.linux-foundation.org, netdev@vger.kernel.org,
	hadi@cyberus.ca, jarkao2@gmail.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:46608 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752731AbZFAXxL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 19:53:11 -0400
In-Reply-To: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas

Original mail sent to netdev and containers before.
(http://www.spinics.net/lists/netdev/msg97745.html)

I have a question about how to use cls_cgroup.

On Thu, 21 May 2009 09:22:56 +0900
Minoru Usui <usui@mxm.nes.nec.co.jp> wrote:

> Hi
> 
> Unfortunately this is only panic report.
> 
> I used cgroup net_cls subsystem, then kernel panic occured.
> I attach panic message and kernel config in this mail's last paragraph.
> If my operation is wrong, could you tell me how to use net_cls and
> where the documentation is. 
> 
> # But I think panic is very bad even if my operation is wrong.

The cause of panic will fix soon. (Now I'll make a patch and will test it.)

I want to know how to use cls_cgroup correctly, so could you tell me how to use it if my operation is wrong. 
Now, I think I might have to specify 'handle' with tc command line, is this true?
But when I specified 'handle', I faced oops. X-P

----------------------------------------------------------------------------------------------------
Jun  1 16:16:58 StingerG kernel: BUG: unable to handle kernel NULL pointer dereference at (null)
Jun  1 16:16:58 StingerG kernel: IP: [<ffffffff8044753b>] cls_cgroup_change+0xf7/0x1f5
Jun  1 16:16:58 StingerG kernel: PGD 21181f067 PUD 20c40e067 PMD 0
Jun  1 16:16:58 StingerG kernel: Oops: 0000 [#1] SMP
Jun  1 16:16:58 StingerG kernel: last sysfs file: /sys/devices/pci0000:00/0000:00:02.0/0000:01:00.0/0000:02:02.0/0000:0c:00.1/irq
Jun  1 16:16:58 StingerG kernel: CPU 7
Jun  1 16:16:58 StingerG kernel: Modules linked in: sch_htb ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp autofs4 hidp rfcomm l2cap bluetooth sunrpc bonding dm_mirror dm_region_hash dm_log dm_multipath dm_mod sbs sbshc battery acpi_memhotplug ac ipv6 parport_pc lp parport e1000e ide_cd_mod sg rtc_cmos cdrom i5000_edac rtc_core button i2c_i801 serio_raw edac_core shpchp i2c_core rtc_lib pcspkr ata_piix libata sd_mod scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd [last unloaded: microcode]
Jun  1 16:16:58 StingerG kernel: Pid: 9202, comm: tc Not tainted 2.6.29.4.local #5 Express5800/120Rg-1 [N8100-1241]
Jun  1 16:16:58 StingerG kernel: RIP: 0010:[<ffffffff8044753b>]  [<ffffffff8044753b>] cls_cgroup_change+0xf7/0x1f5
Jun  1 16:16:58 StingerG kernel: RSP: 0018:ffff88021259d9b8  EFLAGS: 00010246
Jun  1 16:16:58 StingerG kernel: RAX: 00000000fffffffe RBX: ffff88020edd3b80 RCX: 0000000000000000
Jun  1 16:16:58 StingerG kernel: RDX: 0000000000000000 RSI: 0000000000000003 RDI: ffff88021259d9b8
Jun  1 16:16:58 StingerG kernel: RBP: ffff88022ccccd40 R08: ffffffff80510290 R09: 00007fff951f0000
Jun  1 16:16:58 StingerG kernel: R10: ffff88021259ded8 R11: 0000000000000000 R12: ffff880211807000
Jun  1 16:16:58 StingerG kernel: R13: 0000000000000001 R14: ffff88021259da68 R15: ffff880211807720
Jun  1 16:16:58 StingerG kernel: FS:  00007ff68d1dc6e0(0000) GS:ffff88022e1ab840(0000) knlGS:0000000000000000
Jun  1 16:16:58 StingerG kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Jun  1 16:16:58 StingerG kernel: CR2: 0000000000000000 CR3: 000000022b46b000 CR4: 00000000000006e0
Jun  1 16:16:58 StingerG kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000Jun  1 16:16:58 StingerG kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400Jun  1 16:16:58 StingerG kernel: Process tc (pid: 9202, threadinfo ffff88021259c000, task ffff88022aa6a840)Jun  1 16:16:58 StingerG kernel: Stack:
Jun  1 16:16:58 StingerG kernel:  ffff88020c4ad540 0000000000000000 0000000000000000 0000000000000000Jun  1 16:16:58 StingerG kernel:  0000000000000000 ffff88020c4191e8 00007fff951f0000 ffff88022d123010Jun  1 16:16:58 StingerG kernel:  ffff88022d123010 ffff88021180705c ffff88022ccccd40 ffff88022ccccd40
Jun  1 16:16:58 StingerG kernel: Call Trace:
Jun  1 16:16:58 StingerG kernel:  [<ffffffff80445620>] ? tc_ctl_tfilter+0x46d/0x53f
Jun  1 16:16:58 StingerG kernel:  [<ffffffff8043a2be>] ? rtnetlink_rcv_msg+0x0/0x1f3
Jun  1 16:16:58 StingerG kernel:  [<ffffffff804492cb>] ? netlink_rcv_skb+0x34/0x7c
Jun  1 16:16:58 StingerG kernel:  [<ffffffff8043a2b8>] ? rtnetlink_rcv+0x18/0x1e
Jun  1 16:16:58 StingerG kernel:  [<ffffffff804490ac>] ? netlink_unicast+0x1fd/0x270
Jun  1 16:16:58 StingerG kernel:  [<ffffffff8042a3a1>] ? __alloc_skb+0x7f/0x12a
Jun  1 16:16:58 StingerG kernel:  [<ffffffff8044982b>] ? netlink_sendmsg+0x285/0x298
Jun  1 16:16:58 StingerG kernel:  [<ffffffff804490ca>] ? netlink_unicast+0x21b/0x270
Jun  1 16:16:58 StingerG kernel:  [<ffffffff80423f37>] ? sock_sendmsg+0xe2/0xff
Jun  1 16:16:58 StingerG kernel:  [<ffffffff8024ac1a>] ? autoremove_wake_function+0x0/0x2e
Jun  1 16:16:58 StingerG kernel:  [<ffffffff80424920>] ? move_addr_to_kernel+0x2b/0x48
Jun  1 16:16:58 StingerG kernel:  [<ffffffff8042416b>] ? sys_sendmsg+0x217/0x28a
Jun  1 16:16:58 StingerG kernel:  [<ffffffff802a53b6>] ? mem_cgroup_charge_common+0x61/0x72
Jun  1 16:16:58 StingerG kernel:  [<ffffffff80294127>] ? page_add_new_anon_rmap+0x28/0x48
Jun  1 16:16:58 StingerG kernel:  [<ffffffff8028c889>] ? handle_mm_fault+0x2e6/0x760
Jun  1 16:16:58 StingerG kernel:  [<ffffffff804250ca>] ? sys_getsockname+0x7a/0xaa
Jun  1 16:16:58 StingerG kernel:  [<ffffffff8026a150>] ? audit_syscall_entry+0x151/0x17c
Jun  1 16:16:58 StingerG kernel:  [<ffffffff8020bedb>] ? system_call_fastpath+0x16/0x1bJun  1 16:16:58 StingerG kernel: Code: 49 8d 7c 24 5c e8 16 c5 06 00 44 3b 2b b8 fe ff ff ff 0f 85 04 01 00 00 49 8b 56 10 49 c7 c0 90 02 51 80 be 03 00 00 00 48 89 e7 <0f> b7 0a 48 83 c2 04 83 e9 04 e8 ef 34 00 00 85 c0 0f 88 da 00
Jun  1 16:16:58 StingerG kernel: RIP  [<ffffffff8044753b>] cls_cgroup_change+0xf7/0x1f5
Jun  1 16:16:58 StingerG kernel:  RSP <ffff88021259d9b8>Jun  1 16:16:58 StingerG kernel: CR2: 0000000000000000
Jun  1 16:16:58 StingerG kernel: ---[ end trace 19d03b97ffa7b3dc ]---

----------------------------------------------------------------------------------------------------
crash> dis -l ffffffff8044753b
include/net/netlink.h: 747
0xffffffff8044753b <cls_cgroup_change+0xf7>:    movzwl (%rdx),%ecx

    734 /**
    735  * nla_parse_nested - parse nested attributes
    736  * @tb: destination array with maxtype+1 elements
    737  * @maxtype: maximum attribute type to be expected
    738  * @nla: attribute containing the nested attributes
    739  * @policy: validation policy
    740  *
    741  * See nla_parse()
    742  */
    743 static inline int nla_parse_nested(struct nlattr *tb[], int maxtype,
    744                                    const struct nlattr *nla,
    745                                    const struct nla_policy *policy)
    746 {
    747         return nla_parse(tb, maxtype, nla_data(nla), nla_len(nla), policy);
    748 }
----------------------------------------------------------------------------------------------------


> 
> System Environment:
>   kernel: 
>     * 2.6.29.1 on x86_64
>     * 2.6.29.3 on x86_64
>     * 2.6.30-rc6 on x86_64 
>        (panic occurred same sequence but I couldn't confirm if it was
>         same problem. 
>         Because crash couldn't analyze kdump of 2.6.30-rc6. 
>         This is just the crash utility(analysis tool) problem. X-<) 
> 
>   tc: 
>     * iproute2-2.6.29-1
>       (download from http://devresources.linux-foundation.org/dev/iproute2/download/)
> 
> How to reproduce:
>   1. mount net_cls subsystem
> 
>       # mkdir /cgroup
>       # mount -t cgroup -onet_cls none /cgroup
> 
>   2. set qdisc, class by tc
> 
>      # tc qdisc add dev bond0 root handle 1: htb default 30
> 
>      # tc class add dev bond0 parent 1:1 classid 1:10 htb rate 10mbit
>      # tc class add dev bond0 parent 1:1 classid 1:20 htb rate 20mbit
>      # tc class add dev bond0 parent 1:1 classid 1:30 htb rate 30mbit
> 
>   3. set net_cls.classid (classify to classid 1:10)
> 
>      # echo 0x1000a > /cgroup/net_cls.classid
> 
>   4. set filter in order to use net_cls
> 
>      # tc filter add dev bond0 protocol ip parent 1: prio 1 cgroup
>        -> panic occured!
> 
> Step 3 and 4, I referred to the following mails, because I couldn't find any other useful documentation.
>   http://kerneltrap.org/mailarchive/linux-netdev/2008/10/14/3653914/thread

-- 
Minoru Usui <usui@mxm.nes.nec.co.jp>
