From: Yuchung Cheng <ycheng@google.com>
Subject: Re: 3.10.0 network trace
Date: Fri, 12 Jul 2013 14:18:39 -0700
Message-ID: <CAK6E8=eNa72=LySKsgpnKd5A6CSkr0pbpet1X2g8em9Or=m7bg@mail.gmail.com>
References: <CA+rTEUPfP8ouJHbaFrO=-zktg2D06kYgXOq-LnmyKbbEzj-TmA@mail.gmail.com>
 <CA+rTEUMYihwm_5ado5q1ZrYovgM6=Yc99mSaO-dNUyj4XyTj_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Michael Sterrett <michael@sterretts.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:56997 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757582Ab3GLVTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 17:19:03 -0400
Received: by mail-lb0-f176.google.com with SMTP id z5so7856612lbh.7
        for <netdev@vger.kernel.org>; Fri, 12 Jul 2013 14:19:00 -0700 (PDT)
In-Reply-To: <CA+rTEUMYihwm_5ado5q1ZrYovgM6=Yc99mSaO-dNUyj4XyTj_Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 12, 2013 at 1:44 PM, Michael Sterrett <michael@sterretts.net> wrote:
> Upgraded to 3.10.0 and started getting these appearing in the log:
>
> [21893.282786] ------------[ cut here ]------------
> [21893.282802] WARNING: at net/ipv4/tcp_input.c:2776
> tcp_fastretrans_alert+0xbac/0xbf0()
> [21893.282805] Modules linked in:
> [21893.282813] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.10.0 #1
> [21893.282816] Hardware name: ECS IC780M-A/IC780M-A, BIOS 080015  04/19/2010
> [21893.282819]  ffffffff815186b2 0000000000000000 ffffffff810317ec
> ffff88000a5ef500
> [21893.282825]  0000000000000000 0000000000000007 0000000000004120
> 0000000000000001
> [21893.282830]  ffffffff814647cc 0000000700000009 0000000000000000
> 2c81743c00000000
> [21893.282835] Call Trace:
> [21893.282838]  <IRQ>  [<ffffffff815186b2>] ? dump_stack+0xd/0x17
> [21893.282854]  [<ffffffff810317ec>] ? warn_slowpath_common+0x6c/0xa0
> [21893.282860]  [<ffffffff814647cc>] ? tcp_fastretrans_alert+0xbac/0xbf0
> [21893.282865]  [<ffffffff81465257>] ? tcp_ack+0x997/0xd60
> [21893.282872]  [<ffffffff81465aa1>] ? tcp_rcv_established+0xf1/0x640
> [21893.282878]  [<ffffffff8146eb9e>] ? tcp_v4_do_rcv+0x1fe/0x4b0
> [21893.282885]  [<ffffffff81434d9e>] ? nf_iterate+0x8e/0xc0
> [21893.282890]  [<ffffffff81003cfc>] ? do_IRQ+0x5c/0xd0
> [21893.282896]  [<ffffffff814711d7>] ? tcp_v4_rcv+0x757/0x780
> [21893.282901]  [<ffffffff81434e47>] ? nf_hook_slow+0x77/0x150
> [21893.282907]  [<ffffffff8144dfb0>] ? ip_rcv_finish+0x2a0/0x2a0
> [21893.282914]  [<ffffffff8144e057>] ? ip_local_deliver_finish+0xa7/0x1e0
> [21893.282921]  [<ffffffff8140c7cf>] ? __netif_receive_skb_core+0x49f/0x690
> [21893.282926]  [<ffffffff8140cbb4>] ? netif_receive_skb+0x24/0x80
> [21893.282931]  [<ffffffff8140e368>] ? napi_gro_receive+0xc8/0x100
> [21893.282937]  [<ffffffff812ffecc>] ? rtl8169_poll+0x2cc/0x600
> [21893.282942]  [<ffffffff8140ce29>] ? net_rx_action+0x79/0x130
> [21893.282948]  [<ffffffff810382e8>] ? __do_softirq+0xc8/0x1a0
> [21893.282953]  [<ffffffff81038516>] ? irq_exit+0x96/0xc0
> [21893.282957]  [<ffffffff81003cfc>] ? do_IRQ+0x5c/0xd0
> [21893.282963]  [<ffffffff8151caea>] ? common_interrupt+0x6a/0x6a
> [21893.282965]  <EOI>  [<ffffffff8100a0a0>] ?
> arch_remove_reservations+0x130/0x130
> [21893.282978]  [<ffffffff8100a0a2>] ? default_idle+0x2/0x10
> [21893.282983]  [<ffffffff810627f9>] ? cpu_startup_entry+0x79/0x160
> [21893.282989]  [<ffffffff81732d54>] ? start_kernel+0x325/0x330
> [21893.282993]  [<ffffffff81732848>] ? repair_env_string+0x58/0x58
> [21893.282997] ---[ end trace d2be5719b9c30b65 ]---
>
> If this is is already a known issue please let me know.  Otherwise,
> I'm happy to provide any additional information that might be helpful
> in tracking it down.
can you send the output of 'sysctl -a'.
one related fix is commit 93b174ad71b08e504c2cf6e8a58ecce778b77a40



> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
