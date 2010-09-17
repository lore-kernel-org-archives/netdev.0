From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: Possible regression with skb_clone() in 2.6.36
Date: Fri, 17 Sep 2010 15:34:40 -0700
Message-ID: <20100917153440.474b93e4.akpm@linux-foundation.org>
References: <1283209824-8795-1-git-send-email-padovan@profusion.mobi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org
To: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1283209824-8795-1-git-send-email-padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 30 Aug 2010 20:10:23 -0300
"Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org> wrote:

> I've been experiencing some problems when running the L2CAP Streaming mode in
> 2.6.36. The system quickly runs in an Out Of Memory condition and crash. That
> wasn't happening before, so I think we may have a regression here (I didn't find
> where yet). The crash log is below.

So 2.6.35 was OK?

> The following patch does not fix the regression, but shows that removing the
> skb_clone() call from l2cap_streaming_send() makes the problem goes away. The
> patch is good anyway since it saves memory and time when sending Streaming mode
> packets.

How does "make it go away" differ from "fix the regression" :)

But yes, if we don't understand the source of the bug then it may well
still be there.  Did you make any progress in understanding the cause?

> 
> [ 5066.137533] Bluetooth: L2CAP ver 2.15
> [ 5066.137873] Bluetooth: L2CAP socket layer initialized
> [ 5066.545179] Bluetooth: RFCOMM TTY layer initialized
> [ 5066.545879] Bluetooth: RFCOMM socket layer initialized
> [ 5066.546582] Bluetooth: RFCOMM ver 1.11
> [ 5092.268021] l2test invoked oom-killer: gfp_mask=0x4d0, order=0, oom_adj=0, oom_score_adj=0
> [ 5092.268872] Pid: 3897, comm: l2test Not tainted 2.6.36-rc3 #5
> [ 5092.269863] Call Trace:
> [ 5092.270265]  [<ffffffff8138b6a6>] ? _raw_spin_unlock+0x26/0x30
> [ 5092.270878]  [<ffffffff810c0827>] T.427+0x77/0x1e0
> [ 5092.271874]  [<ffffffff811b85e7>] ? security_real_capable_noaudit+0x37/0x60
> [ 5092.272956]  [<ffffffff810c0e3a>] out_of_memory+0x2ca/0x2f0
> [ 5092.273894]  [<ffffffff810c3d43>] __alloc_pages_nodemask+0x693/0x6b0
> [ 5092.274871]  [<ffffffff810ea3e6>] cache_alloc_refill+0x2d6/0x5c0
> [ 5092.275864]  [<ffffffff810ea805>] __kmalloc+0x135/0x150
> [ 5092.276876]  [<ffffffff8130f2ae>] __alloc_skb+0x6e/0x150
> [ 5092.277865]  [<ffffffff810d3a00>] ? might_fault+0x40/0x90
> [ 5092.278652]  [<ffffffff8130ace2>] sock_alloc_send_pskb+0x1c2/0x320
> [ 5092.278927]  [<ffffffff810d3a00>] ? might_fault+0x40/0x90
> [ 5092.279864]  [<ffffffff81312add>] ? memcpy_fromiovec+0x6d/0x90
> [ 5092.280864]  [<ffffffff8130ae50>] sock_alloc_send_skb+0x10/0x20
> [ 5092.281867]  [<ffffffffa00e600f>] l2cap_create_iframe_pdu+0x9f/0x2c0 [l2cap]
> [ 5092.282865]  [<ffffffffa00e84b9>] l2cap_sock_sendmsg+0x5d9/0x910 [l2cap]
> [ 5092.283932]  [<ffffffff8138ba3c>] ? restore_args+0x0/0x30
> [ 5092.284865]  [<ffffffff8130725b>] sock_sendmsg+0xdb/0x100
> [ 5092.285652]  [<ffffffff8138ba3c>] ? restore_args+0x0/0x30
> [ 5092.285864]  [<ffffffff8138ba3c>] ? restore_args+0x0/0x30
> [ 5092.286864]  [<ffffffff813073c0>] sys_sendto+0xf0/0x130
> [ 5092.287864]  [<ffffffff8138b60b>] ? _raw_spin_unlock_irq+0x2b/0x40
> [ 5092.288872]  [<ffffffff81093cfd>] ? trace_hardirqs_on_caller+0x13d/0x180
> [ 5092.289927]  [<ffffffff81093d4d>] ? trace_hardirqs_on+0xd/0x10
> [ 5092.290864]  [<ffffffff810d3a00>] ? might_fault+0x40/0x90
> [ 5092.291649]  [<ffffffff810d3a00>] ? might_fault+0x40/0x90
> [ 5092.291864]  [<ffffffff810d3a00>] ? might_fault+0x40/0x90
> [ 5092.292864]  [<ffffffff8130740f>] sys_send+0xf/0x20
> [ 5092.293870]  [<ffffffff8132ccd6>] compat_sys_socketcall+0x146/0x1f0
> [ 5092.294875]  [<ffffffff81053ee4>] sysenter_dispatch+0x7/0x30

That's a pretty serious regression.
