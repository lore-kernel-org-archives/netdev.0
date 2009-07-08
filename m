From: Andres Freund <andres@anarazel.de>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 ( possibly?caused by netem)
Date: Thu, 9 Jul 2009 00:23:17 +0200
Message-ID: <200907090023.18040.andres@anarazel.de>
References: <200907031326.21822.andres@anarazel.de> <200907071811.27570.andres@anarazel.de> <20090708080852.GC3148@ami.dom.local>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_WxRVKyNxIVlMgf/"
Cc: Joao Correia <joaomiguelcorreia@gmail.com>,
	Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.anarazel.de ([217.115.131.40]:60674 "EHLO smtp.anarazel.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754439AbZGHWXW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jul 2009 18:23:22 -0400
In-Reply-To: <20090708080852.GC3148@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_WxRVKyNxIVlMgf/
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit

On Wednesday 08 July 2009 10:08:52 Jarek Poplawski wrote:
> On Tue, Jul 07, 2009 at 06:11:27PM +0200, Andres Freund wrote:
> > On Tuesday 07 July 2009 15:57:42 Jarek Poplawski wrote:
> > > On Tue, Jul 07, 2009 at 03:34:07PM +0200, Andres Freund wrote:
> > > ...
> > >
> > > > Testing wether its triggerable inside a vm might be interesting...
> > >
> > > Probably similarly to testing without this patch or even less. Maybe
> > > I should've warned you but this type of bugs in -rc with possible
> > > memory or stack overwrites might be fatal for your data (at least).
> >
> > Fortunately all the data on that machine should either be replaceable or
> > regularly backuped.
> >
> > Will test later today if that patch bugs.
>
> If you didn't start yet, it would be nice to use this, btw:
> CONFIG_HOTPLUG_CPU = N
> CONFIG_DEBUG_OBJECTS = Y
> CONFIG_DEBUG_OBJECTS_TIMERS = Y
Unfortunately this just yields the same backtraces during softlockup and not 
earlier.
I did not test without lockdep yet, but that should not have stopped the BUG 
from appearing, right?


Andres

--Boundary-00=_WxRVKyNxIVlMgf/
Content-Type: text/plain;
  charset="UTF-8";
  name="trace.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="trace.txt"

[  207.233011] BUG: soft lockup - CPU#0 stuck for 61s! [openvpn:4232]
[  207.233011] Modules linked in: sch_netem sbs sbshc snd_hda_codec_conexant pcmcia snd_hda_intel snd_hda_codec iwlagn thinkpad_acpi yenta_socket rsrc_nonstatic pcmcia_core btusb snd_hwdep ehci_hcd uhci_hcd
[  207.233011] irq event stamp: 158057
[  207.233011] hardirqs last  enabled at (158056): [<ffffffff81036a10>] restore_args+0x0/0x30
[  207.233011] hardirqs last disabled at (158057): [<ffffffff81035d3a>] save_args+0x6a/0x70
[  207.233011] softirqs last  enabled at (27750): [<ffffffff8155837d>] lock_sock_nested+0x8d/0x130
[  207.233011] softirqs last disabled at (27756): [<ffffffff81568278>] dev_queue_xmit+0x58/0x4b0
[  207.233011] CPU 0:
[  207.233011] Modules linked in: sch_netem sbs sbshc snd_hda_codec_conexant pcmcia snd_hda_intel snd_hda_codec iwlagn thinkpad_acpi yenta_socket rsrc_nonstatic pcmcia_core btusb snd_hwdep ehci_hcd uhci_hcd
[  207.233011] Pid: 4232, comm: openvpn Not tainted 2.6.31-rc2-andres-00151-gf3060b0-dirty #83 208252G
[  207.233011] RIP: 0010:[<ffffffff812a9eb1>]  [<ffffffff812a9eb1>] delay_tsc+0x51/0x80
[  207.233011] RSP: 0018:ffff88012984f938  EFLAGS: 00000202
[  207.233011] RAX: 000000007086c4e9 RBX: ffff88012984f958 RCX: 000000007086c4e9
[  207.233011] RDX: 000000007086c4e9 RSI: 0000000000006238 RDI: 0000000000000001
[  207.233011] RBP: ffffffff81036b6e R08: ffffffff82189460 R09: 0000000000000002
[  207.233011] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000003fda
[  207.233011] R13: ffff88002ee00000 R14: ffff88012984e000 R15: 0000000000000000
[  207.233011] FS:  00007f518d51a6f0(0000) GS:ffff88002ee00000(0000) knlGS:0000000000000000
[  207.233011] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  207.233011] CR2: 00007f46fb78600c CR3: 000000012bc8f000 CR4: 00000000000026f0
[  207.233011] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  207.233011] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  207.233011] Call Trace:
[  207.233011]  [<ffffffff812a9eaa>] ? delay_tsc+0x4a/0x80
[  207.233011]  [<ffffffff812a9d9a>] ? __delay+0xa/0x10
[  207.233011]  [<ffffffff812ae578>] ? _raw_spin_lock+0xd8/0x150
[  207.233011]  [<ffffffff816f0431>] ? _spin_lock+0x51/0x70
[  207.233011]  [<ffffffff81568306>] ? dev_queue_xmit+0xe6/0x4b0
[  207.233011]  [<ffffffff81568306>] ? dev_queue_xmit+0xe6/0x4b0
[  207.233011]  [<ffffffff81568273>] ? dev_queue_xmit+0x53/0x4b0
[  207.233011]  [<ffffffff8159a67c>] ? ip_finish_output+0x13c/0x320
[  207.233011]  [<ffffffff8159a8db>] ? ip_output+0x7b/0xd0
[  207.233011]  [<ffffffff81598b98>] ? ip_generic_getfrag+0x88/0xa0
[  207.233011]  [<ffffffff815996c0>] ? ip_local_out+0x20/0x30
[  207.233011]  [<ffffffff81599957>] ? ip_push_pending_frames+0x287/0x410
[  207.233011]  [<ffffffff815bae18>] ? udp_push_pending_frames+0x168/0x3d0
[  207.233011]  [<ffffffff815bcd07>] ? udp_sendmsg+0x457/0x760
[  207.233011]  [<ffffffff815c4144>] ? inet_sendmsg+0x24/0x60
[  207.233011]  [<ffffffff81555556>] ? sock_sendmsg+0x126/0x140
[  207.233011]  [<ffffffff81097f60>] ? autoremove_wake_function+0x0/0x40
[  207.233011]  [<ffffffff810ab6e7>] ? mark_held_locks+0x67/0x90
[  207.233011]  [<ffffffff816f01fb>] ? _spin_unlock_irqrestore+0x3b/0x70
[  207.233011]  [<ffffffff810ab9fd>] ? trace_hardirqs_on_caller+0x14d/0x190
[  207.233011]  [<ffffffff81556490>] ? sys_sendto+0xf0/0x130
[  207.233011]  [<ffffffff810aba4d>] ? trace_hardirqs_on+0xd/0x10
[  207.233011]  [<ffffffff810a21f7>] ? getnstimeofday+0x57/0xe0
[  207.233011]  [<ffffffff8109c1f1>] ? ktime_get_ts+0x51/0x70
[  207.233011]  [<ffffffff81035ec2>] ? system_call_fastpath+0x16/0x1bx

--Boundary-00=_WxRVKyNxIVlMgf/--
