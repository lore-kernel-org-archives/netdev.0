From: Bernard Pidoux F6BVP <f6bvp@free.fr>
Subject: Re: [AX25] kernel panic
Date: Wed, 19 Mar 2008 08:36:01 +0100
Message-ID: <47E0C261.3000106@free.fr>
References: <47DF9D21.20807@free.fr> <20080318212531.GA2031@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postfix1-g20.free.fr ([212.27.60.42]:47564 "EHLO
	postfix1-g20.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753270AbYCSTZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 15:25:04 -0400
Received: from smtp5-g19.free.fr (smtp5-g19.free.fr [212.27.42.35])
	by postfix1-g20.free.fr (Postfix) with ESMTP id BCA892411A7E
	for <netdev@vger.kernel.org>; Wed, 19 Mar 2008 08:38:08 +0100 (CET)
In-Reply-To: <20080318212531.GA2031@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Francois Romieu wrote:
> Bernard Pidoux F6BVP <f6bvp@free.fr> :
> [...]
>> I used netconsole to document a kernel panic related to AX25 on one of my 
>> systems.
>> This occurs systematically as soon as I close an AX25 session established 
>> through a level 3 ROSE network (FPAC) via AXUDP link (ax25ipd).
>> It is not triggered when connecting locally or via AX25 call through LAN.
> 
> May be replacing netif_rx() in drivers/net/hamradio/mkiss.c::ax_bump()
> by netif_receive_skb() ?
> 

Sorry, this does not made it.
I replaced netif_rx() by netif_receive_skb(skb)
but this gives a worst situation : system is frozen.
Thank you for the suggestion.

  =======================
BUG: soft lockup - CPU#0 stuck for 11s! [ax25ipd:3584]

Pid: 3584, comm: ax25ipd Not tainted (2.6.24.3 #7)
EIP: 0060:[<c01ed892>] EFLAGS: 00000246 CPU: 0
EIP is at delay_tsc+0x12/0x20
EAX: 7752234b EBX: 00000001 ECX: 7752234b EDX: 00000016
ESI: 087022c8 EDI: 00000000 EBP: c6bb5bc0 ESP: c6bb5bbc
  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
CR0: 8005003b CR2: b7dd86f8 CR3: 07960000 CR4: 000000d0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff0ff0 DR7: 00000400
  [<c010535a>] show_trace_log_lvl+0x1a/0x30
  [<c0105d82>] show_trace+0x12/0x20
  [<c01024cc>] show_regs+0x1c/0x20
  [<c015555b>] softlockup_tick+0x11b/0x150
  [<c0126c12>] run_local_timers+0x12/0x20
  [<c012708f>] update_process_times+0x2f/0x60
  [<c013a355>] tick_periodic+0x25/0x80
  [<c013a3c9>] tick_handle_periodic+0x19/0x80
  [<c0107aca>] timer_interrupt+0x4a/0x60
  [<c0155928>] handle_IRQ_event+0x28/0x60
  [<c015725f>] handle_level_irq+0x7f/0xf0
  [<c0106e68>] do_IRQ+0x48/0xa0
  [<c0104d16>] common_interrupt+0x2e/0x34
  [<c01ed839>] __delay+0x9/0x10
  [<c01f15f2>] _raw_spin_lock+0xb2/0x140
  [<c02cd350>] _spin_lock_bh+0x50/0x60
  [<c8c59e72>] ax_xmit+0x112/0x370 [mkiss]
  [<c025e947>] dev_hard_start_xmit+0x207/0x270
  [<c026f454>] __qdisc_run+0x54/0x1b0
  [<c0261226>] dev_queue_xmit+0x266/0x340
  [<c8c27a87>] ax25_queue_xmit+0x47/0x70 [ax25]
  [<c8c27b77>] ax25_transmit_buffer+0xc7/0x110 [ax25]
  [<c8c27c3d>] ax25_send_iframe+0x7d/0x110 [ax25]
  [<c8c27d80>] ax25_kick+0xb0/0x1b0 [ax25]
  [<c8c28e49>] ax25_std_frame_in+0x69/0x890 [ax25]
  [<c8c26dbb>] ax25_kiss_rcv+0x2bb/0x7c0 [ax25]
  [<c025e24a>] netif_receive_skb+0x38a/0x480
  [<c8c596ab>] mkiss_receive_buf+0x34b/0x420 [mkiss]
  [<c0219457>] pty_write+0x47/0x60
  [<c0216a19>] write_chan+0x229/0x330
  [<c021407b>] tty_write+0x12b/0x1c0
  [<c017b66f>] vfs_write+0xaf/0x120
  [<c017bcbd>] sys_write+0x3d/0x70
  [<c010427e>] sysenter_past_esp+0x5f/0xa5
  =======================

Regards,

Bernard Pidoux
