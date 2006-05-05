From: Alex Davis <alex14641@yahoo.com>
Subject: iwconfig shows Encrypt  key off when using WEP.
Date: Thu, 4 May 2006 19:37:54 -0700 (PDT)
Message-ID: <20060505023754.5931.qmail@web50203.mail.yahoo.com>
References: <20060426204937.GF7922@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from web50203.mail.yahoo.com ([206.190.38.44]:1135 "HELO
	web50203.mail.yahoo.com") by vger.kernel.org with SMTP
	id S932445AbWEEChz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 22:37:55 -0400
To: linville@tuxdriver.com, netdev@vger.kernel.org
In-Reply-To: <20060426204937.GF7922@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



I'm using the latest wireless dev git. wireless tools version 28.
wpa_supplicant 0.4.8 .

Here's the output of iwconfig wlan0:

wlan0     IEEE 802.11g  ESSID:"mysid"
          Mode:Managed  Frequency:2.437 GHz  Access Point: xx:xx.....
          RTS thr:off   Fragment thr=2346 B
          Encryption key:off   <--- should be 'on'

Here's lspci -v:

2:03.0 Network controller: Broadcom Corporation BCM4309 802.11a/b/g (rev 03)
        Subsystem: Dell Truemobile 1450 MiniPCI
        Flags: bus master, fast devsel, latency 32, IRQ 7
        Memory at fafee000 (32-bit, non-prefetchable) [size=8K]


Here's the dmesg output from loading the module:

21428.599628] bcm43xx_d80211 driver
[21428.609511] ACPI: PCI Interrupt 0000:02:03.0[A] -> Link [LNKB] -> GSI 7 (level, low) -> IRQ 7
[21428.615559] bcm43xx_d80211: Chip ID 0x4306, rev 0x3
[21428.615561] bcm43xx_d80211: Number of cores: 5
[21428.615566] bcm43xx_d80211: Core 0: ID 0x800, rev 0x4, vendor 0x4243, enabled
[21428.615574] bcm43xx_d80211: Core 1: ID 0x812, rev 0x5, vendor 0x4243, disabled
[21428.615582] bcm43xx_d80211: Core 2: ID 0x80d, rev 0x2, vendor 0x4243, enabled
[21428.615590] bcm43xx_d80211: Core 3: ID 0x807, rev 0x2, vendor 0x4243, disabled
[21428.615597] bcm43xx_d80211: Core 4: ID 0x804, rev 0x9, vendor 0x4243, enabled
[21428.618895] bcm43xx_d80211: PHY connected
[21428.618907] bcm43xx_d80211: Detected PHY: Version: 2, Type 2, Revision 2
[21428.618928] bcm43xx_d80211: Detected Radio: ID: 2205017f (Manuf: 17f Ver: 2050 Rev: 2)
[21428.618943] bcm43xx_d80211: Radio turned off
[21428.618970] bcm43xx_d80211: Radio turned off
[21428.689486] wmaster0: Selected rate control algorithm 'simple'
[21428.789510] bcm43xx_d80211: PHY connected
[21428.992261] bcm43xx_d80211: Radio turned on
[21429.186760] bcm43xx_d80211: Chip initialized
[21429.186974] bcm43xx_d80211: DMA initialized
[21429.186985] bcm43xx_d80211: 80211 cores initialized
[21429.187199] bcm43xx_d80211: Keys cleared
[21429.187239] wmaster0: Does not support passive scan, disabled

Here's my wep.conf file:
# Static WEP keys

ctrl_interface=/var/run/wpa_supplicant

network={
        ssid="mysid"
        auth_alg=OPEN
        key_mgmt=NONE
        wep_key0=111111919191919191919
        wep_tx_keyidx=0
}

Here's the wpa_supplicant command:
wpa_supplicant -D wext -c ~/wep.conf -i wlan0


Other than that, it's been working perfectly.

Thanks

I code, therefore I am

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 
