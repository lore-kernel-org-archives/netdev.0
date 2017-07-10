From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 00/12] Implement XDP bpf_redirect vairants
Date: Mon, 10 Jul 2017 20:30:50 +0200
Message-ID: <20170710203050.54b2d8eb@redhat.com>
References: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810>
        <595FC974.9030807@gmail.com>
        <20170708.104618.2149883426031901592.davem@davemloft.net>
        <20170708210617.249059b9@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, netdev@vger.kernel.org,
        andy@greyhouse.net, daniel@iogearbox.net, ast@fb.com,
        alexander.duyck@gmail.com, bjorn.topel@intel.com,
        jakub.kicinski@netronome.com, ecree@solarflare.com,
        sgoutham@cavium.com, Yuval.Mintz@cavium.com, saeedm@mellanox.com,
        brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51926 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754648AbdGJSa7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Jul 2017 14:30:59 -0400
In-Reply-To: <20170708210617.249059b9@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 8 Jul 2017 21:06:17 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> On Sat, 08 Jul 2017 10:46:18 +0100 (WEST)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: John Fastabend <john.fastabend@gmail.com>
> > Date: Fri, 07 Jul 2017 10:48:36 -0700
> >   
> > > On 07/07/2017 10:34 AM, John Fastabend wrote:    
> > >> This series adds two new XDP helper routines bpf_redirect() and
> > >> bpf_redirect_map(). The first variant bpf_redirect() is meant
> > >> to be used the same way it is currently being used by the cls_bpf
> > >> classifier. An xdp packet will be redirected immediately when this
> > >> is called.    
> > > 
> > > Also other than the typo in the title there ;) I'm going to CC
> > > the driver maintainers working on XDP (makes for a long CC list but)
> > > because we would want to try and get support in as many as possible in
> > > the next merge window.
> > > 
> > > For this rev I just implemented on ixgbe because I wrote the
> > > original XDP support there. I'll volunteer to do virtio as well.    
> > 
> > I went over this series a few times and it looks great to me.
> > You didn't even give me some coding style issues to pick on :-)  
> 
> We (Daniel, Andy and I) have been reviewing and improving on this
> patchset the last couple of weeks ;-).  We had some stability issues,
> which is why it wasn't published earlier. My plan is to test this
> latest patchset again, Monday and Tuesday. I'll try to assess stability
> and provide some performance numbers.


Damn, I though it was stable, I have been running a lot of performance
tests, and then this just happened :-(

[11357.149486] BUG: unable to handle kernel NULL pointer dereference at 0000000000000210
[11357.157393] IP: __dev_map_flush+0x58/0x90
[11357.161446] PGD 3ff685067 
[11357.161446] P4D 3ff685067 
[11357.164199] PUD 3ff684067 
[11357.166947] PMD 0 
[11357.170396] 
[11357.173981] Oops: 0000 [#1] PREEMPT SMP
[11357.177859] Modules linked in: coretemp kvm_intel kvm irqbypass intel_cstate intel_uncore intel_rapl_perf mxm_wmi i2c_i801 pcspkr sg i2c_co]
[11357.203021] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.12.0-net-next-xdp_redirect02-rfc+ #135
[11357.211706] Hardware name: To Be Filled By O.E.M. To Be Filled By O.E.M./Z97 Extreme4, BIOS P2.10 05/12/2015
[11357.221606] task: ffffffff81c0e480 task.stack: ffffffff81c00000
[11357.227568] RIP: 0010:__dev_map_flush+0x58/0x90
[11357.232138] RSP: 0018:ffff88041fa03de0 EFLAGS: 00010286
[11357.237409] RAX: 0000000000000000 RBX: ffff8803fc996600 RCX: 0000000000000003
[11357.244589] RDX: ffff88040d0bf480 RSI: 0000000000000000 RDI: ffffffff81d901d8
[11357.251767] RBP: ffff88041fa03df8 R08: fffffffffffffffc R09: 0000000700000008
[11357.258940] R10: ffffffff813f11d0 R11: 0000000000000040 R12: ffffe8ffffc014a0
[11357.266119] R13: 0000000000000003 R14: 000000000000003c R15: ffff8803fc9c26c0
[11357.273294] FS:  0000000000000000(0000) GS:ffff88041fa00000(0000) knlGS:0000000000000000
[11357.281454] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[11357.287244] CR2: 0000000000000210 CR3: 00000003fc41e000 CR4: 00000000001406f0
[11357.294423] Call Trace:
[11357.296912]  <IRQ>
[11357.298967]  xdp_do_flush_map+0x36/0x40
[11357.302847]  ixgbe_poll+0x7ea/0x1370 [ixgbe]
[11357.307160]  net_rx_action+0x247/0x3e0
[11357.310957]  __do_softirq+0x106/0x2cb
[11357.314664]  irq_exit+0xbe/0xd0
[11357.317851]  do_IRQ+0x4f/0xd0
[11357.320858]  common_interrupt+0x86/0x86
[11357.324733] RIP: 0010:poll_idle+0x2f/0x5a
[11357.328781] RSP: 0018:ffffffff81c03dd0 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff8e
[11357.336426] RAX: 0000000000000000 RBX: ffffffff81d689e0 RCX: 0000000000200000
[11357.343605] RDX: 0000000000000000 RSI: ffffffff81c0e480 RDI: ffff88041fa22800
[11357.350783] RBP: ffffffff81c03dd0 R08: 00000000000003c5 R09: 0000000000000018
[11357.357958] R10: 0000000000000327 R11: 0000000000000390 R12: ffff88041fa22800
[11357.365135] R13: ffffffff81d689f8 R14: 0000000000000000 R15: ffffffff81d689e0
[11357.372311]  </IRQ>
[11357.374453]  cpuidle_enter_state+0xf2/0x2e0
[11357.378678]  cpuidle_enter+0x17/0x20
[11357.382299]  call_cpuidle+0x23/0x40
[11357.385834]  do_idle+0xe8/0x190
[11357.389024]  cpu_startup_entry+0x1d/0x20
[11357.392993]  rest_init+0xd5/0xe0
[11357.396268]  start_kernel+0x3d7/0x3e4
[11357.399979]  x86_64_start_reservations+0x2a/0x2c
[11357.404641]  x86_64_start_kernel+0x178/0x18b
[11357.408959]  secondary_startup_64+0x9f/0x9f
[11357.413186]  ? secondary_startup_64+0x9f/0x9f
[11357.417589] Code: 41 89 c5 48 8b 53 60 44 89 e8 48 8d 14 c2 48 8b 12 48 85 d2 74 23 48 8b 3a f0 49 0f b3 04 24 48 85 ff 74 15 48 8b 87 e0 0 
[11357.436565] RIP: __dev_map_flush+0x58/0x90 RSP: ffff88041fa03de0
[11357.442613] CR2: 0000000000000210
[11357.445972] ---[ end trace f7ed232095169a98 ]---
[11357.450637] Kernel panic - not syncing: Fatal exception in interrupt
[11357.457038] Kernel Offset: disabled
[11357.460566] ---[ end Kernel panic - not syncing: Fatal exception in interrupt

(gdb) list *(__dev_map_flush)+0x58
0xffffffff811422a8 is in __dev_map_flush (kernel/bpf/devmap.c:257).
252				continue;
253	
254			netdev = dev->dev;
255	
256			clear_bit(bit, bitmap);
257			if (unlikely(!netdev || !netdev->netdev_ops->ndo_xdp_flush))
258				continue;
259	
260			netdev->netdev_ops->ndo_xdp_flush(netdev);
261		}

My analysis it that "netdev->netdev_ops == NULL" as:

 NULL pointer dereference at 0000000000000210
 $ echo $((0x210))
 528

As ndo_xdp_flush is at offset 528 in struct net_device_ops.

 $ pahole -C net_device_ops vmlinux
 void (*ndo_xdp_flush)(struct net_device *); /*   528     8 */

But I cannot see where/what will change netdev->netdev_ops to be NULL?!?


> I've complained/warned about the danger of redirecting with XDP,
> without providing (1) a way to debug/see XDP redirects, (2) a way
> interfaces opt-in they can be redirected. (1) is solved by patch-07/12
> via a tracepoint. (2) is currently done by only forwarding to
> interfaces with an XDP program loaded itself, this also comes from a
> practical need for NIC drivers to allocate XDP-TX HW queues.
> 
> I'm not satisfied with the (UAPI) name for the new map
> "BPF_MAP_TYPE_DEVMAP" and the filename this is placed in
> "kernel/bpf/devmap.c", as we want to take advantage of compiler
> inlining for the next redirect map types.  (1) because the name doesn't
> tell the user that this map is connected to the redirect_map call.
> (2) we want to introduce other kinds of redirect maps (like redirect to
> CPUs and sockets), and it would be good if they shared a common "text"
> string.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
