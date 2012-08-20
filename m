From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 46131] New: 32-bit read from uninitialized memory in
 __ip_select_ident since 3.6-rc2
Date: Mon, 20 Aug 2012 18:24:26 +0200
Message-ID: <1345479866.5158.324.camel@edumazet-glaptop>
References: <20120820090313.4856779b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, casteyde.christian@free.fr
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33899 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443Ab2HTQYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 12:24:31 -0400
Received: by bkwj10 with SMTP id j10so1917413bkw.19
        for <netdev@vger.kernel.org>; Mon, 20 Aug 2012 09:24:30 -0700 (PDT)
In-Reply-To: <20120820090313.4856779b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-20 at 09:03 -0700, Stephen Hemminger wrote:
> 
> Begin forwarded message:
> 
> Date: Sat, 18 Aug 2012 09:49:45 +0000 (UTC)
> From: bugzilla-daemon@bugzilla.kernel.org
> To: shemminger@linux-foundation.org
> Subject: [Bug 46131] New: 32-bit read from uninitialized memory in __ip_select_ident since 3.6-rc2
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=46131
> 
>            Summary: 32-bit read from uninitialized memory in
>                     __ip_select_ident since 3.6-rc2
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 3.6-rc2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: casteyde.christian@free.fr
>         Regression: Yes
> 
> 
> Slacware64 current
> Intel Core i7
> 6GB RAM
> 
> Since 3.6-rc2 (this is a regression from 3.6-rc1), I get the following warning
> when I ping a host:
> 
> WARNING: kmemcheck: Caught 32-bit read from uninitialized memory
> (ffff8801c3f79460)
> 00000000030380ab00000000450000482881000080118ebbc0a8010bc0a8010d
>  u u u u i i i i i i i i i i i i i i i i i i i i i i i i i i i i
>  ^
> Pid: 5836, comm: udev-acl.ck Not tainted 3.6.0-rc2 #3 Acer Aspire 7750G/JE70_HR
> RIP: 0010:[<ffffffff81697ed2>]  [<ffffffff81697ed2>]
> __ip_select_ident+0x22/0x120
> RSP: 0000:ffff8801c7e035e0  EFLAGS: 00010282
> RAX: ffff88018194ab00 RBX: ffff88018b454700 RCX: 0000000000000040
> RDX: 0000000000000001 RSI: ffff8801c7e035ec RDI: ffff8801c3f79450
> RBP: ffff8801c7e03620 R08: ffff8801c54a8238 R09: 0000000000000000
> R10: ffff8801c7e03770 R11: 0000000000000050 R12: ffff8801c3f79450
> R13: 0000000000000000 R14: ffff88018db74a80 R15: ffff8801c3f79450
> FS:  00007f0692dfb740(0000) GS:ffff8801c7e00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: ffff8801c6b06a88 CR3: 00000001a9ae5000 CR4: 00000000000407f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff4ff0 DR7: 0000000000000400
>  [<ffffffff816a2aa8>] __ip_make_skb+0x2f8/0x3c0
>  [<ffffffff816a2bd7>] ip_push_pending_frames+0x17/0x30
>  [<ffffffff816d16be>] icmp_push_reply+0xee/0x120
>  [<ffffffff816d1b95>] icmp_send+0x4a5/0xb10
>  [<ffffffff816ce5b8>] __udp4_lib_rcv+0x568/0x920
>  [<ffffffff816ce985>] udp_rcv+0x15/0x20
>  [<ffffffff8169b0d7>] ip_local_deliver_finish+0x107/0x460
>  [<ffffffff8169b6f8>] ip_local_deliver+0x88/0x90
>  [<ffffffff8169ab10>] ip_rcv_finish+0x120/0x5e0
>  [<ffffffff8169b919>] ip_rcv+0x219/0x2b0
>  [<ffffffff8164de82>] __netif_receive_skb+0x742/0x9b0
>  [<ffffffff8164ef68>] netif_receive_skb+0x28/0x1e0
>  [<ffffffff817a2de5>] ieee80211_deliver_skb.isra.28+0xa5/0x220
>  [<ffffffff817a3e87>] ieee80211_rx_handlers+0xf27/0x2380
>  [<ffffffff817a55e7>] ieee80211_prepare_and_rx_handle+0x307/0x8b0
>  [<ffffffff817a620e>] ieee80211_rx+0x67e/0xce0
>  [<ffffffff814b819c>] ath_rx_tasklet+0xc9c/0x1350
>  [<ffffffff814b6024>] ath9k_tasklet+0xe4/0x140
>  [<ffffffff810784ec>] tasklet_action+0x6c/0xe0
>  [<ffffffff81078e5a>] __do_softirq+0xba/0x180
>  [<ffffffff817e32dc>] call_softirq+0x1c/0x30
>  [<ffffffff8103a4ed>] do_softirq+0x7d/0xb0
>  [<ffffffff81079276>] irq_exit+0x96/0xc0
>  [<ffffffff81039f8e>] do_IRQ+0x5e/0xd0
>  [<ffffffff817e18ac>] ret_from_intr+0x0/0x13
>  [<ffffffffffffffff>] 0xffffffffffffffff

Thanks for the report, I am testing a patch.
