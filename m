From: Pablo Cholaky <mrwaltercool@gmail.com>
Subject: Re: r8169 Wake on Lan
Date: Tue, 26 Nov 2013 20:27:54 -0300
Message-ID: <CAEv3EXFm5MrDeZLRyAZdVNoXWEGB7sU405+oM7K=o=eiAnUNPA@mail.gmail.com>
References: <CAEv3EXFiUnfkBCiedjXUzc6MXBnP2vqNx4R3739642dGYazTwA@mail.gmail.com>
 <20131126232101.GA7508@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:35054 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757489Ab3KZX2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 18:28:15 -0500
Received: by mail-wg0-f52.google.com with SMTP id x13so6080651wgg.19
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 15:28:14 -0800 (PST)
In-Reply-To: <20131126232101.GA7508@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Seems like ACPI is enabling by default WOL, I'm wrong? Or maybe a BIOS
setting, unconfigurable by user.

My dmesg of r8159

[    3.834430] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    3.836970] r8169 0000:02:00.0: irq 43 for MSI/MSI-X
[    3.837151] r8169 0000:02:00.0 eth0: RTL8168g/8111g at
0xffffc9000524a000, a4:5d:36:be:93:a3, XID 0c000800 IRQ 43
[    3.837154] r8169 0000:02:00.0 eth0: jumbo features [frames: 9200
bytes, tx checksumming: ko]
[   15.509384] r8169 0000:02:00.0 eth0: link down
[ 2212.203541] r8169 0000:02:00.0 eth0: link down
[33965.758196] r8169 0000:02:00.0: System wakeup enabled by ACPI
[33966.155166] r8169 0000:02:00.0: System wakeup disabled by ACPI
[33970.285568] r8169 0000:02:00.0 eth0: link down
[33991.837714] r8169 0000:02:00.0 eth0: link down
[65787.535308] r8169 0000:02:00.0 eth0: link down
[73646.418210] r8169 0000:02:00.0: System wakeup enabled by ACPI
[73646.818712] r8169 0000:02:00.0: System wakeup disabled by ACPI
[73650.971790] r8169 0000:02:00.0 eth0: link down
[81000.170579] r8169 0000:02:00.0 eth0: link down
[81777.521723] r8169 0000:02:00.0 eth0: link down
[98273.025146] r8169 0000:02:00.0 eth0: link down

If kernel parameters are ugly... a on-kernel option should be bad too?

On Tue, Nov 26, 2013 at 8:21 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Pablo Cholaky <mrwaltercool@gmail.com> :
> [...]
>> I have a HP ENVY laptop with this RealTek, and my laptop don't have a
>> BIOS option to disable WOL. I'm currently using a script on start and
>> shutdown to disable WOL, but could you guys make a module param to
>> enable/disable WOL?
>
> The kernel has to offer a standardized API. Module params are terrible
> in this regard. Please forget it.
>
>> This freaking WOL eats a lot of battery on my laptop and my scripts
>> don't work when I'm using a hibernation or booting a Linux ISO per
>> example.
>
> (if a kernel change can propagate to your ISO, so can your wol
> disabling scripts)
>
> There may be something wrong wrt hibernation (real hibernation, not
> runtime suspend, right ?) but I do not see how the current code could
> change the WoL settings at suspend time for a downed interface.
> Care to provide a short description for your hibernation use ?
>
> The XID line included in dmesg output or plain dmesg itself will be
> welcome to identify the r8169 chipset. It can make some difference in
> the suspend / resume paths.
>
> --
> Ueimor



-- 
Pablo Cholaky
Linux user and developer
Slash.cl Owner
Blablabla
