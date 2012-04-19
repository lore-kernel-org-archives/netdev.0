From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] drop_monitor: allow more events per second
Date: Thu, 19 Apr 2012 23:25:33 +0200
Message-ID: <1334870733.4810.0.camel@edumazet-laptop>
References: <1334855781.2395.203.camel@edumazet-glaptop>
	 <20120419172844.GC18339@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:50706 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933192Ab2DSVZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 17:25:38 -0400
Received: by wibhq7 with SMTP id hq7so44197wib.1
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 14:25:36 -0700 (PDT)
In-Reply-To: <20120419172844.GC18339@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 19 avril 2012 =C3=A0 13:28 -0400, Neil Horman a =C3=A9crit :

> I spent a good deal of time going through it to make sure it was pree=
mpt safe,
> but its certainly possible that I missed something.  I'll look at it =
shortly.
> Thanks for this update though
>=20

You might want to check this problem as well :

[   38.352571] BUG: sleeping function called from invalid context at ke=
rnel/mutex.c:85
[   38.352576] in_atomic(): 1, irqs_disabled(): 0, pid: 4415, name: dro=
pwatch
[   38.352580] Pid: 4415, comm: dropwatch Not tainted 3.4.0-rc2+ #71
[   38.352582] Call Trace:
[   38.352592]  [<ffffffff8153aaf0>] ? trace_napi_poll_hit+0xd0/0xd0
[   38.352599]  [<ffffffff81063f2a>] __might_sleep+0xca/0xf0
[   38.352606]  [<ffffffff81655b16>] mutex_lock+0x26/0x50
[   38.352610]  [<ffffffff8153aaf0>] ? trace_napi_poll_hit+0xd0/0xd0
[   38.352616]  [<ffffffff810b72d9>] tracepoint_probe_register+0x29/0x9=
0
[   38.352621]  [<ffffffff8153a585>] set_all_monitor_traces+0x105/0x170
[   38.352625]  [<ffffffff8153a8ca>] net_dm_cmd_trace+0x2a/0x40
[   38.352630]  [<ffffffff8154a81a>] genl_rcv_msg+0x21a/0x2b0
[   38.352636]  [<ffffffff810f8029>] ? zone_statistics+0x99/0xc0
[   38.352640]  [<ffffffff8154a600>] ? genl_rcv+0x30/0x30
[   38.352645]  [<ffffffff8154a059>] netlink_rcv_skb+0xa9/0xd0
[   38.352649]  [<ffffffff8154a5f0>] genl_rcv+0x20/0x30
[   38.352653]  [<ffffffff81549a7e>] netlink_unicast+0x1ae/0x1f0
[   38.352658]  [<ffffffff81549d76>] netlink_sendmsg+0x2b6/0x310
[   38.352663]  [<ffffffff8150824f>] sock_sendmsg+0x10f/0x130
[   38.352668]  [<ffffffff8150abe0>] ? move_addr_to_kernel+0x60/0xb0
[   38.352673]  [<ffffffff81515f04>] ? verify_iovec+0x64/0xe0
[   38.352677]  [<ffffffff81509c46>] __sys_sendmsg+0x386/0x390
[   38.352682]  [<ffffffff810ffaf9>] ? handle_mm_fault+0x139/0x210
[   38.352687]  [<ffffffff8165b5bc>] ? do_page_fault+0x1ec/0x4f0
[   38.352693]  [<ffffffff8106ba4d>] ? set_next_entity+0x9d/0xb0
[   38.352699]  [<ffffffff81310b49>] ? tty_ldisc_deref+0x9/0x10
[   38.352703]  [<ffffffff8106d363>] ? pick_next_task_fair+0x63/0x140
[   38.352708]  [<ffffffff8150b8d4>] sys_sendmsg+0x44/0x80
[   38.352713]  [<ffffffff8165f8e2>] system_call_fastpath+0x16/0x1b
