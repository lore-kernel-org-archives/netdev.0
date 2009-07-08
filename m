From: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Subject: [regression] ath5k: Overrides regulatory domain set for cfg80211
Date: Wed, 8 Jul 2009 23:40:06 +0200
Message-ID: <200907082340.07787.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In /etc/modprobe.d I have a file containing:
options cfg80211 ieee80211_regdom=EU

During boot this results in:
<snip>
cfg80211: Using static regulatory domain info
cfg80211: Regulatory domain: EU
	(start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
	(2402000 KHz - 2482000 KHz @ 40000 KHz), (600 mBi, 2000 mBm)
	(5170000 KHz - 5190000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
	(5190000 KHz - 5210000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
	(5210000 KHz - 5230000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
	(5230000 KHz - 5330000 KHz @ 40000 KHz), (600 mBi, 2000 mBm)
	(5490000 KHz - 5710000 KHz @ 40000 KHz), (600 mBi, 3000 mBm)
cfg80211: Calling CRDA for country: EU
</snip>

But with 2.6.31-rc2 I then get (the lines marked with "!" are not there 
with .30):
<snip>
  ath5k 0000:02:00.0: enabling device (0000 -> 0002)
  ath5k 0000:02:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
  ath5k 0000:02:00.0: registered as 'phy0'
! ath: EEPROM regdomain: 0x30
! ath: EEPROM indicates we should expect a direct regpair map
! ath: Country alpha2 being used: AM
! ath: Regpair used: 0x30
  phy0: Selected rate control algorithm 'minstrel'
  ath5k phy0: Atheros AR5213A chip found (MAC: 0x59, PHY: 0x43)
  ath5k phy0: RF2112B 2GHz radio found (0x46)
! cfg80211: Calling CRDA for country: AM
</snip>

So it looks as if ath5k has started to override the regdomain I want.

Cheers,
FJP
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
