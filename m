From: Patrick McHardy <kaber@trash.net>
Subject: Re: ipv6 fragmentation-related panic in netfilter
Date: Wed, 30 Oct 2013 00:07:11 +0000
Message-ID: <20131030000701.GB25469@macbook.localnet>
References: <2060a7d2-c307-4e30-b1d4-0bd26c904d6f@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Tomas Hlavacek <tmshlvck@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2060a7d2-c307-4e30-b1d4-0bd26c904d6f@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 29, 2013 at 10:07:59PM +0100, Tomas Hlavacek wrote:
> Hi!
> 
> I have encountered following condition on 3 distinct hosts in last
> few days. Hosts are failing several times a day (4 to 7 times) and
> it usually happens roughly at the same time. Affected hosts has
> almost exactly the same HW, but different kernel versions from
> Debian (Wheezy) default 3.2 up to 3.11.6.
> 
> 
>      KERNEL: /usr/src/vmlinux                   DUMPFILE:
> dump.201310291545  [PARTIAL DUMP]
>        CPUS: 16
>        DATE: Tue Oct 29 15:45:11 2013
>      UPTIME: 06:04:17
> LOAD AVERAGE: 0.04, 0.25, 0.32
>       TASKS: 211
>    NODENAME: fw03a
>     RELEASE: 3.11.6
>     VERSION: #2 SMP Mon Oct 28 20:29:03 CET 2013
>     MACHINE: x86_64  (2393 Mhz)
>      MEMORY: 12 GB
>       PANIC:         PID: 0
>     COMMAND: "swapper/1"
>        TASK: ffff8801b90ac7b0  (1 of 16)  [THREAD_INFO: ffff8801b90b4000]
>         CPU: 1
>       STATE: TASK_RUNNING (PANIC)
> 
> crash> bt
> PID: 0      TASK: ffff8801b90ac7b0  CPU: 1   COMMAND: "swapper/1"
> #0 [ffff8801bfc235d0] machine_kexec at ffffffff81032f68
> #1 [ffff8801bfc23610] crash_kexec at ffffffff8109e055
> #2 [ffff8801bfc236e0] oops_end at ffffffff81005e90
> #3 [ffff8801bfc23700] do_invalid_op at ffffffff81003004
> #4 [ffff8801bfc237a0] invalid_op at ffffffff8142b368
>    [exception RIP: pskb_expand_head+596]
>    RIP: ffffffff81333c74  RSP: ffff8801bfc23850  RFLAGS: 00010202
>    RAX: 0000000000000003  RBX: ffff8801b6d99080  RCX: 0000000000000020
>    RDX: 00000000000005f4  RSI: 0000000000000000  RDI: ffff8801b6d99080
>    RBP: 0000000040115833   R8: 00000000000002c0   R9: ffff8801b8cf2c00
>    R10: 000000000000ffff  R11: 00000000197033fe  R12: 0000000000000000
>    R13: ffff880337b59a00  R14: ffffffffa03fb160  R15: ffff880337b59a00
>    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
> #5 [ffff8801bfc23858] __nf_conntrack_confirm at ffffffffa03ace16
> [nf_conntrack]
> #6 [ffff8801bfc238c8] vlan_netlink_fini at ffffffffa03fb160 [8021q]
> #7 [ffff8801bfc23928] dev_queue_xmit at ffffffff81342d79
> #8 [ffff8801bfc23978] ip6_finish_output2 at ffffffff813d26ee
> #9 [ffff8801bfc239c8] ip6_forward at ffffffff813d44be
> #10 [ffff8801bfc23a48] __ipv6_conntrack_in at ffffffffa034f7b6
> [nf_conntrack_ipv6]
> #11 [ffff8801bfc23a98] nf_iterate at ffffffff8136ba0d
> #12 [ffff8801bfc23af8] nf_hook_slow at ffffffff8136baae
> #13 [ffff8801bfc23b68] nf_ct_frag6_output at ffffffffa039decf
> [nf_defrag_ipv6]
> #14 [ffff8801bfc23bd8] ipv6_defrag at ffffffffa039d0c1 [nf_defrag_ipv6]
> #15 [ffff8801bfc23c18] nf_iterate at ffffffff8136ba0d
> #16 [ffff8801bfc23c78] nf_hook_slow at ffffffff8136baae
> #17 [ffff8801bfc23ce8] ipv6_rcv at ffffffff813d59f5
> #18 [ffff8801bfc23d38] __netif_receive_skb_core at ffffffff813410db
> #19 [ffff8801bfc23db8] napi_gro_receive at ffffffff81341d88
> #20 [ffff8801bfc23dd8] igb_poll at ffffffffa0035867 [igb]
> #21 [ffff8801bfc23e88] net_rx_action at ffffffff81341ac9
> #22 [ffff8801bfc23ed8] __do_softirq at ffffffff81049fb6
> #23 [ffff8801bfc23f38] call_softirq at ffffffff8142b4fc
> #24 [ffff8801bfc23f50] do_softirq at ffffffff8100481d
> #25 [ffff8801bfc23f80] do_IRQ at ffffffff810043bb
> --- <IRQ stack> ---
> #26 [ffff8801b90b5db8] ret_from_intr at ffffffff81429baa
>    [exception RIP: cpuidle_enter_state+86]
>    RIP: ffffffff813107a6  RSP: ffff8801b90b5e68  RFLAGS: 00000216
>    RAX: 000000000007ff2b  RBX: 0000000140523c4c  RCX: 0000000000000018
>    RDX: 0000000225c17d03  RSI: 0000000000000000  RDI: ffffffff81812600
>    RBP: 0000000000000004   R8: 0000000000000018   R9: 00000000000006cf
>    R10: 0000000000000001  R11: 0000000000000006  R12: 0000000100523c4e
>    R13: 0000000000000000  R14: ffffffff81066415  R15: 0000000000000086
>    ORIG_RAX: ffffffffffffff94  CS: 0010  SS: 0018
> #27 [ffff8801b90b5eb0] cpuidle_idle_call at ffffffff813108ce
> #28 [ffff8801b90b5ee0] arch_cpu_idle at ffffffff8100b769
> #29 [ffff8801b90b5ef0] cpu_startup_entry at ffffffff81086b1d
> #30 [ffff8801b90b5f30] start_secondary at ffffffff8102af40
> 
> I am investigating at the moment. All suggestions/help would be
> appreciated.

The problem is that the reassembled packet is referenced by the individual
fragments, so we trigger the BUG_ON in pskb_expand_head(). In this
particular case the case we BUG() on is actually OK, but I'm looking at
a way we can fix this without special casing. Hope to have a patch for
testing in the next hours.
