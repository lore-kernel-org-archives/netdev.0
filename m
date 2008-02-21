From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: sungem triggers NAPI warning
Date: Thu, 21 Feb 2008 13:54:32 +1100
Message-ID: <1203562472.10422.102.camel@pasglop>
References: <1203457124.3874.2.camel@johannes.berg>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:53310 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751347AbYBUCzK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 21:55:10 -0500
In-Reply-To: <1203457124.3874.2.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2008-02-19 at 22:38 +0100, Johannes Berg wrote:
> I started getting this warning with recent kernels:

Do that help ?

In gem_poll(), do:

-  work_done += gem_rx(gp, budget);
+  work_done += gem_rx(gp, budget - work_done);

Cheers,
Ben.

> [  773.908927] ------------[ cut here ]------------
> [  773.908954] Badness at net/core/dev.c:2204
> [  773.908958] NIP: c0277960 LR: c0277948 CTR: c02b9948
> [  773.908963] REGS: ee8f1800 TRAP: 0700   Not tainted  (2.6.25-rc2-00261-g54a6132-dirty)
> [  773.908966] MSR: 00029032 <EE,ME,IR,DR>  CR: 84224448  XER: 20000000
> [  773.908976] TASK = eefa0e00[3143] 'Xorg' THREAD: ee8f0000
> [  773.908979] GPR00: 00000001 ee8f18b0 eefa0e00 0000005e ef8d0c30 00000044 00000000 864a0000 
> [  773.908988] GPR08: 00004a86 f2280000 00000000 00000044 00000000 101f85a4 00000000 ee8f1d9c 
> [  773.908997] GPR16: ee8f1da0 ee8f1da4 00000000 ee8f1d94 ee8f1d98 c0620000 c08751a4 0000b994 
> [  773.909006] GPR24: c08750e4 00000000 000000ec 0000005e ee8f0000 00000000 00000040 ef82454c 
> [  773.909016] NIP [c0277960] net_rx_action+0x190/0x218
> [  773.909027] LR [c0277948] net_rx_action+0x178/0x218
> [  773.909032] Call Trace:
> [  773.909035] [ee8f18b0] [c0277948] net_rx_action+0x178/0x218 (unreliable)
> [  773.909041] [ee8f18f0] [c0034d9c] __do_softirq+0x84/0xf8
> [  773.909053] [ee8f1910] [c0006aac] do_softirq+0x58/0x5c
> [  773.909063] [ee8f1920] [c00348d8] irq_exit+0x60/0x80
> [  773.909068] [ee8f1930] [c0006fcc] do_IRQ+0xa8/0xc8
> [  773.909074] [ee8f1940] [c00129d4] ret_from_except+0x0/0x14
> [  773.909086] --- Exception: 501 at _spin_unlock_irqrestore+0x1c/0x54
> [  773.909094]     LR = _spin_unlock_irqrestore+0x18/0x54
> [  773.909098] [ee8f1a20] [c01f39c0] tty_ldisc_try+0x54/0x6c
> [  773.909108] [ee8f1a40] [c01f4d5c] tty_ldisc_ref_wait+0x18/0xb0
> [  773.909114] [ee8f1a80] [c01f4e54] tty_poll+0x60/0xa8
> [  773.909119] [ee8f1aa0] [c00ad734] do_select+0x294/0x4fc
> [  773.909131] [ee8f1d70] [c00adc4c] core_sys_select+0x2b0/0x404
> [  773.909137] [ee8f1ed0] [c00ae510] sys_select+0x140/0x250
> [  773.909142] [ee8f1f10] [c00052ec] ppc_select+0x24/0x150
> [  773.909148] [ee8f1f40] [c0012328] ret_from_syscall+0x0/0x38
> [  773.909153] --- Exception: c01 at 0xfc2b28c
> [  773.909179]     LR = 0x101a4528
> [  773.909181] Instruction dump:
> [  773.909185] 4182ff98 801f0010 7fe3fb78 7fc4f378 7c0903a6 4e800421 7c7b1b78 7f1bf000 
> [  773.909193] 4099ff80 80180204 7c000034 5400d97e <0f000000> 2f800000 419eff68 38000001 
> 
> with a sungem card. I have no idea what to do about it, it doesn't seem
> to be fatal in any way either.
> 
> In order to trigger it, I have to transfer a lot of data. I have
> triggered it now with a full kernel recompilation using -j6 and distcc
> onto a fast machine (with tg3 network, direct cable, gbit), and with
> rsync transferring 26GiB data between the machines.
> 
> johannes

