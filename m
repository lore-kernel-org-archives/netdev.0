From: Chuck Ebbert <cebbert@redhat.com>
Subject: Oops in
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c::ipv6_confirm(), kernel
 2.6.30.8
Date: Sat, 17 Oct 2009 05:01:37 -0400
Message-ID: <200910170903.n9H93bKI012269@int-mx03.intmail.prod.int.phx2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

general protection fault: 0000 [#1] SMP 
last sysfs file: /sys/devices/system/cpu/sched_mc_power_savings
CPU 0 
Modules linked in: tun fuse rfcomm sco bridge stp llc bnep l2cap autofs4
w83627ehf hwmon_vid sunrpc sit tunnel4 nf_nat_sip nf_conntrack_sip nf_nat_ftp
nf_conntrack_ftp ipt_LOG xt_owner iptable_mangle ipt_MASQUERADE iptable_nat
nf_nat xt_limit nf_conntrack_ipv6 xt_mac ip6t_LOG ip6table_filter ip6_tables
p4_clockmod freq_table speedstep_lib squashfs nls_utf8 dm_multipath raid1
kvm_intel kvm uinput ipv6 ppdev snd_hda_codec_realtek snd_hda_intel
snd_hda_codec snd_hwdep snd_pcm nouveau pcspkr i2c_i801 firewire_ohci snd_timer
btusb firewire_core e1000 snd bluetooth drm iTCO_wdt iTCO_vendor_support
crc_itu_t i2c_algo_bit asus_atk0110 i82975x_edac soundcore sky2 edac_core
parport_pc i2c_core floppy hwmon snd_page_alloc parport raid456 raid6_pq
async_xor async_memcpy async_tx xor [last unloaded: freq_table]
Pid: 4104, comm: qemu-kvm Not tainted 2.6.30.8-64.fc11.x86_64.debug #1 System
Product Name
RIP: 0010:[<ffffffffa03624e1>]  [<ffffffffa03624e1>] ipv6_confirm+0xd0/0x147
[nf_conntrack_ipv6]
RSP: 0018:ffff880035203668  EFLAGS: 00010212
RAX: 0000000000000030 RBX: ffff8801f90a1080 RCX: 0000000000000002
RDX: ffffffff81783f40 RSI: 0000000000000030 RDI: ffff8801f90a1080
RBP: ffff880035203698 R08: ffffffffa04520ee R09: ffff880035203748
R10: 0000000000000000 R11: 0000000000000000 R12: ffffffff81783f40
R13: 6b6b6b6b6b6b6b6b R14: 0000000000000002 R15: 0000000000000004
FS:  00007f944e44b740(0000) GS:ffff880035200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007fffbc54ef60 CR3: 000000020f8d8000 CR4: 00000000000026e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process qemu-kvm (pid: 4104, threadinfo ffff88020f89c000, task
ffff8802104a4760)
Stack:
 3a00000000000246 00000000696092b1 0000000080000000 ffff8801f90a1080
 ffffffffa04520ee ffffffff81783bd0 ffff880035203708 ffffffff8142b117
 ffff8800352036c8 ffff880035203748 ffff880210492060 0000000000000000
Call Trace:
 <IRQ> <0> [<ffffffffa04520ee>] ? br_nf_dev_queue_xmit+0x0/0xa1 [bridge]
 [<ffffffff8142b117>] nf_iterate+0x5c/0xb3
 [<ffffffffa04520ee>] ? br_nf_dev_queue_xmit+0x0/0xa1 [bridge]
 [<ffffffff8142b214>] nf_hook_slow+0xa6/0x136
 [<ffffffffa04520ee>] ? br_nf_dev_queue_xmit+0x0/0xa1 [bridge]
 [<ffffffffa044c29d>] ? br_dev_queue_push_xmit+0x0/0xae [bridge]
 [<ffffffffa045263b>] nf_hook_thresh.clone.0+0x4c/0x62 [bridge]
 [<ffffffffa0452d92>] br_nf_post_routing+0x1a8/0x1e4 [bridge]
 [<ffffffff8142b117>] nf_iterate+0x5c/0xb3
 [<ffffffffa044c29d>] ? br_dev_queue_push_xmit+0x0/0xae [bridge]
 [<ffffffff8142b214>] nf_hook_slow+0xa6/0x136
 [<ffffffffa044c29d>] ? br_dev_queue_push_xmit+0x0/0xae [bridge]
 [<ffffffffa044c39d>] nf_hook_thresh.clone.0+0x52/0x68 [bridge]
 [<ffffffffa044c3ed>] br_forward_finish+0x3a/0x62 [bridge]
 [<ffffffffa0452aaa>] br_nf_forward_finish+0xb3/0xd2 [bridge]
 [<ffffffffa045263b>] ? nf_hook_thresh.clone.0+0x4c/0x62 [bridge]
 [<ffffffffa045318a>] br_nf_forward_ip+0x1af/0x1de [bridge]
 [<ffffffffa044c3b3>] ? br_forward_finish+0x0/0x62 [bridge]
 [<ffffffff8142b117>] nf_iterate+0x5c/0xb3
 [<ffffffffa044c3b3>] ? br_forward_finish+0x0/0x62 [bridge]
 [<ffffffff8142b214>] nf_hook_slow+0xa6/0x136
 [<ffffffffa044c3b3>] ? br_forward_finish+0x0/0x62 [bridge]
 [<ffffffffa044c415>] ? __br_forward+0x0/0xab [bridge]
 [<ffffffffa044c39d>] nf_hook_thresh.clone.0+0x52/0x68 [bridge]
 [<ffffffffa044c499>] __br_forward+0x84/0xab [bridge]
 [<ffffffffa044c1ca>] br_flood+0x82/0xd9 [bridge]
 [<ffffffff814086ee>] ? netif_receive_skb+0x120/0x44c
 [<ffffffffa044c249>] br_flood_forward+0x28/0x3e [bridge]
 [<ffffffffa044d36a>] br_handle_frame_finish+0x13a/0x167 [bridge]
 [<ffffffffa04529da>] br_nf_pre_routing_finish_ipv6+0xb7/0xd4 [bridge]
 [<ffffffffa045263b>] ? nf_hook_thresh.clone.0+0x4c/0x62 [bridge]
 [<ffffffffa04534e8>] br_nf_pre_routing+0x32f/0x577 [bridge]
 [<ffffffffa044d230>] ? br_handle_frame_finish+0x0/0x167 [bridge]
 [<ffffffff8142b117>] nf_iterate+0x5c/0xb3
 [<ffffffff8123bbf6>] ? kobject_put+0x54/0x6f
 [<ffffffffa044d230>] ? br_handle_frame_finish+0x0/0x167 [bridge]
 [<ffffffff8142b214>] nf_hook_slow+0xa6/0x136
 [<ffffffffa044d230>] ? br_handle_frame_finish+0x0/0x167 [bridge]
 [<ffffffffa044d21a>] nf_hook_thresh.clone.0+0x52/0x68 [bridge]
 [<ffffffffa044d533>] br_handle_frame+0x19c/0x1d9 [bridge]
 [<ffffffff814088fa>] netif_receive_skb+0x32c/0x44c
 [<ffffffff814086ee>] ? netif_receive_skb+0x120/0x44c
 [<ffffffff81087465>] ? trace_hardirqs_on_caller+0x32/0x173
 [<ffffffff81408ac5>] process_backlog+0xab/0xfb
 [<ffffffff81060805>] ? _local_bh_enable+0xad/0xd6
 [<ffffffff81409348>] net_rx_action+0xc6/0x226
 [<ffffffff8140944c>] ? net_rx_action+0x1ca/0x226
 [<ffffffff81060900>] __do_softirq+0xd2/0x1d2
 [<ffffffff8101328c>] call_softirq+0x1c/0x30
 <EOI> <0> [<ffffffff81014bf3>] do_softirq+0x5f/0xd7
 [<ffffffff814094dd>] netif_rx_ni+0x35/0x4e
 [<ffffffffa049a0b3>] tun_chr_aio_write+0x384/0x3f3 [tun]
 [<ffffffffa0499d2f>] ? tun_chr_aio_write+0x0/0x3f3 [tun]
 [<ffffffff81124aba>] do_sync_readv_writev+0xf7/0x14a
 [<ffffffff81088f33>] ? print_lock_contention_bug+0x2a/0x106
 [<ffffffff810745bf>] ? autoremove_wake_function+0x0/0x5f
 [<ffffffff811f488c>] ? security_file_permission+0x29/0x3f
 [<ffffffff81125b15>] do_readv_writev+0xbf/0x156
 [<ffffffff8112630b>] ? fget_light+0x66/0x113
 [<ffffffff8124036a>] ? __up_read+0x89/0xaa
 [<ffffffff81125c02>] vfs_writev+0x56/0x75
 [<ffffffff81125d38>] sys_writev+0x59/0xb6
 [<ffffffff81012002>] system_call_fastpath+0x16/0x1b
Code: 2c 75 1d f6 05 1a fc 1c e2 40 74 60 f6 05 17 fc 1c e2 04 74 57 80 3d ad
4d 00 00 00 74 4e eb 62 44 89 f1 4c 89 e2 89 c6 48 89 df <41> ff 55 50 83 f8 01
75 3d 4c 8b a3 88 00 00 00 4d 85 e4 74 2c 
RIP  [<ffffffffa03624e1>] ipv6_confirm+0xd0/0x147 [nf_conntrack_ipv6]
 RSP <ffff880035203668>
---[ end trace 5dc400d9f2f8290b ]---

   c: f6 05 17 fc 1c e2 04  testb  $0x4,-0x1de303e9(%rip)
  13: 74 57                 je     0x6c
  15: 80 3d ad 4d 00 00 00  cmpb   $0x0,0x4dad(%rip)
  1c: 74 4e                 je     0x6c
  1e: eb 62                 jmp    0x82
  20: 44 89 f1              mov    %r14d,%ecx
  23: 4c 89 e2              mov    %r12,%rdx
  26: 89 c6                 mov    %eax,%esi
  28: 48 89 df              mov    %rbx,%rdi

   0: 41 ff 55 50           callq  *0x50(%r13)  <===========
   4: 83 f8 01              cmp    $0x1,%eax
   7: 75 3d                 jne    0x46
   9: 4c 8b a3 88 00 00 00  mov    0x88(%rbx),%r12
  10: 4d 85 e4              test   %r12,%r12
  13: 74 2c                 je     0x41

R13: 6b6b6b6b6b6b6b6b  

Corresponds to:
net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c:178:

        ret = helper->help(skb, protoff, ct, ctinfo);  
