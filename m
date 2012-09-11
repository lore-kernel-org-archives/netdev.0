From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Oops with latest (netfilter) nf-next tree, when unloading
 iptable_nat
Date: Tue, 11 Sep 2012 11:51:21 +0200
Message-ID: <1347357081.3928.32.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>,
	yongjun_wei@trendmicro.com.cn
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pablo,

I'm hitting this general protection fault, when unloading iptables_nat.

Git tree: git://1984.lsi.us.es/nf-next
At commit 0edd94887d19 (ipvs: use list_del_init instead of list_del/INIT_LIST_HEAD)

Notice, I'm not seeing this with net-next (at commit 9f00d9776bc5b)

[  524.590171] general protection fault: 0000 [#1] SMP 
[  524.591067] Modules linked in: netconsole ip_vs_lblc ip_vs_lc ip_vs_rr ip_vs libcrc32c ipt_MASQUERADE nf_nat_ipv4(-) nf_nat iptable_mangle xt_mark ip6table_mangle xt_LOG ip6table_filter ip6_tables virtio_balloon virtio_net [last unloaded: iptable_nat]
[  524.591067] CPU 0 
[  524.591067] Pid: 5842, comm: modprobe Not tainted 3.6.0-rc3-pablo-nf-next+ #1 Red Hat KVM
[  524.591067] RIP: 0010:[<ffffffffa002c2fd>]  [<ffffffffa002c2fd>] nf_nat_proto_clean+0x6d/0xc0 [nf_nat]
[  524.591067] RSP: 0018:ffff880073203e18  EFLAGS: 00010246
[  524.591067] RAX: 0000000000000000 RBX: ffff880077dff2c8 RCX: ffff8800797fab70
[  524.591067] RDX: dead000000200200 RSI: ffff880073203e88 RDI: ffffffffa002f208
[  524.591067] RBP: ffff880073203e28 R08: ffff880073202000 R09: 0000000000000000
[  524.591067] R10: dead000000200200 R11: dead000000100100 R12: ffffffff81c6dc00
 list corruption?   ^^^^^^^^^^^^^^^^      ^^^^^^^^^^^^^^^^ 
[  524.591067] R13: ffff880078671640 R14: ffff880078671638 R15: ffff880073203e88
[  524.591067] FS:  00007f04dc38b700(0000) GS:ffff88007cc00000(0000) knlGS:0000000000000000
[  524.591067] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  524.591067] CR2: 00007f04dc398000 CR3: 0000000072238000 CR4: 00000000000006f0
[  524.591067] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  524.591067] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  524.591067] Process modprobe (pid: 5842, threadinfo ffff880073202000, task ffff8800797fab70)
[  524.591067] Stack:
[  524.591067]  ffff880073203e68 ffffffffa002c290 ffff880073203e78 ffffffff815614e3
[  524.591067]  ffffffff00000000 0000258d00000246 ffff880073203e68 ffffffff81c6dc00
[  524.591067]  ffff880073203e88 ffffffffa00358a0 0000000000000000 000000000040f5b0
[  524.591067] Call Trace:
[  524.591067]  [<ffffffffa002c290>] ? nf_nat_net_exit+0x50/0x50 [nf_nat]
[  524.591067]  [<ffffffff815614e3>] nf_ct_iterate_cleanup+0xc3/0x170
[  524.591067]  [<ffffffffa002c54a>] nf_nat_l3proto_unregister+0x8a/0x100 [nf_nat]
[  524.591067]  [<ffffffff812a0303>] ? compat_prepare_timeout+0x13/0xb0
[  524.591067]  [<ffffffffa0035848>] nf_nat_l3proto_ipv4_exit+0x10/0x23 [nf_nat_ipv4]
[  524.591067]  [<ffffffff8109f4a5>] sys_delete_module+0x235/0x2b0
[  524.591067]  [<ffffffff810b8193>] ? __audit_syscall_entry+0x1b3/0x1f0
[  524.591067]  [<ffffffff810b8776>] ? __audit_syscall_exit+0x3e6/0x410
[  524.591067]  [<ffffffff816679e2>] system_call_fastpath+0x16/0x1b
[  524.591067] Code: 75 6c 0f b6 46 01 84 c0 74 05 3a 42 3e 75 5f 80 7e 02 00 74 41 48 c7 c7 08 f2 02 a0 e8 3d 3b 63 e1 48 8b 03 48 8b 53 08 48 85 c0 <48> 89 02 74 04 48 89 50 08 48 be 00 02 20 00 00 00 ad de 48 c7 
[  524.591067] RIP  [<ffffffffa002c2fd>] nf_nat_proto_clean+0x6d/0xc0 [nf_nat]
[  524.591067]  RSP <ffff880073203e18>


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer


