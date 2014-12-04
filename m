From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: 3.12.33 - BUG xfrm_selector_match+0x25/0x2f6
Date: Thu, 04 Dec 2014 10:44:52 +0100
Message-ID: <54802D14.9030509@suse.cz>
References: <547F2462.6040405@smart-weblications.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
To: f.wiessner@smart-weblications.de, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <547F2462.6040405@smart-weblications.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/03/2014, 03:55 PM, Smart Weblications GmbH - Florian Wiessner wrote:
> [16623.095403] BUG: unable to handle kernel paging request at 00000000010600d0
> [16623.095445] IP: [<ffffffff81547767>] xfrm_selector_match+0x25/0x2f6
> [16623.095480] PGD aeaea067 PUD 85d95067 PMD 0
> [16623.095513] Oops: 0000 [#1] SMP
> [16623.095543] Modules linked in: netconsole xt_nat xt_multiport veth ip_vs_rr
...
> [16623.096062] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.12.33 #1
> [16623.096091] Hardware name: Supermicro X9SCI/X9SCA/X9SCI/X9SCA, BIOS 1.1a
> 09/28/2011
> [16623.096137] task: ffffffff81804450 ti: ffffffff817f4000 task.ti: ffffffff817f4000
> [16623.096182] RIP: 0010:[<ffffffff81547767>]  [<ffffffff81547767>]
> xfrm_selector_match+0x25/0x2f6
> [16623.096233] RSP: 0018:ffff88083fc03900  EFLAGS: 00010246
> [16623.096261] RAX: 0000000000000001 RBX: ffff88083fc03a20 RCX: ffff880787fb1200
> [16623.096292] RDX: 0000000000000002 RSI: ffff88083fc03a20 RDI: 00000000010600a6
> [16623.096323] RBP: 00000000010600a6 R08: 0000000000000000 R09: ffff88083fc039a0
> [16623.096353] R10: 0000000000000000 R11: 0000000000000001 R12: ffff88083fc03a20
> [16623.096383] R13: 0000000000000001 R14: ffffffff818a9700 R15: ffffffffa01c73e0
> [16623.096414] FS:  0000000000000000(0000) GS:ffff88083fc00000(0000)
> knlGS:0000000000000000
> [16623.096469] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [16623.096498] CR2: 00000000010600d0 CR3: 0000000085f0b000 CR4: 00000000000407f0
> [16623.096528] Stack:
> [16623.096550]  0000000000000000 0000000001060002 ffff880787fb1200 ffff88083fc03a20
> [16623.096602]  0000000000000001 ffffffff81547a7c 0000000000000000 ffff8800baad5480
> [16623.096655]  ffffffff81804450 ffffffff818a9700 000000003c9041bc ffffffff81547ef7
> [16623.096721] Call Trace:
> [16623.096744]  <IRQ>
> [16623.096749]  [<ffffffff81547a7c>] ? xfrm_sk_policy_lookup+0x44/0x9b
> [16623.096802]  [<ffffffff81547ef7>] ? xfrm_lookup+0x91/0x446
> [16623.096832]  [<ffffffff81541316>] ? ip_route_me_harder+0x150/0x1b0
> [16623.096865]  [<ffffffffa01b6457>] ? ip_vs_route_me_harder+0x86/0x91 [ip_vs]
> [16623.096899]  [<ffffffffa01b797a>] ? ip_vs_out+0x2d3/0x5bc [ip_vs]
> [16623.096930]  [<ffffffff81501420>] ? ip_rcv_finish+0x2b8/0x2b8
> [16623.096959]  [<ffffffff814fc2d3>] ? nf_iterate+0x42/0x80
> [16623.096989]  [<ffffffff814fc37a>] ? nf_hook_slow+0x69/0xff
> [16623.097017]  [<ffffffff81501420>] ? ip_rcv_finish+0x2b8/0x2b8
> [16623.097047]  [<ffffffff81501744>] ? ip_local_deliver+0x6f/0x7e
> [16623.097078]  [<ffffffff814d82a6>] ? __netif_receive_skb_core+0x5f0/0x66c
> [16623.097108]  [<ffffffff814d84b7>] ? process_backlog+0x13e/0x13e
> [16623.097140]  [<ffffffffa04b4e09>] ? br_handle_frame_finish+0x382/0x382 [bridge]
> [16623.097187]  [<ffffffff814d8503>] ? netif_receive_skb+0x4c/0x7d
> [16623.097218]  [<ffffffffa04b4d95>] ? br_handle_frame_finish+0x30e/0x382 [bridge]
> [16623.097265]  [<ffffffffa04b4fda>] ? br_handle_frame+0x1d1/0x217 [bridge]
> [16623.097297]  [<ffffffffa048e4aa>] ? bond_handle_frame+0x86/0x1bd [bonding]
> [16623.097328]  [<ffffffff814d8155>] ? __netif_receive_skb_core+0x49f/0x66c
> [16623.097358]  [<ffffffff814d8503>] ? netif_receive_skb+0x4c/0x7d
> [16623.097388]  [<ffffffff814d9091>] ? napi_gro_receive+0x35/0x76
> [16623.097418]  [<ffffffff813eae17>] ? e1000_clean_rx_irq+0x26d/0x2f5
> [16623.097448]  [<ffffffff813ef48e>] ? e1000e_poll+0x65/0x23d
> [16623.097477]  [<ffffffff814d8709>] ? net_rx_action+0xa2/0x1c0
...
> This happens again and again with 3.12.33
> 
> 
> see also: http://www.spinics.net/lists/netdev/msg306283.html
> 
> is this already fixed somehow?

Hi, I doubt so, as you are the first one letting me know. Could you
check whether 3.12.30 works OK for you?

thanks,
-- 
js
suse labs
