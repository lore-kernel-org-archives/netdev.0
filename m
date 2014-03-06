From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: use raw_cpu ops in snmp stats bh
Date: Thu, 06 Mar 2014 06:44:34 -0800
Message-ID: <1394117074.27473.29.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1394110536-4532-1-git-send-email-sergey.senozhatsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394110536-4532-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-03-06 at 15:55 +0300, Sergey Senozhatsky wrote:
> Commit a25982c15ae52 ("percpu: add preemption checks to __this_cpu
> ops") added preemption checks to __this_cpu ops, which are used in
> SNMP_INC_STATS_BH() and SNMP_ADD_STATS_BH(), resulting in following
> warnings:
> 
> BUG: using __this_cpu_add() in preemptible [00000000] code: ssh/4661
> caller is __this_cpu_preempt_check+0x2b/0x2d
> CPU: 3 PID: 4661 Comm: ssh Not tainted 3.14.0-rc5-next-20140306-dbg-dirty #162
> Hardware name: Acer             Aspire 5741G    /Aspire 5741G    , BIOS V1.20 02/08/2011
>  0000000000000000 ffff880094939be0 ffffffff813b8305 0000000000000003
>  ffff880094939c00 ffffffff8121221f ffff88015130a8c0 0000000000000000
>  ffff880094939c38 ffffffff8121226b 635f736968745f5f 29286464615f7570
> Call Trace:
>  [<ffffffff813b8305>] dump_stack+0x4e/0x7a
>  [<ffffffff8121221f>] check_preemption_disabled+0xce/0xdd
>  [<ffffffff8121226b>] __this_cpu_preempt_check+0x2b/0x2d
>  [<ffffffff81370b5a>] ? tcp_rearm_rto+0x9f/0xa1
>  [<ffffffff81373456>] tcp_event_new_data_sent+0x6d/0x91
>  [<ffffffff81374dc6>] tcp_write_xmit+0x3f1/0x935
>  [<ffffffff813754e4>] __tcp_push_pending_frames+0x28/0x82
>  [<ffffffff81368109>] tcp_push+0xcc/0x102
>  [<ffffffff8136a0c1>] tcp_sendmsg+0x8c5/0xb7a
>  [<ffffffff81207d59>] ? string.isra.6+0x3b/0x9f
>  [<ffffffff8138a10a>] inet_sendmsg+0x75/0xa0
>  [<ffffffff81320fb6>] sock_aio_write+0xe7/0xfe
>  [<ffffffff81207d59>] ? string.isra.6+0x3b/0x9f
>  [<ffffffff810e08ab>] do_sync_write+0x54/0x73
>  [<ffffffff810e0df7>] vfs_write+0xc6/0x17c
>  [<ffffffff810e1603>] SyS_write+0x44/0x78
>  [<ffffffff813be0a1>] tracesys+0xd4/0xd9
> 
> use raw_cpu_inc() and raw_cpu_add() instead of __this_cpu_inc()
> and __this_cpu_add().
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> ---
>  include/net/snmp.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

I think you missed a lot of mails sent by Chrisoph Lameter recently...
