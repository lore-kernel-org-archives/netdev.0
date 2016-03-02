From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: skb_under_panic in ip_tunnel_xmit
Date: Wed, 02 Mar 2016 10:14:49 -0800
Message-ID: <1456942489.648.113.camel@edumazet-ThinkPad-T530>
References: <20160302171159.8A27C384B80@fruggeri-Arora18.sjc.aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, frugger@arista.com
To: Francesco Ruggeri <fruggeri@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35790 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793AbcCBSOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 13:14:52 -0500
Received: by mail-pa0-f51.google.com with SMTP id bj10so68028661pad.2
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 10:14:51 -0800 (PST)
In-Reply-To: <20160302171159.8A27C384B80@fruggeri-Arora18.sjc.aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On mer., 2016-03-02 at 09:11 -0800, Francesco Ruggeri wrote:
> I can consistently get this  panic on 4.4.1 as well as 3.18.
> 
> [ 2076.264975] gre: GRE over IPv4 demultiplexor driver
> [ 2076.269326] ip_gre: GRE over IPv4 tunneling driver
> [ 2076.274464] conntrack: generic helper won't handle protocol 47. Please consider loading the specific helper module.
> [ 2088.868553] skbuff: skb_under_panic: text:ffffffff814c03f2 len:108 put:20 head:ffff8800a5f6c400 data:ffff8800a5f6c3f8 tail:0x64 end:0xc0 dev:t3
> [ 2088.869755] ------------[ cut here ]------------
> [ 2088.870179] kernel BUG at net/core/skbuff.c:102!
> [ 2088.870599] invalid opcode: 0000 [#1] SMP 
> [ 2088.871024] Modules linked in: ip_gre ip_tunnel gre dummy iptable_filter rfcomm bnep macvlan snd_seq_midi snd_seq_midi_event btusb btrtl btbcm btintel sg bluetooth joydev snd_ens1371 snd_ac97_codec ac97_bus coretemp hwmon snd_seq snd_pcm snd_timer snd_rawmidi snd_seq_device snd ppdev soundcore ip6table_filter ip6_tables bonding gameport serio_raw pcspkr battery kvm parport_pc nfsd auth_rpcgss oid_registry parport irqbypass ac irda crc_ccitt fuse nfs_acl lockd xt_multiport acpi_cpufreq tpm_tis tpm iptable_nat shpchp grace nf_conntrack_ipv4 nf_defrag_ipv4 i2c_piix4 nf_nat_ipv4 ip_tables nf_nat nf_conntrack x_tables tun 8021q uinput vmwgfx crc32c_intel drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm ehci_pci drm aesni_intel aes_x86_64 glue_helper lrw gf128mul ablk_helper
  cryptd i2c_core
> [ 2088.875474]  sr_mod mptspi mptscsih ehci_hcd mptbase scsi_transport_spi e1000 uhci_hcd cdrom sunrpc dm_mirror dm_region_hash dm_log dm_mod autofs4
> [ 2088.876737] CPU: 1 PID: 6420 Comm: ping Not tainted 4.4.1-2980094.AroraKernelnextfruggeri.2.fc18.x86_64 #1
> [ 2088.878039] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2012
> [ 2088.879521] task: ffff880035ea0000 ti: ffff8800b0ff8000 task.ti: ffff8800b0ff8000
> [ 2088.880285] RIP: 0010:[<ffffffff81522130>]  [<ffffffff81522130>] skb_panic+0x66/0x68
> [ 2088.881214] RSP: 0018:ffff8800b0ffb728  EFLAGS: 00010292
> [ 2088.881945] RAX: 0000000000000083 RBX: ffff8800b51b6c00 RCX: 0000000000000000
> [ 2088.882692] RDX: ffff88013ae2f101 RSI: ffff88013ae2cae8 RDI: ffff88013ae2cae8
> [ 2088.883424] RBP: ffff8800b0ffb748 R08: 0000000000000000 R09: 00000000ffffffff
> [ 2088.884110] R10: 00000000ffffffff R11: ffff88013621f3e0 R12: 0000000000000054
> [ 2088.884846] R13: ffffffff81a9fe40 R14: 0000000000000000 R15: 0000000003030303
> [ 2088.885535] FS:  00007f24b4a24740(0000) GS:ffff88013ae20000(0000) knlGS:0000000000000000
> [ 2088.886270] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 2088.887014] CR2: 00007f9d6fb26000 CR3: 00000000aae66000 CR4: 00000000001406e0
> [ 2088.887817] Stack:
> [ 2088.888582]  ffff8800a5f6c3f8 0000000000000064 00000000000000c0 ffff880138fac000
> [ 2088.889378]  ffff8800b0ffb758 ffffffff8143b640 ffff8800b0ffb7c8 ffffffff814c03f2
> [ 2088.890188]  ffff880000000040 ffffffff00000040 ffff880000000000 000000000000002f
> [ 2088.891011] Call Trace:
> [ 2088.892073]  [<ffffffff8143b640>] skb_push+0x3b/0x3c
> [ 2088.893156]  [<ffffffff814c03f2>] iptunnel_xmit+0xad/0x145
> [ 2088.894033]  [<ffffffffa0563ee3>] ip_tunnel_xmit+0x673/0x790 [ip_tunnel]
> [ 2088.894884]  [<ffffffffa0568645>] __gre_xmit+0x76/0x7f [ip_gre]
> [ 2088.895700]  [<ffffffffa05691fa>] ipgre_xmit+0xd3/0xef [ip_gre]
> [ 2088.896573]  [<ffffffff8144c9e7>] dev_hard_start_xmit+0x226/0x2fc
> [ 2088.897387]  [<ffffffff8144cf0c>] __dev_queue_xmit+0x333/0x425
> [ 2088.898183]  [<ffffffff8144d01e>] dev_queue_xmit+0x10/0x12
> [ 2088.898996]  [<ffffffff81453120>] neigh_direct_output+0x11/0x13
> [ 2088.899793]  [<ffffffff814876a3>] ip_finish_output2+0x233/0x293
> [ 2088.900582]  [<ffffffff81486894>] ? dst_mtu+0xb/0xd
> [ 2088.901283]  [<ffffffff81487849>] ip_finish_output+0x146/0x159
> [ 2088.901990]  [<ffffffff81486b02>] ? ip_generic_getfrag+0x5c/0x98
> [ 2088.902658]  [<ffffffff81488874>] ip_output+0x5f/0x91
> [ 2088.903306]  [<ffffffff81487703>] ? ip_finish_output2+0x293/0x293
> [ 2088.903964]  [<ffffffff81488220>] ? __ip_local_out+0x73/0x7c
> [ 2088.904625]  [<ffffffff81486896>] ? dst_mtu+0xd/0xd
> [ 2088.905222]  [<ffffffff814868a5>] dst_output+0xf/0x11
> [ 2088.905820]  [<ffffffff8148825a>] ip_local_out+0x31/0x3a
> [ 2088.906378]  [<ffffffff81489117>] ip_send_skb+0x1a/0x3f
> [ 2088.906938]  [<ffffffff8148916f>] ip_push_pending_frames+0x33/0x3b
> [ 2088.907465]  [<ffffffff814a7c71>] raw_sendmsg+0x794/0x8ea
> [ 2088.907981]  [<ffffffff8144119c>] ? __skb_recv_datagram+0x201/0x487
> [ 2088.908548]  [<ffffffff81441454>] ? skb_recv_datagram+0x32/0x34
> [ 2088.909050]  [<ffffffff814a7267>] ? raw_recvmsg+0x68/0x159
> [ 2088.909705]  [<ffffffff8113ed4e>] ? rw_copy_check_uvector+0x6e/0x109
> [ 2088.910247]  [<ffffffff814b40ba>] inet_sendmsg+0x3c/0x65
> [ 2088.910775]  [<ffffffff81434c88>] sock_sendmsg_nosec+0x12/0x1d
> [ 2088.911279]  [<ffffffff81434cbc>] sock_sendmsg+0x29/0x2e
> [ 2088.911764]  [<ffffffff81435f2f>] ___sys_sendmsg+0x1a6/0x23f
> [ 2088.912349]  [<ffffffff81331e0a>] ? ldsem_up_read+0x1b/0x30
> [ 2088.912820]  [<ffffffff81330143>] ? tty_ldisc_deref+0x16/0x18
> [ 2088.913299]  [<ffffffff81329cf8>] ? tty_write+0x207/0x222
> [ 2088.913743]  [<ffffffff8132e102>] ? n_tty_receive_buf+0x13/0x13
> [ 2088.914244]  [<ffffffff81154673>] ? __fget_light+0x2c/0x4d
> [ 2088.914671]  [<ffffffff814363f2>] __sys_sendmsg+0x42/0x60
> [ 2088.915126]  [<ffffffff81436422>] SyS_sendmsg+0x12/0x1e
> [ 2088.915534]  [<ffffffff815274ae>] entry_SYSCALL_64_fastpath+0x12/0x71
> [ 2088.915947] Code: 00 00 48 89 44 24 10 8b 87 c8 00 00 00 48 89 44 24 08 48 8b 87 d8 00 00 00 48 c7 c7 29 ba 85 81 48 89 04 24 31 c0 e8 d4 4e bd ff <0f> 0b 0f 1f 44 00 00 55 48 89 e5 41 54 4c 8d a7 a8 01 00 00 53 
> [ 2088.917397] RIP  [<ffffffff81522130>] skb_panic+0x66/0x68
> [ 2088.917914]  RSP <ffff8800b0ffb728>
> 
> I use this script, which creates gre tunnels  t1 and t3, creates a tx
> loop between them, then sends a packet through t3 and t1 before
> dropping it with an iptables rule.
> 
> ip link add dummy1 type dummy
> ip addr add 1.1.1.1/32 dev dummy1
> ip link set dummy1 up
> 
> ip link add dummy3 type dummy
> ip addr add 3.3.3.3/32 dev dummy3
> ip link set dummy3 up
> 
> ip tunnel add t1 mode gre local 1.1.1.1 remote 2.2.2.2
> ip link set t1 up
> 
> ip tunnel add t3 mode gre local 3.3.3.3 remote 4.4.4.4
> ip link set t3 up
> 
> ip route add 2.2.2.2 dev t3
> ip route add 4.4.4.4 dev t1
> 
> iptables -I OUTPUT -p gre -d 2.2.2.2 -j DROP
> 
> ping -f 2.2.2.2
> 
> The root cause of the crash is that with every packet
> t3->needed_headroom and t1->needed_headroom are strictly incremented
> in ip_tunnel_xmit, since each one uses the other's needed_headroom.
> 
> The immediate cause of the crash is that when needed_headroom wraps
> around (in my case I get max_headroom = 65540 and t3->needed_headroom
> = 4, max_headroom is unsigned int and needed_headroom is unsigned
> short) skb_cow_head does not allocate enough headroom in the skb.
> 
> I have not been able to come with a solution except not updating a
> tunnel's needed_headroom, but that would have a performance impact
> (see also http://marc.info/?l=linux-netdev&m=145594279014551&w=2).
> Any suggestions?
> 
> Thanks,
> Francesco Ruggeri
> 
I am not sure we want to support ~64K of headers.

Is this something real, or just another root-exploit
linux-bug-of-the-day trick ? 

When I want to reboot my host I usually type 'reboot', as it looks nicer
to me ;)
