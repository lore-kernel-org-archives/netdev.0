From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [GIT] Networking
Date: Fri, 7 Jan 2011 22:13:54 +0100
Message-ID: <20110107211354.GA1862@electric-eye.fr.zoreil.com>
References: <20110106.122003.233698077.davem@davemloft.net> <AANLkTi=7=_FyVsjA3vKEpg8RwfC=m-8QGfqa6ctxQday@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Hayes Wang <hayeswang@realtek.com>,
	Ben Hutchings <benh@debian.org>,
	David Woodhouse <dwmw2@infradead.org>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57240 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753232Ab1AGWeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jan 2011 17:34:03 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTi=7=_FyVsjA3vKEpg8RwfC=m-8QGfqa6ctxQday@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linus Torvalds <torvalds@linux-foundation.org> :
> On Thu, Jan 6, 2011 at 12:20 PM, David Miller <davem@davemloft.net> wrote:
> >
> > Plus the usual spattering of wireless, bluetooth, and wired driver
> > updates.
> 
> Grr.

Oops.

[...]
> [torvalds@i5 linux]$ git bisect good
> bca03d5f32c8ee9b5cfa1d32640a63fded6cb3c0 is the first bad commit
> commit bca03d5f32c8ee9b5cfa1d32640a63fded6cb3c0
> Author: fran?ois romieu <romieu@fr.zoreil.com>
> Date:   Mon Jan 3 15:07:31 2011 +0000
> 
>     r8169: remove the firmware of RTL8111D.
> 
>     The binary file of the firmware is moved to linux-firmware repository.
>     The firmwares are rtl_nic/rtl8168d-1.fw and rtl_nic/rtl8168d-2.fw.
>     The driver goes along if the firmware couldn't be found. However, it
>     is suggested to be done with the suitable firmware.
> 
>     Some wrong PHY parameters are directly corrected in the driver.
> 
>     Simple firmware checking added per Ben Hutchings suggestion.
> 
>     Signed-off-by: Hayes Wang <hayeswang@realtek.com>
>     Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
>     Cc: Ben Hutchings <benh@debian.org>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> and the behavior is very broken: it just hangs at boot-time. No
> messages from the driver (certainly not any messages about missing
> firmware), no nothing. The thing is just hung.
>
> On a working setup, I have
> 
> 
>   [    1.595071] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
>   [    1.595114] r8169 0000:01:00.0: PCI INT A -> GSI 19 (level, low) -> IRQ 19
>   [    1.595174] r8169 0000:01:00.0: setting latency timer to 64
>   [    1.595227] r8169 0000:01:00.0: irq 42 for MSI/MSI-X
>   [    1.595770] r8169 0000:01:00.0: eth0: RTL8168d/8111d at
> 0xffffc90000068000, e0:cb:4e:95:1a:d7, XID 083000c0 IRQ 42

>   ...
>   [    7.985917] r8169 0000:01:00.0: eth0: link up
>   [    7.987525] r8169 0000:01:00.0: eth0: link up
> 
> while on a non-working setup, I get that XID line, and after that a
> few other init routines continue to show up (probably just
> multi-threaded initcalls), but the box is dead.
> 
> Quite frankly, that commit looks broken anyway. It doesn't just switch
> to the firmware loader, it also seems to change other things (ie
> removed some mdio writes, added others).

It was described in the commit message as
[...]
    Some wrong PHY parameters are directly corrected in the driver.

> What's going on?

The firmware is supposed to be optional. The (relevant) 8168 have
been reported to work without it. I have tested it with my hardware
(RTL_GIGA_MAC_VER_26 (== your), RTL_GIGA_MAC_VER_25 + some others),
seen the "r8169 0000:02:00.0: eth0: unable to apply firmware patch"
message and noticed that the card was actually working. Though I did
not try a non-modular build, this was not exactly a five minutes
test.

I had no technical reason [*] to turn the firmware mandatory and screw
distro-maintainers who have decided that the firmware is not free enough.

[*] The small "I will regret it" voices in my head do not count as
    technical reasons.

[...]
> Not acceptable. I'm ok with an external firmware repository, but only
> if it _works_. Right now it doesn't. It just seems to cause silent
> failures: there were no warnings about missing firmware at ANY time.
> Not build-time, not run-time.

?

The driver is supposed to display a message at KERN_WARNING.

-- 
Ueimor
