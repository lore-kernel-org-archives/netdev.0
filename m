From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sky2 driver breaks reboot/shutdown
Date: Wed, 16 Nov 2011 14:48:06 -0800
Message-ID: <20111116144806.0b6e327f@nehalam.linuxnetplumber.net>
References: <878vnfpy6y.fsf@turtle.gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Sven Joachim <svenjoac@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <878vnfpy6y.fsf@turtle.gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 16 Nov 2011 22:14:13 +0100
Sven Joachim <svenjoac@gmx.de> wrote:

> [ Resending since my first attempt apparently did not make it to the
>   mailing lists.  Apologies to anyone who receives duplicates. ]
> 
> Hi,
> 
> after upgrading from Linux 3.1 to 3.2-rc2 I noticed that the kernel
> would no longer reboot or shutdown properly, hanging instead.  Removing
> the sky2 driver works around this.  According to "lspci -v", I have the
> following network card:
> 
> ,----
> | 03:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8056 PCI-E Gigabit Ethernet Controller (rev 13)
> | 	Subsystem: ABIT Computer Corp. Device 108f
> | 	Flags: bus master, fast devsel, latency 0, IRQ 17
> | 	Memory at fdefc000 (64-bit, non-prefetchable) [size=16K]
> | 	I/O ports at ce00 [size=256]
> | 	[virtual] Expansion ROM at fdd00000 [disabled] [size=128K]
> | 	Capabilities: <access denied>
> | 	Kernel driver in use: sky2
> `----
> 
> Bisecting shows 0bdb0bd01 as the first bad commit:
> 

Already reported. I am testing a fix. The hang is happening in synchronize_irq
in sky2_hw_all_down; but there are several other bugs that were introduced at the
same time.
