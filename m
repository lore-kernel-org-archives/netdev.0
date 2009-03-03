From: Chuck Ebbert <cebbert@redhat.com>
Subject: Bluetooth oops from hci_conn_del, kernel 2.6.29-rc6
Date: Tue, 3 Mar 2009 17:43:31 -0500
Message-ID: <20090303174331.0c386a68@dhcp-100-2-144.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42495 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752003AbZCCWnm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 17:43:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From https://bugzilla.redhat.com/show_bug.cgi?id=488115

general protection fault: 0000 [#1] SMP 
last sysfs file: /sys/devices/pci0000:00/0000:00:1d.3/usb9/9-1/9-1:1.0/bluetooth/hci0/hci0:12/type
CPU 1 
Modules linked in: netconsole configfs rfcomm btusb ipt_MASQUERADE iptable_nat nf_nat bridge stp llc bnep sco l2cap bluetooth autofs4 nf_conntrack_netbios_ns nf_conntrack_ftp ip6t_REJECT ip6t_ipv6header nf_conntrack_ipv6 ip6table_filter ip6_tables ipv6 p4_clockmod speedstep_lib freq_table xfs exportfs ext2 uinput dcdbas iTCO_wdt i2c_i801 firewire_ohci iTCO_vendor_support pcspkr i2c_core i3000_edac serio_raw firewire_core edac_core tg3 crc_itu_t ata_generic pata_acpi [last unloaded: netconsole]
Pid: 0, comm: swapper Tainted: G        W  2.6.29-0.148.rc6.fc11.x86_64 #1 PowerEdge SC430              
RIP: 0010:[<ffffffff812f1be0>]  [<ffffffff812f1be0>] skb_dequeue+0x38/0x70
RSP: 0018:ffff88003eaa3d60  EFLAGS: 00010006
RAX: 0000000000000282 RBX: ffff88003d413aa0 RCX: ffff88003ea94e28
RDX: ffffffff81395bc8 RSI: ffff88003d413ab8 RDI: 0000000000000046
RBP: ffff88003eaa3d80 R08: ffff88003eaa3c90 R09: 0000000000000001
R10: ffff8800391461c0 R11: ffff8800386e17c8 R12: 6b6b6b6b6b6b6b6b
R13: ffff88003d413a88 R14: ffff8800391461c0 R15: 0000000000000016
FS:  0000000000000000(0000) GS:ffff88003ea7e708(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00000030366a3120 CR3: 0000000039cc9000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffff88003ea9c000, task ffff88003ea946a0)
Stack:
 ffff88003eaa3d70 ffff88003d413a88 ffff88003d4139f8 ffff880039146420
 ffff88003eaa3da0 ffffffff812f25dd ffff88003d4139f8 ffff8800391461b0
 ffff88003eaa3dd0 ffffffffa01c24e7 ffff88003eaa3dd0 ffff8800391461b0
Call Trace:
 <IRQ> <0> [<ffffffff812f25dd>] skb_queue_purge+0x23/0x2d
 [<ffffffffa01c24e7>] hci_conn_del+0xde/0xe9 [bluetooth]
 [<ffffffffa01c47ec>] hci_event_packet+0x1b61/0x1d0d [bluetooth]
 [<ffffffff81395794>] ? _read_unlock+0x2b/0x2f
 [<ffffffffa01c5624>] ? hci_send_to_sock+0x139/0x149 [bluetooth]
 [<ffffffffa01c10e8>] hci_rx_task+0xa3/0x258 [bluetooth]
 [<ffffffff81050acf>] ? tasklet_action+0x50/0xf8
 [<ffffffff81050b0d>] tasklet_action+0x8e/0xf8
 [<ffffffff810512be>] __do_softirq+0x94/0x176
 [<ffffffff810127ac>] call_softirq+0x1c/0x30
 [<ffffffff8101393e>] do_softirq+0x52/0xb9
 [<ffffffff81050ee1>] irq_exit+0x53/0x90
 [<ffffffff81013c57>] do_IRQ+0x12c/0x151
 [<ffffffff81011e93>] ret_from_intr+0x0/0x2e
 <EOI> <0> [<ffffffff8106eaf0>] ? trace_hardirqs_off+0xd/0xf
 [<ffffffff81017ca5>] ? mwait_idle+0x99/0xcb
 [<ffffffff8106fac7>] ? trace_hardirqs_on+0xd/0xf
 [<ffffffff81017cae>] ? mwait_idle+0xa2/0xcb
 [<ffffffff81017ca5>] ? mwait_idle+0x99/0xcb
 [<ffffffff81398c7b>] ? atomic_notifier_call_chain+0xf/0x11
 [<ffffffff8101025d>] ? enter_idle+0x27/0x29
 [<ffffffff810102c7>] ? cpu_idle+0x68/0xb3
 [<ffffffff8138f1c0>] ? start_secondary+0x199/0x19e
Code: 0f 1f 44 00 00 48 8d 5f 18 49 89 fd 48 89 df e8 82 3f 0a 00 4d 8b 65 00 4d 39 ec 75 05 45 31 e4 eb 2a 4d 85 e4 74 25 41 ff 4d 10 <49> 8b 0c 24 49 8b 54 24 08 49 c7 04 24 00 00 00 00 49 c7 44 24 
RIP  [<ffffffff812f1be0>] skb_dequeue+0x38/0x70
 RSP <ffff88003eaa3d60>


net/core/skbuff.c:skb_dequeue():1793:
        result = __skb_dequeue(list);

static inline struct sk_buff *__skb_dequeue(struct sk_buff_head *list)
{
        struct sk_buff *skb = skb_peek(list);
        if (skb)
                __skb_unlink(skb, list);  <=== oopses trying to deref skb
        return skb;
}

skb_peek() returned skb == 0x6b6b6b6b6b6b6b6b:

static inline struct sk_buff *skb_peek(struct sk_buff_head *list_)
{
        struct sk_buff *list = ((struct sk_buff *)list_)->next;
        if (list == (struct sk_buff *)list_)
                list = NULL;
        return list;
}
