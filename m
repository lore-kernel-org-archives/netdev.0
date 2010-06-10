From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/8] netpoll/bridge fixes
Date: Thu, 10 Jun 2010 22:40:47 +1000
Message-ID: <20100610124047.GA16658@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="VS++wcV0S1rZb1Fb"
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Qianfeng Zhang <frzhang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	WANG Cong <amwang@redhat.com>,
	Stephen He
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:33997 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754207Ab0FJMkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jun 2010 08:40:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

Qianfeng Zhang reported that he was seeing crashes with the
attached backtrace.

I tracked this down to the recently added netpoll support in
the bridge device.  It's a classic use-after-free problem.

Trying to solve it brought out a host of other issues, some of
which existed prior to the new bridge code.  The following patches
attempt to address some of these issues.

Warning, this is completely untested (apart from compiling with
everything enabled) so please look but don't merge :)

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg.txt"

BUG: unable to handle kernel NULL pointer dereference at 0000000000000400
IP: [<ffffffffa0456824>] __br_deliver+0x64/0xe0 [bridge]
PGD 31e038067 PUD 31e5d6067 PMD 0 
Oops: 0000 [#1] SMP 
last sysfs file: /sys/kernel/mm/ksm/run
CPU 3 
Modules linked in: vhost_net(U) macvtap(U) macvlan(U) tun(U) ip6table_filter(U) ip6_tables(U) ebtable_nat(U) ebtables(U) ipt_MASQUERADE(U) iptable_nat(U) nf_nat(U) nfsd(U) exportfs(U) nfs(U) lockd(U) fscache(U) nfs_acl(U) auth_rpcgss(U) sunrpc(U) cpufreq_ondemand(U) acpi_cpufreq(U) freq_table(U)
bridge(U) stp(U) llc(U) ipv6(U) dm_mirror(U) dm_region_hash(U) dm_log(U) kvm_intel(U) kvm(U) snd_hda_codec_realtek(U) snd_hda_intel(U) snd_hda_codec(U) snd_hwdep(U) snd_seq(U) snd_seq_device(U) snd_pcm(U) igb(U) i7core_edac(U) edac_core(U) iTCO_wdt(U) dca(U) snd_timer(U) snd(U) soundcore(U)
snd_page_alloc(U) iTCO_vendor_support(U) sr_mod(U) tg3(U) sg(U) cdrom(U) serio_raw(U) wmi(U) ext4(U) mbcache(U) jbd2(U) sd_mod(U) mptsas(U) crc_t10dif(U) mptscsih(U) mptbase(U) scsi_transport_sas(U) firewire_ohci(U) firewire_core(U) crc_itu_t(U) ahci(U) nouveau(U) ttm(U) drm_kms_helper(U) drm(U)
i2c_algo_bit(U) i2c_core(U) dm_mod(U) [last unloaded: microcode]

Modules linked in: vhost_net(U) macvtap(U) macvlan(U) tun(U) ip6table_filter(U) ip6_tables(U) ebtable_nat(U) ebtables(U) ipt_MASQUERADE(U) iptable_nat(U) nf_nat(U) nfsd(U) exportfs(U) nfs(U) lockd(U) fscache(U) nfs_acl(U) auth_rpcgss(U) sunrpc(U) cpufreq_ondemand(U) acpi_cpufreq(U) freq_table(U)
bridge(U) stp(U) llc(U) ipv6(U) dm_mirror(U) dm_region_hash(U) dm_log(U) kvm_intel(U) kvm(U) snd_hda_codec_realtek(U) snd_hda_intel(U) snd_hda_codec(U) snd_hwdep(U) snd_seq(U) snd_seq_device(U) snd_pcm(U) igb(U) i7core_edac(U) edac_core(U) iTCO_wdt(U) dca(U) snd_timer(U) snd(U) soundcore(U)
snd_page_alloc(U) iTCO_vendor_support(U) sr_mod(U) tg3(U) sg(U) cdrom(U) serio_raw(U) wmi(U) ext4(U) mbcache(U) jbd2(U) sd_mod(U) mptsas(U) crc_t10dif(U) mptscsih(U) mptbase(U) scsi_transport_sas(U) firewire_ohci(U) firewire_core(U) crc_itu_t(U) ahci(U) nouveau(U) ttm(U) drm_kms_helper(U) drm(U)
i2c_algo_bit(U) i2c_core(U) dm_mod(U) [last unloaded: microcode]
Pid: 2234, comm: netserver Tainted: G        W  2.6.32-31.el6.x86_64 #1 HP Z800 Workstation
RIP: 0010:[<ffffffffa0456824>]  [<ffffffffa0456824>] __br_deliver+0x64/0xe0 [bridge]
RSP: 0018:ffff880320ab7698  EFLAGS: 00010292
RAX: 0000000000000000 RBX: ffff88032035a6c0 RCX: ffff880320056140
RDX: 000000000000a971 RSI: 0000000000000282 RDI: ffff88031af1769c
RBP: ffff880320ab76b8 R08: ffff88031af1769c R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000000 R12: ffff88031d17aa80
R13: ffff88031d17aab8 R14: ffff88031af7e8ce R15: ffff88032035a000
FS:  00007ff18f067700(0000) GS:ffff880028260000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000400 CR3: 000000031f101000 CR4: 00000000000026e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process netserver (pid: 2234, threadinfo ffff880320ab6000, task ffff88031af62a60)
Stack:
 0000000380000000 ffff88032056f300 ffff88031d17aa80 ffff88032035a6c0
<0> ffff880320ab76c8 ffffffffa04568d5 ffff880320ab76f8 ffffffffa04555ac
<0> ffffffff818bbde0 0000000000000003 ffffffff818bbe20 ffff88031d17aa80
Call Trace:
 [<ffffffffa04568d5>] br_deliver+0x35/0x40 [bridge]
 [<ffffffffa04555ac>] br_dev_xmit+0xbc/0x100 [bridge]
 [<ffffffff8140f708>] dev_hard_start_xmit+0x2b8/0x370
 [<ffffffff81412c3e>] dev_queue_xmit+0x3be/0x4a0
 [<ffffffff81417545>] neigh_resolve_output+0x105/0x370
 [<ffffffff8144e9f0>] ? ip_finish_output+0x0/0x310
 [<ffffffff8144eb2c>] ip_finish_output+0x13c/0x310
 [<ffffffff8144edb8>] ip_output+0xb8/0xc0
 [<ffffffff8144dd0f>] ? __ip_local_out+0x9f/0xb0
 [<ffffffff8144dd45>] ip_local_out+0x25/0x30
 [<ffffffff8144e590>] ip_queue_xmit+0x190/0x420
 [<ffffffff814630e1>] tcp_transmit_skb+0x3f1/0x790
 [<ffffffff814649f9>] tcp_send_ack+0xd9/0x120
 [<ffffffff8145c31e>] __tcp_ack_snd_check+0x5e/0xa0
 [<ffffffff81461401>] tcp_rcv_established+0x271/0x820
 [<ffffffff814694b3>] tcp_v4_do_rcv+0x2e3/0x430
 [<ffffffff814694b3>] ? tcp_v4_do_rcv+0x2e3/0x430
 [<ffffffff814003ad>] release_sock+0x5d/0xc0
 [<ffffffff81458744>] tcp_recvmsg+0x864/0xe80
 [<ffffffff81013c8e>] ? apic_timer_interrupt+0xe/0x20
 [<ffffffff813ffa79>] sock_common_recvmsg+0x39/0x50
 [<ffffffff813fd42e>] ? sock_recvmsg+0x13e/0x160
 [<ffffffff813fd423>] sock_recvmsg+0x133/0x160
 [<ffffffff8110c31e>] ? filemap_fault+0xbe/0x510
 [<ffffffff8108ff80>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8110aa87>] ? unlock_page+0x27/0x30
 [<ffffffff81131869>] ? __do_fault+0x439/0x500
 [<ffffffff81013c8e>] ? apic_timer_interrupt+0xe/0x20
 [<ffffffff814003ff>] ? release_sock+0xaf/0xc0
 [<ffffffff813fd771>] sys_recvfrom+0xe1/0x170
 [<ffffffff8101187e>] ? __switch_to+0x26e/0x320
 [<ffffffff810d267e>] ? audit_syscall_entry+0x2e/0x280
 [<ffffffff810d28a2>] ? audit_syscall_entry+0x252/0x280
 [<ffffffff81013172>] system_call_fastpath+0x16/0x1b
Code: c9 49 c7 c1 30 66 45 a0 4c 89 e2 be 03 00 00 00 bf 07 00 00 00 c7 04 24 00 00 00 80 e8 c6 eb fd e0 83 f8 01 74 31 49 8b 44 24 20 <48> 8b 80 00 04 00 00 48 85 c0 74 0e 48 8b 80 b8 00 00 00 48 8b 
RIP  [<ffffffffa0456824>] __br_deliver+0x64/0xe0 [bridge]
 RSP <ffff880320ab7698>
CR2: 0000000000000400


--VS++wcV0S1rZb1Fb--
