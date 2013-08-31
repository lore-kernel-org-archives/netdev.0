From: dormando <dormando@rydia.net>
Subject: Re: ipv4: warnings on sk_wmem_queued
Date: Sat, 31 Aug 2013 12:38:01 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1308311229280.3532@dtop>
References: <20130830195638.GA27393@dcvr.yhbt.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Wong <normalperson@yhbt.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130830195638.GA27393@dcvr.yhbt.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I noticed these warnings on stock 3.10.9 running stress tests on
> cmogstored.git (git://bogomips.org/cmogstored.git) doing standard
> HTTP server stuff between lo and tmpfs:
>
[...]
> I was going to reboot into 3.10.10 before I looked at dmesg.  These
> warnings happened after ~8 hours of stress tests, and those stress tests
> are still running.

I had a kernel panic this morning on a production machine, also running
3.10.9. I only got a small part of the end of the trace, but it matches:

> Aug 30 06:03:54 localhost kernel: [<ffffffff813c0073>] ip_queue_xmit+0x153/0x3c0
> Aug 30 06:03:54 localhost kernel: [<ffffffff813d6c25>] tcp_transmit_skb+0x3c5/0x820
> Aug 30 06:03:54 localhost kernel: [<ffffffff813d72c1>] tcp_write_xmit+0x191/0xaa0
> Aug 30 06:03:54 localhost kernel: [<ffffffff8138434c>] ? __kmalloc_reserve.isra.49+0x3c/0xa0
> Aug 30 06:03:54 localhost kernel: [<ffffffff813d7c42>] __tcp_push_pending_frames+0x32/0xa0
> Aug 30 06:03:54 localhost kernel: [<ffffffff813d8a8f>] tcp_send_fin+0x6f/0x190
> Aug 30 06:03:54 localhost kernel: [<ffffffff813cc508>] tcp_close+0x378/0x410
> Aug 30 06:03:54 localhost kernel: [<ffffffff813efe5a>] inet_release+0x5a/0xa0
> Aug 30 06:03:54 localhost kernel: [<ffffffff8137a218>] sock_release+0x28/0x90
> Aug 30 06:03:54 localhost kernel: [<ffffffff8137a5c2>] sock_close+0x12/0x20
> Aug 30 06:03:54 localhost kernel: [<ffffffff81123def>] __fput+0xaf/0x240
> Aug 30 06:03:54 localhost kernel: [<ffffffff8112403e>] ____fput+0xe/0x10
> Aug 30 06:03:54 localhost kernel: [<ffffffff81054d47>] task_work_run+0xa7/0xe0
> Aug 30 06:03:54 localhost kernel: [<ffffffff8100209c>] do_notify_resume+0x9c/0xb0
> Aug 30 06:03:54 localhost kernel: [<ffffffff81430788>] int_signal+0x12/0x17

... from there to here...

Then:
RIP  [<ffffffff8113c42a> kmem_cache_alloc+0x5a/0x130
 RSP <ffff881fffca3958>
---[ end trace 6ab931f3db28b31e ]---
Kernel panic - not syncing: Fatal exception in interrupt

Machine was running for a few days before panic'ing. I don't see anything
in 3.10.10 that would've affected this.

Thanks!

(also: hi Eric!)
