From: Thomas Graf <tgraf@suug.ch>
Subject: Re: skb_checksum_help
Date: Mon, 24 Jan 2005 01:53:48 +0100
Message-ID: <20050124005348.GL23931@postel.suug.ch>
References: <41F432BD.3000300@davidcoulson.net> <20050124003241.GJ23931@postel.suug.ch> <41F44605.6050001@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Coulson <david@davidcoulson.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41F44605.6050001@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <41F44605.6050001@trash.net> 2005-01-24 01:49
> Thomas Graf wrote:
> 
> >I CC'ed netdev, this seems more serious than I thought.
> >
> >Background: David noticed the assertion csum + 2 > offset being trigged
> >in skb_checksum_help. I sent him a patch converting it into a warning
> >printing offset, len, n.raw, tail, csum, features and the whole packet
> >as hexdump. He uses the acenic driver which is actually capable of doing
> >IP checksumming. (Patch enclosed at the end)
> >
> How does the backtrace look ?

It's a normal forwarded packet as it seems. ipq_kill doesn't show
up in other occurances of this bug.

kernel BUG at net/core/dev.c:1100!
invalid operand: 0000 [#1]
SMP
CPU:    0
EIP:    0060:[<c02b78dc>]    Not tainted VLI
EFLAGS: 00010216   (2.6.10)
EIP is at skb_checksum_help+0x9c/0xf0
eax: 00009ec4   ebx: 000001ce   ecx: 00009ec2   edx: adc3f0fe
esi: f6b58b80   edi: f693d824   ebp: 00000000   esp: c04c3c84
ds: 007b   es: 007b   ss: 0068
Process swapper (pid: 0, threadinfo=c04c2000 task=c0410b40)
Stack: adc3f0fe f6b58b80 f7034000 00000000 fffffff4 c02b7c86 000073a6 
02e0f250
        00000282 f6de9ea4 f6b58b80 f6de9e80 0000000e c02bd354 f6de9ea8 
00000000
        000001e2 c02e5697 f589b680 f693d800 f693d824 f6b58b80 c02ea0de 
00000000
Call Trace:
  [<c02b7c86>] dev_queue_xmit+0x246/0x290
  [<c02bd354>] neigh_resolve_output+0xc4/0x1b0
  [<c02e5697>] ipq_kill+0x67/0x80
  [<c02ea0de>] ip_finish_output2+0xce/0x1a0
  [<c02e8998>] ip_fragment+0x638/0x750
  [<c02ea010>] ip_finish_output2+0x0/0x1a0
  [<c02ea010>] ip_finish_output2+0x0/0x1a0
  [<c031a70f>] ip_refrag+0x6f/0x80
  [<c02ea010>] ip_finish_output2+0x0/0x1a0
  [<c02c1592>] nf_iterate+0x72/0xb0
  [<c02ea010>] ip_finish_output2+0x0/0x1a0
  [<c02ea010>] ip_finish_output2+0x0/0x1a0
  [<c02c1898>] nf_hook_slow+0x68/0xf0
  [<c02ea010>] ip_finish_output2+0x0/0x1a0
  [<c02ea010>] ip_finish_output2+0x0/0x1a0
  [<c02e7ba1>] ip_finish_output+0x1e1/0x1f0
  [<c02ea010>] ip_finish_output2+0x0/0x1a0
  [<c02e8998>] ip_fragment+0x638/0x750
  [<c0322c28>] ipt_hook+0x28/0x30
  [<c02c1592>] nf_iterate+0x72/0xb0
  [<c02e79c0>] ip_finish_output+0x0/0x1f0
  [<c02e65d0>] ip_forward_finish+0x0/0x50
  [<c02e65f9>] ip_forward_finish+0x29/0x50
  [<c02c18e2>] nf_hook_slow+0xb2/0xf0
  [<c02e65d0>] ip_forward_finish+0x0/0x50
  [<c02e650c>] ip_forward+0x1bc/0x280
  [<c02e65d0>] ip_forward_finish+0x0/0x50
  [<c02e5378>] ip_rcv_finish+0x1f8/0x270
  [<c02c1592>] nf_iterate+0x72/0xb0
  [<c02e5180>] ip_rcv_finish+0x0/0x270
  [<c02e5180>] ip_rcv_finish+0x0/0x270
  [<c02c18e2>] nf_hook_slow+0xb2/0xf0
  [<c02e5180>] ip_rcv_finish+0x0/0x270
  [<c02e4eec>] ip_rcv+0x3ec/0x4b0
  [<c02e5180>] ip_rcv_finish+0x0/0x270
  [<c0241e09>] ace_rx_int+0x2f9/0x3d0
  [<c02b837a>] netif_receive_skb+0x20a/0x2b0
  [<c02b84a6>] process_backlog+0x86/0x120
  [<c02b85bf>] net_rx_action+0x7f/0x110
  [<c011c5d6>] __do_softirq+0xb6/0xd0
  [<c011c61d>] do_softirq+0x2d/0x30
  [<c010474e>] do_IRQ+0x1e/0x30
  [<c0102ef2>] common_interrupt+0x1a/0x20
  [<c01006f0>] default_idle+0x0/0x40
  [<c0100719>] default_idle+0x29/0x40
  [<c01007ab>] cpu_idle+0x3b/0x50
  [<c04c48ab>] start_kernel+0x13b/0x160
  [<c04c4350>] unknown_bootoption+0x0/0x1c0
Code: 24 00 00 00 00 29 d9 89 da 89 f0 e8 df bb ff ff 8b 9e b0 00 00 00 
89 c2 8b 7e 24 29 fb 85 db 7e 4e 8b 4e 6c 8d 41 02 39 d8 76 08 <0f> 0b 
4c 04 73 ad 3f c0 89 d0 c1 e0 10 81 e2 00 00 ff ff 01 c2
  <0>Kernel panic - not syncing: Fatal exception in interrupt

> The check looks bogus:
> 
> >+		if (skb->h.raw < skb->data || skb->h.raw > skb->data)
> >+			printk(KERN_CRIT "skb hdr corrupted!\n");

Right, my fault, should have been skb->tail in the second check.
