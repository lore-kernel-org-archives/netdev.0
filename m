From: Thomas Graf <tgraf@suug.ch>
Subject: Re: skb_checksum_help
Date: Mon, 24 Jan 2005 13:22:47 +0100
Message-ID: <20050124122247.GQ23931@postel.suug.ch>
References: <20050124005348.GL23931@postel.suug.ch> <E1Cst4o-0007bD-00@gondolin.me.apana.org.au> <20050123202715.281ac87c.davem@davemloft.net> <20050124045635.GA30372@gondor.apana.org.au> <41F48293.9050301@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>, david@davidcoulson.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41F48293.9050301@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <41F48293.9050301@trash.net> 2005-01-24 06:07
> Herbert Xu wrote:
> 
> >Another possibility is some bogus netfilter module that the
> >reporter is using.  His backtrace was showing an ipq_kill which
> >isn't in the main tree.
> >
> I was fooled by the name too, ipq_kill doesn't belong to ip_queue but
> to net/ipv4/ip_fragment.c.

I followed this one too because it is directly related to frag reasm
but it is a regular occurance called by a timer, here's a backtrace
without ipq_kill:

kernel BUG at net/core/dev.c:1103!
invalid operand: 0000 [#1]
SMP 
CPU:    0
EIP:    0060:[<c02bb4bd>]    Not tainted VLI
EFLAGS: 00010282   (2.6.10-ac8) 
EIP is at skb_checksum_help+0xcd/0x120
eax: 00000011   ebx: f665bb80   ecx: c04bfc84   edx: 00000296
esi: 0000011d   edi: 1e97231e   ebp: f4d76941   esp: c04bfc80
ds: 007b   es: 007b   ss: 0068
Process swapper (pid: 0, threadinfo=c04be000 task=c040db40)
Stack: c03f84c8 00000008 00000000 f665bb80 f7e31c00 00000000 fffffff4 c02bb866 
       00000000 f691b520 00000286 f6ffe4a4 f665bb80 0000000e f6ffe480 c02c1095 
       f6ffe4a8 00000000 00000131 f4dc0b80 f4d76800 00000000 f665bb80 c02edb5e 
Call Trace:
 [<c02bb866>] dev_queue_xmit+0x246/0x290
 [<c02c1095>] neigh_connected_output+0x85/0xd0
 [<c02edb5e>] ip_finish_output2+0xce/0x1a0
 [<c02ec420>] ip_fragment+0x5e0/0x6f0
 [<c02eda90>] ip_finish_output2+0x0/0x1a0
 [<c02eda90>] ip_finish_output2+0x0/0x1a0
 [<c031e17f>] ip_refrag+0x6f/0x80
 [<c02eda90>] ip_finish_output2+0x0/0x1a0
 [<c02c5152>] nf_iterate+0x72/0xb0
 [<c02eda90>] ip_finish_output2+0x0/0x1a0
 [<c02eda90>] ip_finish_output2+0x0/0x1a0
 [<c02c53f8>] nf_hook_slow+0x68/0xf0
 [<c02eda90>] ip_finish_output2+0x0/0x1a0
 [<c02eda90>] ip_finish_output2+0x0/0x1a0
 [<c02eb6c1>] ip_finish_output+0x1e1/0x1f0
 [<c02eda90>] ip_finish_output2+0x0/0x1a0
 [<c02ec420>] ip_fragment+0x5e0/0x6f0
 [<c0326698>] ipt_hook+0x28/0x30
 [<c02c5152>] nf_iterate+0x72/0xb0
 [<c02eb4e0>] ip_finish_output+0x0/0x1f0
 [<c02ea0f0>] ip_forward_finish+0x0/0x50
 [<c02ea119>] ip_forward_finish+0x29/0x50
 [<c02c5442>] nf_hook_slow+0xb2/0xf0
 [<c02ea0f0>] ip_forward_finish+0x0/0x50
 [<c02ea02c>] ip_forward+0x1bc/0x280
 [<c02ea0f0>] ip_forward_finish+0x0/0x50
 [<c02e8e98>] ip_rcv_finish+0x1f8/0x270
 [<c02c5152>] nf_iterate+0x72/0xb0
 [<c02e8ca0>] ip_rcv_finish+0x0/0x270
 [<c02e8ca0>] ip_rcv_finish+0x0/0x270
 [<c02c5442>] nf_hook_slow+0xb2/0xf0
 [<c02e8ca0>] ip_rcv_finish+0x0/0x270
 [<c02e8a0c>] ip_rcv+0x3ec/0x4b0
 [<c02e8ca0>] ip_rcv_finish+0x0/0x270
 [<c02bbf5a>] netif_receive_skb+0x20a/0x2b0
 [<c02bc086>] process_backlog+0x86/0x120
 [<c02bc19f>] net_rx_action+0x7f/0x110
 [<c011c606>] __do_softirq+0xb6/0xd0
 [<c011c64d>] do_softirq+0x2d/0x30
 [<c010474e>] do_IRQ+0x1e/0x30
 [<c0102ef2>] common_interrupt+0x1a/0x20
 [<c01006f0>] default_idle+0x0/0x40
 [<c0100719>] default_idle+0x29/0x40
 [<c01007ab>] cpu_idle+0x3b/0x50
 [<c04c08ab>] start_kernel+0x13b/0x160
 [<c04c0350>] unknown_bootoption+0x0/0x1c0
Code: 83 a8 00 00 00 72 04 39 e8 76 0c c7 04 24 aa 84 3f c0 e8 47 cb e5 ff 0f b7 43 78 c7 04 24 c8 84 3f c0 89 44 24 04 e8 33 cb e5 ff <0f> 0b 4f 04 93 84 3f c0 8b 4b 24 8b 53 6c 89 f8 c1 e0 10 81 e7 
 <0>Kernel panic - not syncing: Fatal exception in interrupt
