From: Mike McCormack <mikem@ring3k.org>
Subject: Wireless fails to associate at boot (regression) due to commit
	77fdaa12c
Date: Tue, 21 Jul 2009 14:54:29 +0900
Message-ID: <392fb48f0907202254t120ff3cmec885d164dc3344d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f213.google.com ([209.85.217.213]:36477 "EHLO
	mail-gx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754455AbZGUFya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 01:54:30 -0400
Received: by gxk9 with SMTP id 9so4918254gxk.13
        for <netdev@vger.kernel.org>; Mon, 20 Jul 2009 22:54:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johannes,

The following commit causes my wireless network not to associate after
bootup.  It eventually associates with the wireless router (dlink,
unencrypted) after 5 or 10 minutes, or after poking it with an
ifdown/ifup wlan0.  Without the following patch, association occurs by
the time dhclient starts looking for an IP address for my machine.

mike@mini:~/net-next-2.6$ cat wireless-regression.txt
77fdaa12cea26c204cc12c312fe40bc0f3dcdfd8 is first bad commit
commit 77fdaa12cea26c204cc12c312fe40bc0f3dcdfd8
Author: Johannes Berg <johannes@sipsolutions.net>
Date:   Tue Jul 7 03:45:17 2009 +0200

    mac80211: rework MLME for multiple authentications

The system is a mini-mac, and the wireless card is using the ath5k driver:

02:00.0 Ethernet controller: Atheros Communications Inc. AR242x
802.11abg Wireless PCI Express Adapter (rev 01)
        Subsystem: Apple Computer Inc. Device 0086
        Flags: bus master, fast devsel, latency 0, IRQ 17
        Memory at 90100000 (64-bit, non-prefetchable) [size=64K]
        Capabilities: [40] Power Management version 2
        Capabilities: [50] Message Signalled Interrupts: Mask- 64bit-
Queue=0/0 Enable-
        Capabilities: [60] Express Legacy Endpoint, MSI 00
        Capabilities: [90] MSI-X: Enable- Mask- TabSize=1
        Capabilities: [100] Advanced Error Reporting <?>
        Capabilities: [140] Virtual Channel <?>
        Kernel driver in use: ath5k
        Kernel modules: ath5k

After associating we get:

mike@mini:~/net-next-2.6$ /sbin/iwconfig wlan0
wlan0     IEEE 802.11abg  ESSID:"dlink"
          Mode:Managed  Frequency:2.437 GHz  Access Point: 00:22:B0:F3:6E:CB
          Bit Rate=36 Mb/s   Tx-Power=20 dBm
          Retry  long limit:7   RTS thr:off   Fragment thr:off
          Power Management:off

Below is the dmesg output in case of failure.

thanks,

Mike


[   11.505312] loop: module loaded
[   11.744097] cfg80211: Using static regulatory domain info
[   11.744169] cfg80211: Regulatory domain: US
[   11.744231]  (start_freq - end_freq @ bandwidth),
(max_antenna_gain, max_eirp)
[   11.744311]  (2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, 2700 mBm)
[   11.744380]  (5170000 KHz - 5190000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
[   11.744456]  (5190000 KHz - 5210000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
[   11.744519]  (5210000 KHz - 5230000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
[   11.744582]  (5230000 KHz - 5330000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
[   11.744644]  (5735000 KHz - 5835000 KHz @ 40000 KHz), (600 mBi, 3000 mBm)
[   11.744712] cfg80211: Calling CRDA for country: US
[   11.891754] ath5k 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[   11.891831] ath5k 0000:02:00.0: setting latency timer to 64
[   11.891867] ath5k 0000:02:00.0: registered as 'phy0'
[   12.100829] ath: EEPROM regdomain: 0x5e
[   12.100832] ath: EEPROM indicates we should expect a direct regpair map
[   12.100837] ath: Country alpha2 being used: KP
[   12.100839] ath: Regpair used: 0x5e
[   12.317670] phy0: Selected rate control algorithm 'minstrel'
[   12.318020] ath5k phy0: Atheros AR5414 chip found (MAC: 0xa3, PHY: 0x61)
[   12.318971] cfg80211: Calling CRDA for country: KP
[   12.479093] device-mapper: uevent: version 1.0.3
[   12.479669] device-mapper: ioctl: 4.15.0-ioctl (2009-04-01)
initialised: dm-devel@redhat.com
[   78.401661] NET: Registered protocol family 10
[   78.402439] lo: Disabled Privacy Extensions
[   78.403894] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[  136.401387] [drm] Initialized drm 1.1.0 20060810
[  136.558731] pci 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[  136.558738] pci 0000:00:02.0: setting latency timer to 64
[  136.562181] [drm] Initialized i915 1.6.0 20080730 for 0000:00:02.0 on minor 0
[  297.483216] wlan0: deauthenticating by local choice (reason=3)
[  300.593186] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[  300.593214] wlan0: direct probe to AP 00:22:b0:f3:6e:cb (try 1)
[  300.596300] wlan0 direct probe responded
[  300.596307] wlan0: authenticate with AP 00:22:b0:f3:6e:cb (try 1)
[  300.597728] wlan0: authenticated
[  300.796039] wlan0: associate with AP 00:22:b0:f3:6e:cb (try 1)
[  300.798311] wlan0: RX AssocResp from 00:22:b0:f3:6e:cb (capab=0x421
status=0 aid=1)
[  300.798317] wlan0: associated
[  300.799024] ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
[  311.648031] wlan0: no IPv6 routers present
