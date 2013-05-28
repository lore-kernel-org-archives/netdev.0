From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch v2] skbuff: Hide GFP_ATOMIC page allocation failures for
 dropped packets
Date: Tue, 28 May 2013 10:46:01 -0700
Message-ID: <1369763161.3301.545.camel@edumazet-glaptop>
References: <1369601101-23057-1-git-send-email-atomlin@redhat.com>
	 <20130527224149.GA4384@electric-eye.fr.zoreil.com>
	 <51A4D4AD.2010507@candelatech.com>
	 <20130528161518.GC11614@optiplex.redhat.com>
	 <1369758577.3301.543.camel@edumazet-glaptop>
	 <20130528174304.GD11614@optiplex.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Francois Romieu <romieu@fr.zoreil.com>, atomlin@redhat.com,
	netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	pshelar@nicira.com, mst@redhat.com, alexander.h.duyck@intel.com,
	riel@redhat.com, sergei.shtylyov@cogentembedded.com,
	linux-kernel@vger.kernel.org
To: Rafael Aquini <aquini@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130528174304.GD11614@optiplex.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-05-28 at 14:43 -0300, Rafael Aquini wrote:

> 
> Perhaps the explanation is because we're looking into old stuff bad effects,
> then. But just to list a few for your appreciation:
> --------------------------------------------------------


> --------------------------------------------------------
> May 14 09:00:34 ifil03 kernel: swapper: page allocation failure. order:1,
> mode:0x20
> May 14 09:00:34 ifil03 kernel: Pid: 0, comm: swapper Not tainted
> 2.6.32-220.el6.x86_64 #1
> May 14 09:00:34 ifil03 kernel: Call Trace:
> May 14 09:00:34 ifil03 kernel: <IRQ>  [<ffffffff81123f0f>] ?
> __alloc_pages_nodemask+0x77f/0x940
> May 14 09:00:34 ifil03 kernel: [<ffffffff8115ddc2>] ? kmem_getpages+0x62/0x170
> May 14 09:00:34 ifil03 kernel: [<ffffffff8115e9da>] ? fallback_alloc+0x1ba/0x270
> May 14 09:00:34 ifil03 kernel: [<ffffffff8115e42f>] ? cache_grow+0x2cf/0x320
> May 14 09:00:34 ifil03 kernel: [<ffffffff8115e759>] ?
> ____cache_alloc_node+0x99/0x160
> May 14 09:00:34 ifil03 kernel: [<ffffffff8115f53b>] ?
> kmem_cache_alloc+0x11b/0x190
> May 14 09:00:34 ifil03 kernel: [<ffffffff8141f528>] ? sk_prot_alloc+0x48/0x1c0
> May 14 09:00:34 ifil03 kernel: [<ffffffff8141f7b2>] ? sk_clone+0x22/0x2e0
> May 14 09:00:34 ifil03 kernel: [<ffffffff8146ca26>] ? inet_csk_clone+0x16/0xd0
> May 14 09:00:34 ifil03 kernel: [<ffffffff814858f3>] ?
> tcp_create_openreq_child+0x23/0x450
> May 14 09:00:34 ifil03 kernel: [<ffffffff814832dd>] ?
> tcp_v4_syn_recv_sock+0x4d/0x2a0
> May 14 09:00:34 ifil03 kernel: [<ffffffff814856b1>] ? tcp_check_req+0x201/0x420
> May 14 09:00:34 ifil03 kernel: [<ffffffff8147b166>] ?
> tcp_rcv_state_process+0x116/0xa30
> May 14 09:00:34 ifil03 kernel: [<ffffffff81482cfb>] ? tcp_v4_do_rcv+0x35b/0x430
> May 14 09:00:34 ifil03 kernel: [<ffffffff81484471>] ? tcp_v4_rcv+0x4e1/0x860
> May 14 09:00:34 ifil03 kernel: [<ffffffff814621fd>] ?
> ip_local_deliver_finish+0xdd/0x2d0
> May 14 09:00:34 ifil03 kernel: [<ffffffff81462488>] ? ip_local_deliver+0x98/0xa0
> May 14 09:00:34 ifil03 kernel: [<ffffffff8146194d>] ? ip_rcv_finish+0x12d/0x440
> May 14 09:00:34 ifil03 kernel: [<ffffffff8101bd86>] ?
> intel_pmu_enable_all+0xa6/0x150
> May 14 09:00:34 ifil03 kernel: [<ffffffff81461ed5>] ? ip_rcv+0x275/0x350
> May 14 09:00:34 ifil03 kernel: [<ffffffff8142bedb>] ?
> __netif_receive_skb+0x49b/0x6e0
> May 14 09:00:34 ifil03 kernel: [<ffffffff8142df88>] ?
> netif_receive_skb+0x58/0x60
> May 14 09:00:34 ifil03 kernel: [<ffffffffa00a0a9e>] ?
> vmxnet3_rq_rx_complete+0x36e/0x880 [vmxnet3]
> ....
> --

I hope you do realize this path has nothing to do with skb allocation ,
but socket cloning ?
