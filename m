From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] bcm43xx-softmac: add PCI-E code
Date: Fri, 20 Oct 2006 11:46:55 -0400
Message-ID: <4538EF6F.3030305@gentoo.org>
References: <45330803.mail261110C22@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
In-Reply-To: <45330803.mail261110C22-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Larry,

Larry Finger wrote:
> From: Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>
> 
> The current bcm43xx driver does not contain code to handle PCI-E interfaces
> such as the BCM4311 and BCM4312. This patch, originally written by Stefano
> Brivio adds the necessary code to enable these interfaces. 

I am testing this on a Compaq VS6120US laptop. This is my first 
experience with using bcm43xx. I'm connecting to a WPA network.

bcm43xx: Chip ID 0x4311, rev 0x1
bcm43xx: Number of cores: 4
bcm43xx: Core 0: ID 0x800, rev 0x11, vendor 0x4243, enabled
bcm43xx: Core 1: ID 0x812, rev 0xa, vendor 0x4243, disabled
bcm43xx: Core 2: ID 0x817, rev 0x3, vendor 0x4243, disabled
bcm43xx: Core 3: ID 0x820, rev 0x1, vendor 0x4243, enabled
bcm43xx: PHY connected
bcm43xx: Detected PHY: Version: 4, Type 2, Revision 8
bcm43xx: Detected Radio: ID: 2205017f (Manuf: 17f Ver: 2050 Rev: 2)

Most of the time, it doesn't work. wpa_supplicant scans, gets scan 
results, tries to associate, and then things stop there. Sometimes the 
association completes but the WPA PSK stuff times out, sometimes the WPA 
PSK stuff completes and it gets an IP, but doesn't get any further.

After bringing down the interface, it cannot be brought up again:

bcm43xx: Radio turned off
bcm43xx: DMA-32 0x0200 (RX) max used slots: 7/64
bcm43xx: DMA-32 0x02A0 (TX) max used slots: 0/512
bcm43xx: DMA-32 0x0280 (TX) max used slots: 0/512
bcm43xx: DMA-32 0x0260 (TX) max used slots: 0/512
bcm43xx: DMA-32 0x0240 (TX) max used slots: 0/512
bcm43xx: DMA-32 0x0220 (TX) max used slots: 7/512
bcm43xx: DMA-32 0x0200 (TX) max used slots: 0/512
bcm43xx: ASSERTION FAILED (bcm43xx_status(bcm) == 
BCM43xx_STAT_INITIALIZED) at: 
drivers/net/wireless/bcm43xx/bcm43xx_main.c:1852:bcm43xx_interrupt_handler()
bcm43xx: IRQ_READY timeout
bcm43xx: core_up for active 802.11 core failed (-19)

Unloading and reloading the driver allows the interface to come up again.

Approximately 1 in 5 times it does get an IP and I can connect to stuff.

I realise this report probably isn't all that useful, but this laptop is 
going to be out of the office for a while, I guess I'll just lend him a 
ZD1211 if he needs wireless.

Daniel
