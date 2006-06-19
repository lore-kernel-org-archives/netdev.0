From: Daniel Gryniewicz <dang@fprintf.net>
Subject: Re: [PATCH, RFT] bcm43xx: Busting the 1G limit
Date: Mon, 19 Jun 2006 11:23:49 -0400
Message-ID: <1150730630.9048.2.camel@athena.fprintf.net>
References: <200606171928.08155.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nemesis.fprintf.net ([66.134.112.218]:16391 "EHLO
	nemesis.fprintf.net") by vger.kernel.org with ESMTP id S932466AbWFSPXz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jun 2006 11:23:55 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200606171928.08155.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-06-17 at 19:28 +0200, Michael Buesch wrote:
> Hi,
> 
> This patch adds full 32-bit and 64-bit DMA support
> to the bcm43xx driver. Well, it _should_ do this. I can
> not test it, as I don't have a machine to trigger the 1G
> limit.
> The 1G limit should be exploitable on an AMD64 machine
> with more than 1G RAM.
> 
> Please test and report, if it works or not. In the
> case of "works not", please provide full dmesg log.
> 
> Note that I am not sure which cards actually support
> full 32-bit or even 64-bit mode. Older cards might still
> only support 30-bit DMA.

Hi.

I tried this on both 2.6.17-rc6 and on wireless-dev, and got pretty much
the same panic on both (modulo locking).  My box is a turion with 2 GB
of ram and a BCM4318.  Here's the panic from wireless-dev:

Unable to handle kernel NULL pointer dereference at 0000000000000020
RIP:
<ffffffff88104f24>{:bcm43xx:bcm43xx_dma_handle_xmitstatus+436}
PGD 0
Oops: 0000 [1] PREEMPT
CPU 0
Modules linked in: uhci_hdc ieee80211_crypt_wep cryptoloop loop
snd_atiixp_modem
snd_atiixp snd_ac97_codec snd_ac97_bus bcm43xx snd_pcm snd_timer
ieee80211softmac ehci_hcd snd ohci1394 ieee80211 ohci_hdc sdhci ieee1394
yenta_socket usbcore mmc_core soundcore rsrc_nonstatic ieee80211_crypt
8139too
snd_page_alloc pcmcia_core
Pid: 6139, comm: iwconfig Not tainted 2.6.17-rc6-dfg1-g57aab842-dirty #1
RIP: 0010:[<ffffffff88104f24>]
<ffffffff88104f24>{:bcm43xx:bcm43xx_dma_handle_xmitstatus+436}
RSP: 0018:ffffffff81445df8  EFLAGS: 00010002
RAX: 0000000000000063 RBX: 0000000000000001 RCX: 00000000ffffffff
RDX: 0000000000000000 RSI: 0000000000000082 RDI: 0000000000000001
RBP: ffffffff81445e28 R08: 000000000002e8c7 R09: 0000000000000000
R10: 0000000000000000 R11: 00000000fffffffa R12: 0000000000000000
R13: 00000000000030d1 R14: ffffffff81445eb8 R15: 00000000000000d0
FS:  00002b8b5dc68d20(0000) GS:ffffffff81445eb8(0000)
knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000020 CR3: 0000000076314000 CR4: 00000000000006e0
Process iwconfig (pid: 6139, threadinfo ffff8100748ae000, task
ffff810075840890)
Stack: ffff81007510f050 0000000000000000 ffff81007510f050
0000000000008800
       ffffffff814453b8 0000000020000800 ffffffff814453f8
ffffffff880f13cb
       ffffffff81445e78 ffff81007541e740
Call Trace: <IRQ> <ffffffff880f13cb>{:bcm43xx:bcm43xx_interrupt_tasklet
+2379}
       <ffffffff81092b78>{tasklet_action+72}
<ffffffff810126d0>{__do_softirq+80}
       <ffffffff8106872a>{call_softirq+30} <ffffffff81075e04>{do_softirq
+52}
       <ffffffff81092cf4>{irq_exit+63} <ffffffff81075e51>{do_IRQ+65}
       <ffffffff81067dae>{ret_from_intr+0} <EOI>
<ffffffff810078c8>{_raw_spin_lock+296}
       <ffffffff8106dc9e>{_spin_lock+30}
<ffffffff810202dd>{unlink_file_vma+61}
       <ffffffff810206a8>{free_pagetables+152}
<ffffffff8103ee97>{exit_mmap+135}
       <ffffffff810416b6>{mmput+54} <ffffffff81047b63>{exit_mmap+243}
       <ffffffff81016a9a>{do_exit+602} <ffffffff81012e1c>{__fput+428}
       <ffffffff810506e0>{debug_mutex_init+0}
<ffffffff81054862>{sys_exit_group+18}
       <ffffffff81067892>{system_call+126}

Code: 45 3b 7c 24 20 7c 28 49 c7 c0 be 9e 10 88 b9 59 03 00 00 48
RIP <ffffffff88104f24>{:bcm43xx:bcm43xx_dma_handle_xmitstatus+436} RSP
<ffffffff81445df8>
CR2: 0000000000000020
 <0>Kernel panic - not syncing: Aiee, killing interrupt handler!

Daniel

