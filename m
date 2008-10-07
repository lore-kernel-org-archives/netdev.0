From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2 driver can't enable/disable wake-on-lan on HP DL585 G2
 onboard NICs
Date: Mon, 6 Oct 2008 21:36:54 -0700
Message-ID: <C27F8246C663564A84BB7AB34397724202784A2B96@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <20081006194845.4e18705f@manzanita>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "'Tim Mann'" <mann@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1189 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750803AbYJGEhH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 00:37:07 -0400
In-Reply-To: <20081006194845.4e18705f@manzanita>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Tim Mann wrote:

>
> Here's the deal.  The HP DL585 G2 has an onboard dual-port
> NIC based on
> the bcm5706.  Both ports support wake-on-lan, but WOL works
> if and only
> if you enable it using an option in the HP BIOS setup screens.  If you
> disable it from there, ethtool still thinks WOL is supported and that
> it's enabled by default, but the machine won't wake.  Conversely (and
> this part surprises me more), if you enable WOL from the BIOS setup
> screen, the machine always wakes on a WOL magic packet *even* if you
> try to disable WOL using ethtool.  Again ethtool thinks that WOL is
> supported and that it's enabled by default, and it thinks that it can
> disable WOL, but disabling it through ethtool has no effect -- the
> machine wakes anyway.

It sounds like an extra reset to the NIC is happening on this machine
during shutdown or suspend.  When that happens, it would wipe out the
WoL setting done by the driver.  I'll see if we have this DL585 to
try it out here.

>
> I don't have this problem with other NICs that use the bnx2
> driver.  In
> particular, I just retested one that I have in a box in my office, and
> the bnx2 driver can both enable and disable WOL on that NIC fine.
>
> So far I've tried this only with a bnx2 driver that advertises itself
> as 1.6.9 with release date December 8, 2007.  I could try with a newer
> one, but I looked at the diffs between 1.6.9 and 1.8.0 and I
> didn't see
> anything that looks like it should affect this.  Let me know if I
> should try it anyway, though.
>
> In case it helps, here's lspci output from the HP box with
> the misbehaving NIC:
>
> [root@drm121 ~]# lspci -s 41:01.0 -v
> 41:01.0 Ethernet controller: Broadcom Corporation NetXtreme
> II 5706 Gigabit Ethernet (rev 02)
>         Subsystem: Hewlett-Packard Company Unknown device 1709
>         Flags: bus master, 66MHz, medium devsel, latency 120, IRQ 23
>         Memory at fa000000 (64-bit, non-prefetchable) [size=32M]
>         [virtual] Expansion ROM at 88200000 [disabled] [size=2K]
>         Capabilities: [40] PCI-X non-bridge device
>         Capabilities: [48] Power Management version 2
>         Capabilities: [50] Vital Product Data
> [root@drm121 ~]# lspci -s 41:01.0 -v -n
> 41:01.0 0200: 14e4:164a (rev 02)
>         Subsystem: 103c:1709
>         Flags: bus master, 66MHz, medium devsel, latency 120, IRQ 23
>         Memory at fa000000 (64-bit, non-prefetchable) [size=32M]
>         [virtual] Expansion ROM at 88200000 [disabled] [size=2K]
>         Capabilities: [40] PCI-X non-bridge device
>         Capabilities: [48] Power Management version 2
>         Capabilities: [50] Vital Product Data

This is unrelated to WoL, but why is MSI capability missing on the
HP machine?

>
> Here's output from my test machine:
>
> [root@moppet ~]# lspci -s 41:04.0 -v
> 41:04.0 Ethernet controller: Broadcom Corporation NetXtreme
> II 5706 Gigabit Ethernet (rev 02)
>         Subsystem: Hewlett-Packard Company Unknown device 3101
>         Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 16
>         Memory at f0000000 (64-bit, non-prefetchable) [size=32M]
>         [virtual] Expansion ROM at 88000000 [disabled] [size=64K]
>         Capabilities: [40] PCI-X non-bridge device
>         Capabilities: [48] Power Management version 2
>         Capabilities: [50] Vital Product Data
>         Capabilities: [58] Message Signalled Interrupts:
> 64bit+ Queue=0/0 Enable-
>
> [root@moppet ~]# lspci -s 41:04.0 -v -n
> 41:04.0 0200: 14e4:164a (rev 02)
>         Subsystem: 103c:3101
>         Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 16
>         Memory at f0000000 (64-bit, non-prefetchable) [size=32M]
>         [virtual] Expansion ROM at 88000000 [disabled] [size=64K]
>         Capabilities: [40] PCI-X non-bridge device
>         Capabilities: [48] Power Management version 2
>         Capabilities: [50] Vital Product Data
>         Capabilities: [58] Message Signalled Interrupts:
> 64bit+ Queue=0/0 Enable
>
>
> --
> Tim Mann  work: mann@vmware.com  home: tim@tim-mann.org
>           http://www.vmware.com  http://tim-mann.org
>
>

