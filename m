From: Alex Davis <alex14641@yahoo.com>
Subject: System hangs after running 2.6.17rc6 with broadcom 4309 and device scape stack
Date: Sun, 18 Jun 2006 17:18:45 -0700 (PDT)
Message-ID: <20060619001845.84526.qmail@web50206.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from web50206.mail.yahoo.com ([206.190.38.47]:60283 "HELO
	web50206.mail.yahoo.com") by vger.kernel.org with SMTP
	id S1750860AbWFSASq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jun 2006 20:18:46 -0400
To: netdev@vger.kernel.org, linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After running 2.6.17rc6 with device scape stack 
(git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-dev.git)
for a few hours, my system hangs. Here is the last thing I see in my logs:

[4323255.189000] NETDEV WATCHDOG: wmaster0: transmit timed out
[4323255.189000] wmaster0: resetting interface.
[4323255.189000] bcm43xx_d80211: Controller RESET (IEEE reset) ...
[4323255.191000] bcm43xx_d80211: ASSERTION FAILED (bcm->mac_suspended >= 0) at:
drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c:2191:bcm43xx_mac_suspend()
[4323255.192000] ACPI: PCI interrupt for device 0000:02:03.0 disabled
[4323255.192000] ACPI: PCI Interrupt 0000:02:03.0[A] -> Link [LNKB] -> GSI 7 (level, low) -> IRQ 7
[4323255.198000] bcm43xx_d80211: Chip ID 0x4306, rev 0x3
[4323255.198000] bcm43xx_d80211: Number of cores: 5
[4323255.198000] bcm43xx_d80211: Core 0: ID 0x800, rev 0x4, vendor 0x4243, enabled
[4323255.198000] bcm43xx_d80211: Core 1: ID 0x812, rev 0x5, vendor 0x4243, disabled
[4323255.198000] bcm43xx_d80211: Core 2: ID 0x80d, rev 0x2, vendor 0x4243, enabled
[4323255.198000] bcm43xx_d80211: Core 3: ID 0x807, rev 0x2, vendor 0x4243, disabled
[4323255.198000] bcm43xx_d80211: Core 4: ID 0x804, rev 0x9, vendor 0x4243, enabled
[4323255.201000] bcm43xx_d80211: PHY connected
[4323255.201000] bcm43xx_d80211: Detected PHY: Version: 2, Type 2, Revision 2
[4323255.201000] bcm43xx_d80211: Detected Radio: ID: 2205017f (Manuf: 17f Ver: 2050 Rev: 2)
[4323255.201000] bcm43xx_d80211: Radio turned off
[4323255.201000] bcm43xx_d80211: Radio turned off
[4323255.201000] bcm43xx_d80211: Controller restarted

This has happened daily during the two days I've been running this version.

My log also has lots of these messages:

4322054.949000] bcm43xx_d80211: ASSERTION FAILED (bcm->mac_suspended >= 0) at:
drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c:2191:bcm43xx_mac_suspend()
[4322054.950000] bcm43xx_d80211: ASSERTION FAILED (bcm->mac_suspended >= 0) at:
drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c:2173:bcm43xx_mac_enable()
[4322114.953000] bcm43xx_d80211: ASSERTION FAILED (bcm->mac_suspended >= 0) at:
drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c:2191:bcm43xx_mac_suspend()
[4322114.970000] bcm43xx_d80211: ASSERTION FAILED (bcm->mac_suspended >= 0) at:
drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c:2173:bcm43xx_mac_enable()
[4322174.973000] bcm43xx_d80211: ASSERTION FAILED (bcm->mac_suspended >= 0) at:
drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c:2191:bcm43xx_mac_suspend()
[4322174.974000] bcm43xx_d80211: ASSERTION FAILED (bcm->mac_suspended >= 0) at:
drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c:2173:bcm43xx_mac_enable()
[4322234.977000] bcm43xx_d80211: ASSERTION FAILED (bcm->mac_suspended >= 0) at:
drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c:2191:bcm43xx_mac_suspend()
[4322234.994000] bcm43xx_d80211: ASSERTION FAILED (bcm->mac_suspended >= 0) at:
drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c:2173:bcm43xx_mac_enable()
[4322294.997000] bcm43xx_d80211: ASSERTION FAILED (bcm->mac_suspended >= 0) at:
drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c:2191:bcm43xx_mac_suspend()

The system hangs so hard not even alt-sysrq can wake it up.

This problem did not occur in the 2.6.17r4 or rc5 versions of the dscape stack.

System is a Dell Latitude D600 laptop.

#lsmod
rate_control            5312  0
bcm43xx_d80211        451456  0
80211                 181512  2 rate_control,bcm43xx_d80211
snd_pcm_oss            43680  0
snd_mixer_oss          18688  1 snd_pcm_oss
ohci_hcd               21060  0
usbhid                 41184  0
intel_agp              22044  1
uhci_hcd               23628  0
generic                 4356  0 [permanent]
snd_intel8x0           32028  0
snd_ac97_codec        101408  1 snd_intel8x0
snd_ac97_bus            2240  1 snd_ac97_codec
snd_pcm                89668  3 snd_pcm_oss,snd_intel8x0,snd_ac97_codec
snd_timer              23172  1 snd_pcm
snd                    52004  6
snd_pcm_oss,snd_mixer_oss,snd_intel8x0,snd_ac97_codec,snd_pcm,snd_timer
soundcore               8160  1 snd
snd_page_alloc          8904  2 snd_intel8x0,snd_pcm
8250_pci               20352  0
8250                   26996  1 8250_pci
serial_core            19904  1 8250
tg3                   114692  0
yenta_socket           26636  4
rsrc_nonstatic         12992  1 yenta_socket
pcmcia                 35116  0
firmware_class          8768  2 bcm43xx_d80211,pcmcia
crc32                   4096  1 pcmcia
pcmcia_core            40544  3 yenta_socket,rsrc_nonstatic,pcmcia
nls_iso8859_1           4032  1
ntfs                  107828  1
usbkbd                  6784  0
usbmouse                4992  0
agpgart                32236  1 intel_agp
usb_storage            35972  2
sd_mod                 18496  3
scsi_mod              131624  2 usb_storage,sd_mod
ehci_hcd               31624  0

#lspci
02:03.0 Network controller: Broadcom Corporation BCM4309 802.11a/b/g (rev 03)

relevant part of .config:
CONFIG_BCM43XX_D80211=m
CONFIG_BCM43XX_D80211_DEBUG=y
CONFIG_BCM43XX_D80211_DMA=y
CONFIG_BCM43XX_D80211_PIO=y
CONFIG_BCM43XX_D80211_DMA_AND_PIO_MODE=y
# CONFIG_BCM43XX_D80211_DMA_MODE is not set
# CONFIG_BCM43XX_D80211_PIO_MODE is not set

Can test patches if necessary.


I code, therefore I am

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 
