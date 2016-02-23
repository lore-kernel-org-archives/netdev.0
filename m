From: Wakko Warner <wakko@animx.eu.org>
Subject: Re: 4.4.1 skb_warn_bad_offload+0xc5/0x110
Date: Mon, 22 Feb 2016 20:35:09 -0500
Message-ID: <20160223013509.GA14041@animx.eu.org>
References: <20160216000838.GA12968@animx.eu.org>
 <56CB0CF5.1060906@stressinduktion.org>
Reply-To: Wakko Warner <wakko@animx.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56CB0CF5.1060906@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please keep me in CC.

Hannes Frederic Sowa wrote:
> [full-quote for netdev]
> On 16.02.2016 01:08, Wakko Warner wrote:
> >I've been seeing the following on some of my VMs ran under qemu.  The VMs do
> >not have internet connectivity.  This happened when some files were accessed
> >via NFS to another VM (NOTE: Both VMs throw these warnings.  Both VMs are
> >running the exact same kernel).  The host is also throwing these warnings
> >and is also 4.4.1, but not the same kernel build.
> >
> >The issue appears to have gone away if I issue the following on the guests
> >and on the host (except br0 instead of eth0 on host)
> >ethtool -K eth0 gso off gro off ufo off tso off
> >
> >On the host, br0 does not have any interfaces enslaved except for the
> >interface for the VMs and also does not have an IPv4 address assigned.
> >
> >[   90.067519] ------------[ cut here ]------------
> >[   90.067678] WARNING: CPU: 0 PID: 2258 at /usr/src/linux/dist/4.4.1-nobklcd/net/core/dev.c:2422 skb_warn_bad_offload+0xc5/0x110()
> >[   90.067766] virtio_net: caps=(0x00000804001f4a29, 0x0000000000000000) len=32934 data_len=32768 gso_size=1480 gso_type=2 ip_summed=0
> >[   90.067878] Modules linked in: nfsv3 nfsd auth_rpcgss oid_registry exportfs nfs lockd grace sunrpc ipv6 virtio_net virtio_balloon evdev unix
> >[   90.068206] CPU: 0 PID: 2258 Comm: kworker/0:1H Not tainted 4.4.1 #1
> >[   90.068258] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS Debian-1.8.2-1 04/01/2014
> >[   90.068340] Workqueue: rpciod rpc_async_schedule [sunrpc]
> >[   90.068433]  ffffffff81503288 ffffffff811d455e ffff880276ffb9a0 ffffffff81041343
> >[   90.068575]  ffff88007b85be00 ffff880276ffb9f0 0000000000000002 ffff880276f87aac
> >[   90.068725]  ffff88027692c000 ffffffff810413b7 ffffffff81503498 ffffffff00000030
> >[   90.068846] Call Trace:
> >[   90.068888]  [<ffffffff811d455e>] ? dump_stack+0x47/0x69
> >[   90.068967]  [<ffffffff81041343>] ? warn_slowpath_common+0x73/0xa0
> >[   90.069068]  [<ffffffff810413b7>] ? warn_slowpath_fmt+0x47/0x50
> >[   90.069129]  [<ffffffff813103a5>] ? skb_warn_bad_offload+0xc5/0x110
> >[   90.069191]  [<ffffffff81313121>] ? __skb_gso_segment+0x71/0xc0
> >[   90.069250]  [<ffffffff81313460>] ? validate_xmit_skb.isra.119.part.120+0x100/0x290
> >[   90.069314]  [<ffffffff810848a9>] ? lock_timer_base.isra.22+0x49/0x60
> >[   90.069381]  [<ffffffff81313931>] ? validate_xmit_skb_list+0x31/0x50
> >[   90.069440]  [<ffffffff8132d3a0>] ? sch_direct_xmit+0x140/0x1e0
> >[   90.069497]  [<ffffffff81313be8>] ? __dev_queue_xmit+0x1c8/0x490
> >[   90.069555]  [<ffffffff8133e5e2>] ? ip_finish_output2+0x122/0x300
> >[   90.069613]  [<ffffffff812fda6d>] ? release_sock+0xfd/0x160
> >[   90.069671]  [<ffffffff8133fe25>] ? ip_output+0xb5/0xc0
> >[   90.069720]  [<ffffffff8133dab0>] ? ip_reply_glue_bits+0x50/0x50
> >[   90.069784]  [<ffffffff811e028b>] ? prandom_u32+0x1b/0x30
> >[   90.069833]  [<ffffffff8133f5f2>] ? ip_local_out+0x12/0x40
> >[   90.069877]  [<ffffffff81340710>] ? ip_send_skb+0x10/0x40
> >[   90.069922]  [<ffffffff81363760>] ? udp_send_skb+0x160/0x240
> >[   90.069990]  [<ffffffff81363874>] ? udp_push_pending_frames+0x34/0x50
> >[   90.070050]  [<ffffffff813650e4>] ? udp_sendpage+0xe4/0x150
> >[   90.070095]  [<ffffffff812fa4fa>] ? kernel_sendmsg+0x2a/0x40
> >[   90.070164]  [<ffffffffa008a233>] ? xs_send_kvec+0x83/0x90 [sunrpc]
> >[   90.070223]  [<ffffffff813702f3>] ? inet_sendpage+0x93/0xe0
> >[   90.070270]  [<ffffffffa008a3af>] ? xs_sendpages+0x16f/0x1b0 [sunrpc]
> >[   90.070330]  [<ffffffffa008a60e>] ? xs_udp_send_request+0x5e/0x100 [sunrpc]
> >[   90.070390]  [<ffffffffa0088807>] ? xprt_transmit+0x47/0x230 [sunrpc]
> >[   90.070449]  [<ffffffffa0086255>] ? call_transmit+0x175/0x220 [sunrpc]
> >[   90.070508]  [<ffffffffa008cdbb>] ? __rpc_execute+0x4b/0x290 [sunrpc]
> >[   90.070575]  [<ffffffff8105d123>] ? finish_task_switch+0x83/0x1b0
> >[   90.070653]  [<ffffffff81054ba9>] ? process_one_work+0x129/0x3f0
> >[   90.070711]  [<ffffffff81054eb2>] ? worker_thread+0x42/0x490
> >[   90.070764]  [<ffffffff81054e70>] ? process_one_work+0x3f0/0x3f0
> >[   90.070816]  [<ffffffff81059a98>] ? kthread+0xb8/0xd0
> >[   90.070860]  [<ffffffff810599e0>] ? kthread_worker_fn+0x100/0x100
> >[   90.070925]  [<ffffffff813a2fff>] ? ret_from_fork+0x3f/0x70
> >[   90.070974]  [<ffffffff810599e0>] ? kthread_worker_fn+0x100/0x100
> >[   90.071035] ---[ end trace ffb4f8c2d24c1959 ]---
> >
> 
> Can you try the following patch?

I'll try it tomorrow.  I had some disk failures on this system and am in the
process of restoring it.

> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -1233,6 +1233,9 @@ ssize_t   ip_append_page(struct sock *sk,
> struct flowi4 *fl4, struct page *page,
>         if (!skb)
>                 return -EINVAL;
> 
> +       if (skb->ip_summed != CHECKSUM_PARTIAL)
> +               return -EINVAL;
> +
>         cork->length += size;
>         if ((size + skb->len > mtu) &&
>             (sk->sk_protocol == IPPROTO_UDP) &&
-- 
 Microsoft has beaten Volkswagen's world record.  Volkswagen only created 22
 million bugs.
