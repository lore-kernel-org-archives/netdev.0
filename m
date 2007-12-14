From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: kernel 2.6.23.8: KERNEL: assertion in net/ipv4/tcp_input.c
Date: Fri, 14 Dec 2007 22:51:02 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712142240220.1400@kivilampi-30.cs.helsinki.fi>
References: <200712030100.26283.wolfgang.walter@studentenwerk.mhn.de>
 <Pine.LNX.4.64.0712030840540.26423@kivilampi-30.cs.helsinki.fi>
 <200712131751.15578.wolfgang.walter@studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34773 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751876AbXLNUvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 15:51:04 -0500
In-Reply-To: <200712131751.15578.wolfgang.walter@studentenwerk.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Dec 2007, Wolfgang Walter wrote:

> it happened again with your patch applied:
> 
> WARNING: at net/ipv4/tcp_input.c:1018 tcp_sacktag_write_queue()
> 
> Call Trace:
> <IRQ>  [<ffffffff80549290>] tcp_sacktag_write_queue+0x7d0/0xa60
> [<ffffffff80283869>] add_partial+0x19/0x60
> [<ffffffff80549ac4>] tcp_ack+0x5a4/0x1d70
> [<ffffffff8054e625>] tcp_rcv_established+0x485/0x7b0
> [<ffffffff80554c3d>] tcp_v4_do_rcv+0xed/0x3e0
> [<ffffffff80556fe7>] tcp_v4_rcv+0x947/0x970
> [<ffffffff80538c6c>] ip_local_deliver+0xac/0x290
> [<ffffffff80538862>] ip_rcv+0x362/0x6c0
> [<ffffffff804fc5d3>] netif_receive_skb+0x323/0x420
> [<ffffffff8042ab40>] tg3_poll+0x630/0xa50
> [<ffffffff804fecba>] net_rx_action+0x8a/0x140
> [<ffffffff8023a269>] __do_softirq+0x69/0xe0
> [<ffffffff8020d47c>] call_softirq+0x1c/0x30
> [<ffffffff8020f315>] do_softirq+0x35/0x90
> [<ffffffff8023a105>] irq_exit+0x55/0x60
> [<ffffffff8020f3f0>] do_IRQ+0x80/0x100
> [<ffffffff8020c7d1>] ret_from_intr+0x0/0xa
> <EOI>

...Yeah, as I suspected, left_out != 0 when sacked_out and lost_out are 
zero. I'll try to read the code again to see how that could happen (in 
any case this is just annoying at the best, no other harm but the 
message is being done). ...If nothing comes up I might ask you to run
with another test patch but it might take week or so until I've enough
time to dig into this fully because I must also come familiar with 
something as pre-historic as the 2.6.23 (there are already large number
of related changes since then, both in upcoming 2.6.24 and some in 
net-2.6.25)... :-)

> > Any tweaking done to TCP related sysctls?
> 
> net/core/somaxconn=2048
> net/ipv4/tcp_syncookies=1
> net/ipv4/tcp_max_syn_backlog=8192
> net/ipv4/tcp_max_tw_buckets=1800000
> net/ipv4/tcp_window_scaling=0
> net/ipv4/tcp_timestamps=0

Thanks, these won't be that significant, though timestamps will exclude 
some possibilities :-).


-- 
 i.
