From: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Subject: [2.6.31-rc1] iwlagn (4965): regression when hardware rf switch is used
Date: Mon, 29 Jun 2009 11:28:04 +0200
Message-ID: <200906291128.05639.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

(Reported earlier in 'no wireless due to RFKILL problem' thread, but
Johannes suggested opening a new thread as it is a separate issue.)

I've tried .31-rc1 on my HP 2510p notebook and noticed a problem when
using the hardware rf kill switch.

If disable wireless using the hardware switch and the enable it again
almost immediately after on 2.6.30, I get:
[disable]
iwlagn 0000:10:00.0: Radio Frequency Kill Switch is On:
Kill switch must be turned off for wireless networking to work.
usb 3-1: USB disconnect, address 2
[enable]
Registered led device: iwl-phy0::radio
Registered led device: iwl-phy0::assoc
Registered led device: iwl-phy0::RX
Registered led device: iwl-phy0::TX
usb 3-1: new full speed USB device using uhci_hcd and address 3
usb 3-1: configuration #1 chosen from 1 choice
wlan0: no probe response from AP 00:14:c1:38:e5:15 - disassociating
iwlagn 0000:10:00.0: index 0 not used in uCode key table.
wlan0: authenticate with AP 00:14:c1:38:e5:15
wlan0: authenticate with AP 00:14:c1:38:e5:15
wlan0: authenticated
wlan0: associate with AP 00:14:c1:38:e5:15
wlan0: RX ReassocResp from 00:14:c1:38:e5:15 (capab=0x411 status=0 aid=1)
wlan0: associated

And without any other action networking is up again.


But with 2.6.31 I get this:
[disable]
wlan0: deauthenticating by local choice (reason=3)
iwlagn 0000:10:00.0: Error sending REPLY_ADD_STA: enqueue_hcmd failed: -5
mac80211-phy0: failed to remove key (0, 00:14:c1:38:e5:15) from hardware (-5)
iwlagn 0000:10:00.0: Error sending REPLY_ADD_STA: enqueue_hcmd failed: -5
mac80211-phy0: failed to remove key (1, ff:ff:ff:ff:ff:ff) from hardware (-5)
usb 3-1: USB disconnect, address 2
[enable]
usb 3-1: new full speed USB device using uhci_hcd and address 3
usb 3-1: configuration #1 chosen from 1 choice

A lot uglier with those errors. And after that I have to run ifdown/ifup
before networking is up again (ifup only does not work as it will complain
"interface already configured"):

[ifdown wlan0]
Registered led device: iwl-phy0::radio
Registered led device: iwl-phy0::assoc
Registered led device: iwl-phy0::RX
Registered led device: iwl-phy0::TX
ADDRCONF(NETDEV_UP): wlan0: link is not ready
[ifup wlan 0]
Registered led device: iwl-phy0::radio
Registered led device: iwl-phy0::assoc
Registered led device: iwl-phy0::RX
Registered led device: iwl-phy0::TX
ADDRCONF(NETDEV_UP): wlan0: link is not ready
wlan0: authenticate with AP 00:14:c1:38:e5:15
wlan0: authenticated
wlan0: associate with AP 00:14:c1:38:e5:15
wlan0: RX AssocResp from 00:14:c1:38:e5:15 (capab=0x411 status=0 aid=1)
wlan0: associated
ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready

BTW, would it make sense to bring back the first two lines shown with .30
(or at least the first one):
   iwlagn 0000:10:00.0: Radio Frequency Kill Switch is On:
   Kill switch must be turned off for wireless networking to work.
IMHO it's good to register the reason for the disconnect.

>From lspci:
10:00.0 Network controller [0280]: Intel Corporation PRO/Wireless
        4965 AG or AGN [Kedron] Network Connection [8086:4229] (rev 61)

Cheers,
FJP
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
