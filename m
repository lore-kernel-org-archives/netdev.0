From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Oops with latest (netfilter) nf-next tree, when unloading
 iptable_nat
Date: Fri, 21 Sep 2012 11:47:22 +0200
Message-ID: <1348220842.3103.17.camel@localhost>
References: <1347357081.3928.32.camel@localhost>
	 <20120912213627.GJ14750@breakpoint.cc> <20120914120750.GA5764@1984>
	 <Pine.GSO.4.63.1209141511020.11622@stinky-local.trash.net>
	 <1348058791.2761.94.camel@localhost>
	 <Pine.GSO.4.63.1209200855500.8409@stinky-local.trash.net>
	 <20120920100859.GB20828@1984>
	 <Pine.GSO.4.63.1209201212480.1775@stinky-local.trash.net>
	 <Pine.GSO.4.63.1209201859140.14078@stinky-local.trash.net>
	 <20120921010025.GA20479@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, Florian Westphal <fw@strlen.de>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120921010025.GA20479@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-09-21 at 03:00 +0200, Pablo Neira Ayuso wrote:
> On Thu, Sep 20, 2012 at 07:06:52PM +0200, Patrick McHardy wrote:
> > On Thu, 20 Sep 2012, Patrick McHardy wrote:
[cut]
(discussion of fixes by Patrick and Florian)
(...settling on Patricks second patch)

> Makes sense. And we can revisit this to improve it later.
> 
> I'll take this patch. I'll send a batch with updates for the nf-nat
> thin asap.

What git tree is that?

I'm trying to work off Pablo's nf-next tree (for my IPVS changes):
  git://1984.lsi.us.es/nf-next

But I don't see the patch in that tree ...yet.


Notice, the bug is also present in DaveM's net-next tree.
(I know I stated earlier that it didn't affect net-next, but I just
forgot to select the new netfilter .config options for nat)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer


Oops output, for the sake of completeness:
------------------------------------------
[  866.878092] general protection fault: 0000 [#1] SMP 
[  866.878986] Modules linked in: netconsole ip_vs_lblc ip_vs_lc ip_vs_rr ip_vs libcrc32c ipt_MASQUERADE nf_nat_ipv4(-) nf_nat iptable_mangle xt_mark ip6table_mangle xt_LOG ip6table_filter ip6_tables virtio_net virtio_balloon [last unloaded: iptable_nat]
[  866.879045] CPU 0 
[  866.879045] Pid: 4053, comm: modprobe Not tainted 3.6.0-rc5-net-next-sysctl-tcp+ #13 Red Hat KVM
[  866.879045] RIP: 0010:[<ffffffffa002c2dd>]  [<ffffffffa002c2dd>] nf_nat_proto_clean+0x6d/0xc0 [nf_nat]
[  866.879045] RSP: 0018:ffff880078a41e18  EFLAGS: 00010246
[  866.879045] RAX: 0000000000000000 RBX: ffff880079142500 RCX: dead000000200200
[  866.879045] RDX: dead000000200200 RSI: ffff880078a41e88 RDI: ffffffffa002f268
[  866.879045] RBP: ffff880078a41e28 R08: ffff880078a40000 R09: 0000000000000002
[  866.879045] R10: 0000000000000000 R11: 0000000000000246 R12: ffffffff81c6db40
[  866.879045] R13: ffff880037d8f008 R14: ffff880037d8f000 R15: ffff880078a41e88
[  866.879045] FS:  00007fc30c11a700(0000) GS:ffff88007cc00000(0000) knlGS:0000000000000000
[  866.879045] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  866.879045] CR2: 00007fc30c127000 CR3: 00000000780ef000 CR4: 00000000000006f0
[  866.879045] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  866.879045] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  866.879045] Process modprobe (pid: 4053, threadinfo ffff880078a40000, task ffff88007a379650)
[  866.879045] Stack:
[  866.879045]  ffff880078a41e68 ffffffffa002c270 ffff880078a41e78 ffffffff81541413
[  866.879045]  ffffffff00000000 0000147578a40303 ffff880078a41e68 ffffffff81c6db40
[  866.879045]  ffff880078a41e88 ffffffffa00358a0 0000000000000000 000000000040f5b0
[  866.879045] Call Trace:
[  866.879045]  [<ffffffffa002c270>] ? nf_nat_net_exit+0x50/0x50 [nf_nat]
[  866.879045]  [<ffffffff81541413>] nf_ct_iterate_cleanup+0xc3/0x170
[  866.879045]  [<ffffffffa002c50a>] nf_nat_l3proto_unregister+0x8a/0x100 [nf_nat]
[  866.879045]  [<ffffffff81290303>] ? proc_keys_next+0x23/0x60
[  866.879045]  [<ffffffffa0035848>] nf_nat_l3proto_ipv4_exit+0x10/0x23 [nf_nat_ipv4]
[  866.879045]  [<ffffffff810988b5>] sys_delete_module+0x235/0x2b0
[  866.879045]  [<ffffffff810b38c3>] ? __audit_syscall_entry+0x1b3/0x1f0
[  866.879045]  [<ffffffff810b36e6>] ? __audit_syscall_exit+0x3e6/0x410
[  866.879045]  [<ffffffff81640122>] system_call_fastpath+0x16/0x1b
[  866.879045] Code: 75 6c 0f b6 46 01 84 c0 74 05 3a 42 3e 75 5f 80 7e 02 00 74 41 48 c7 c7 68 f2 02 a0 e8 1d c5 60 e1 48 8b 03 48 8b 53 08 48 85 c0 <48> 89 02 74 04 48 89 50 08 48 be 00 02 20 00 00 00 ad de 48 c7 
[  866.879045] RIP  [<ffffffffa002c2dd>] nf_nat_proto_clean+0x6d/0xc0 [nf_nat]
[  866.879045]  RSP <ffff880078a41e18>


