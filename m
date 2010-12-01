From: "Stefan Lippers-Hollmann" <s.L-H@gmx.de>
Subject: Re: [PATCH] net/r8169: Remove the firmware of RTL8111D
Date: Wed, 1 Dec 2010 17:36:55 +0100
Message-ID: <201012011736.59625.s.L-H@gmx.de>
References: <1291180966-3124-1-git-send-email-hayeswang@realtek.com> <20101201080732.GA3234@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Hayes Wang <hayeswang@realtek.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ben Hutchings <ben@decadent.org.uk>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101201080732.GA3234@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

On Wednesday 01 December 2010, Francois Romieu wrote:
> Hayes Wang <hayeswang@realtek.com> :
> > Remove the firmware of RTL8111D from the kernel.
> > The binary file of firmware would be moved to linux-firmware repository.
> 
> The driver can not simply go along when request_firmware fails. Though Ben's
> code did not take care of it, the driver should imho propagate some return
> code. Ben ?
[...]

At least for RTL8111D-1 (rtl8168d_1_hw_phy_config(), phy_reg_init_2[])
a missing firmware update doesn't seem to be fatal
	http://bugs.debian.org/561309#45

I'm running that card (onboard of the Intel D945GSEJT mainboard), with
rtl8168d_1_hw_phy_config()/ phy_reg_init_2[] stripped out, without any 
noticable issues for about a year as always-on home server and good 
GBit/s performance.

[    3.861378] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    3.861462] r8169 0000:01:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    3.861575] r8169 0000:01:00.0: setting latency timer to 64
[    3.861703] r8169 0000:01:00.0: irq 45 for MSI/MSI-X
[    3.865188] r8169 0000:01:00.0: eth0: RTL8168d/8111d at 0xf8406000, 00:1c:c0:ee:22:88, XID 081000c0 IRQ 45

using Debian's firmware removal patch and without the required firmware
image being present
[    3.870663] eth0: unable to apply firmware patch

[   16.364231] r8169 0000:01:00.0: eth0: link up
[   26.562069] eth0: no IPv6 routers present

Debian has been shipping (unstable and a little later squeeze, the 
upcoming stable) kernels with this firmware stripped out since late 
december 2009.

Therefore I'd think it's safe to just make some noise about missing 
firmware images and not cease operations completely for this chipset.

Regards
	Stefan Lippers-Hollmann
