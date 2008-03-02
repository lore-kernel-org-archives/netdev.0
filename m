From: Chris Wedgwood <cw@f00f.org>
Subject: Re: 2.6.25-rc3ish TCP assertion & WARN_ON
Date: Sun, 2 Mar 2008 09:50:13 -0800
Message-ID: <20080302175013.GA4483@puku.stupidest.org>
References: <20080301183234.GA4707@puku.stupidest.org> <Pine.LNX.4.64.0803012213190.350@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp120.sbc.mail.sp1.yahoo.com ([69.147.64.93]:46760 "HELO
	smtp120.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754827AbYCBRuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2008 12:50:20 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803012213190.350@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 01, 2008 at 10:19:07PM +0200, Ilpo J?rvinen wrote:

> It consumes some cpu by validating the whole TCP's write queue
> multiple times per ACK to find most of the errors as soon as they
> happen rather than when some cheap mainline trap triggers (often
> much later than the actual bug).

With that:

  [ 1911.211964] P: 0 L: 0 vs 0 S: 0 vs 0 F: 0 vs 2 w: 2569814359-2569814359 (3)
  [ 1911.211981] l0 s0 f2 p0 seq: su2569814359 hs2569814359 sn2569814359
  [ 1911.211995] ------------[ cut here ]------------
  [ 1911.212005] WARNING: at net/ipv4/tcp_ipv4.c:234 tcp_verify_wq+0x23d/0x271()
  [ 1911.212022] Modules linked in: kvm_amd kvm tun firewire_ohci firewire_core crc_itu_t
  [ 1911.212046] Pid: 0, comm: swapper Not tainted 2.6.25-rc3-cw3-01124-g4b36a25-dirty #8
  [ 1911.212062]
  [ 1911.212063] Call Trace:
  [ 1911.212076]  <IRQ>  [<ffffffff80231aeb>] warn_on_slowpath+0x58/0x6b
  [ 1911.212093]  [<ffffffff80232912>] ? printk+0x67/0x69
  [ 1911.212103]  [<ffffffff804d26c6>] ? tcp_print_queue+0x21b/0x22d
  [ 1911.212115]  [<ffffffff8053caeb>] ? _spin_unlock_bh+0x2f/0x34
  [ 1911.212127]  [<ffffffff804d2ec0>] tcp_verify_wq+0x23d/0x271
  [ 1911.212140]  [<ffffffff804c92db>] tcp_ack+0x749/0xfab
  [ 1911.212152]  [<ffffffff8053f369>] ? __atomic_notifier_call_chain+0x74/0x83
  [ 1911.212165]  [<ffffffff804cc13c>] tcp_rcv_state_process+0x731/0xb2d
  [ 1911.212177]  [<ffffffff804d2458>] tcp_v4_do_rcv+0x167/0x1ba
  [ 1911.212188]  [<ffffffff804d4543>] tcp_v4_rcv+0x701/0x75e
  [ 1911.212199]  [<ffffffff804b9684>] ip_local_deliver_finish+0x158/0x230
  [ 1911.212211]  [<ffffffff804b9b6d>] ip_local_deliver+0x72/0x7d
  [ 1911.212222]  [<ffffffff804b9507>] ip_rcv_finish+0x353/0x378
  [ 1911.212233]  [<ffffffff804b9ac8>] ip_rcv+0x272/0x2a5
  [ 1911.212249]  [<ffffffff80492f57>] netif_receive_skb+0x26c/0x2b9
  [ 1911.212261]  [<ffffffff8049575c>] process_backlog+0x82/0xe7
  [ 1911.212273]  [<ffffffff80495207>] net_rx_action+0x87/0x14e
  [ 1911.212285]  [<ffffffff80236d07>] __do_softirq+0x66/0xd3
  [ 1911.212297]  [<ffffffff8020c45c>] call_softirq+0x1c/0x28
  [ 1911.212308]  [<ffffffff8020dd03>] do_softirq+0x34/0x72
  [ 1911.212319]  [<ffffffff80236c9f>] irq_exit+0x3f/0x41
  [ 1911.212329]  [<ffffffff8020deb2>] do_IRQ+0x147/0x169
  [ 1911.212340]  [<ffffffff8020a225>] ? default_idle+0x0/0x5f
  [ 1911.212351]  [<ffffffff8020b7a1>] ret_from_intr+0x0/0xa
  [ 1911.212360]  <EOI>  [<ffffffff8053f2f5>] ? __atomic_notifier_call_chain+0x0/0x83
  [ 1911.212379]  [<ffffffff8020a25e>] ? default_idle+0x39/0x5f
  [ 1911.212390]  [<ffffffff8020a259>] ? default_idle+0x34/0x5f
  [ 1911.212401]  [<ffffffff8020a225>] ? default_idle+0x0/0x5f
  [ 1911.212411]  [<ffffffff8020a31c>] ? cpu_idle+0x98/0xba
  [ 1911.212423]  [<ffffffff805277d1>] ? rest_init+0x55/0x57
  [ 1911.212434]
  [ 1911.212440] ---[ end trace 9f6658e64a24d34b ]---

Is that useful?
