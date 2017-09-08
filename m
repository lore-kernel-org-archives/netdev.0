From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: WARN_ON() in __nf_hook_entries_try_shrink()
Date: Thu, 7 Sep 2017 17:01:12 -0700
Message-ID: <CA+55aFw64ihu1bai0Em8pXD4dZ-wFVtV7BRjWbDLLb2MPWWXkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        David Miller <davem@davemloft.net>,
        NetFilter <netfilter-devel@vger.kernel.org>,
        coreteam@netfilter.org,
        Network Development <netdev@vger.kernel.org>
To: Aaron Conole <aconole@bytheb.org>, Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On shutdown I get this (edited down a bit to be more legible):

  Stopping firewalld - dynamic firewall daemon...
  NETFILTER_CFG table=nat family=2 entries=55
  NETFILTER_CFG table=mangle family=2 entries=40
  NETFILTER_CFG table=raw family=2 entries=28
  NETFILTER_CFG table=security family=2 entries=13
  NETFILTER_CFG table=filter family=2 entries=93
  ------------[ cut here ]------------
  WARNING: CPU: 1 PID: 21512 at net/netfilter/core.c:218
__nf_hook_entries_try_shrink+0x106/0x130
  CPU: 1 PID: 21512 Comm: iptables-restor Not tainted
4.13.0-08555-gc0da4fa0d1a5 #7
  Hardware name: Dell Inc. XPS 13 9350/09JHRY, BIOS 1.4.17 05/10/2017
  RIP: 0010:__nf_hook_entries_try_shrink+0x106/0x130
  Call Trace:
     nf_unregister_net_hooks+0x117/0x240
     ipv4_hooks_unregister+0x60/0x70 [nf_conntrack_ipv4]
     nf_ct_netns_put+0x48/0x80 [nf_conntrack]
     conntrack_mt_destroy+0x15/0x20 [xt_conntrack]
     cleanup_match+0x43/0x70
     cleanup_entry+0x42/0xc0
     __do_replace+0x17a/0x1f0
     do_ipt_set_ctl+0x146/0x1b0
     nf_setsockopt+0x46/0x80
     ip_setsockopt+0x82/0xb0
     raw_setsockopt+0x34/0x40
     sock_common_setsockopt+0x14/0x20
     SyS_setsockopt+0x80/0xe0
     entry_SYSCALL_64_fastpath+0x13/0x94
[ .. warning repeats a few times .. ]
  ---[ end trace 56a6f5b20d97161d ]---
  NETFILTER_CFG table=broute family=7 entries=0
  NETFILTER_CFG table=nat family=7 entries=0
  NETFILTER_CFG table=filter family=7 entries=0
  NETFILTER_CFG table=mangle family=2 entries=6

and some searching notes that the kernel test robot already reported
this a few days ago but nobody reacted.

The kernel test robot seems to blame commit d3ad2c17b404 ("netfilter:
core: batch nf_unregister_net_hooks synchronize_net calls").

Hmm?

               Linus
