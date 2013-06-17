From: Jun Chen <jun.d.chen@intel.com>
Subject: Re: [PATCH] tcp: Modify the condition for the first skb to collapse
Date: Mon, 17 Jun 2013 14:52:13 -0400
Message-ID: <1371495133.28418.19.camel@chenjun-workstation>
References: <1371478739.10495.5.camel@chenjun-workstation>
	 <1371456935.3252.177.camel@edumazet-glaptop>
	 <1371490190.28418.6.camel@chenjun-workstation>
	 <1371464962.3252.181.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, ncardwell@google.com, edumazet@google.com,
	netdev@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371464962.3252.181.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-06-17 at 03:29 -0700, Eric Dumazet wrote:
> On Mon, 2013-06-17 at 13:29 -0400, Jun Chen wrote:
> > > 
> > hi,
> > When the condition of tcp_win_from_space(skb->truesize) > skb->len is
> > true but the before(start, TCP_SKB_CB(skb)->seq) is also true, the final
> > condition will be true. The follow line:
> > int offset = start - TCP_SKB_CB(skb)->seq;
> > BUG_ON(offset < 0);
> > this BUG_ON will be triggered.
> > 
> 
> Really this should never happen, we must track what's happening here.
It's very very rare, but the logic of codes have such a little hole.
> 
> Are you using a pristine kernel, without any patches ?
The based kernel version is 3.4.  
> 
> Are you able to reproduce this bug in a short amount of time ?
I can't reproduce it in short time, this log had just been found once
for long long time tests on many devices . 
> 
> What kind of driver is in use ? (your stack trace was truncated)

I attach the whole stack traces for you.

<0>[ 7736.348788] Call Trace:

<4>[ 7736.348861]  [<c18addd0>] tcp_prune_queue+0x120/0x2f0

<4>[ 7736.348984]  [<c18aea27>] tcp_data_queue+0x777/0xf00

<4>[ 7736.349055]  [<c18dc8f8>] ? ipt_do_table+0x1f8/0x480

<4>[ 7736.349126]  [<c18dc8f8>] ? ipt_do_table+0x1f8/0x480

<4>[ 7736.349196]  [<c18b2e84>] tcp_rcv_established+0x114/0x680

<4>[ 7736.349269]  [<c18bb034>] tcp_v4_do_rcv+0x164/0x350

<4>[ 7736.349396]  [<c18de301>] ? nf_nat_fn+0xb1/0x1d0

<4>[ 7736.349470]  [<c18bc0c1>] tcp_v4_rcv+0x6f1/0x7a0

<4>[ 7736.349599]  [<c1881dad>] ? nf_hook_slow+0x10d/0x150

<4>[ 7736.349673]  [<c189b30b>] ip_local_deliver_finish+0x8b/0x200

<4>[ 7736.349796]  [<c189b60f>] ip_local_deliver+0x8f/0xa0

<4>[ 7736.349867]  [<c189b280>] ? ip_rcv_finish+0x300/0x300

<4>[ 7736.349937]  [<c189b05f>] ip_rcv_finish+0xdf/0x300

<4>[ 7736.350062]  [<c189b878>] ip_rcv+0x258/0x330

<4>[ 7736.350132]  [<c189af80>] ? inet_del_protocol+0x30/0x30

<4>[ 7736.350258]  [<c1864175>] __netif_receive_skb+0x325/0x410

<4>[ 7736.350331]  [<c1864956>] process_backlog+0x96/0x150

<4>[ 7736.350455]  [<c1864ba5>] net_rx_action+0x115/0x210

<4>[ 7736.350525]  [<c18b7680>] ? tcp_out_of_resources+0xb0/0xb0

<4>[ 7736.350652]  [<c123dc0b>] __do_softirq+0x9b/0x220

<4>[ 7736.350723]  [<c123db70>] ? local_bh_enable_ip+0xd0/0xd0

> 
> 
> 
