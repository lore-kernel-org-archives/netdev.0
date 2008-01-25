From: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
Subject: [PATCH 00/14][v3]: Driver for Wireless RNDIS USB devices.
Date: Sat, 26 Jan 2008 00:50:32 +0200
Message-ID: <20080125225032.11716.77713.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bjd-a1rhEgazXTw@public.gmane.org, david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

Here is the third try on wireless RNDIS patchset.

Patches 1-9 are from second patchset (with name change rndis_wext -> rndis_wlan
in comments where needed):
 1. Fix sparse warning: returning void valued expression
 2. [cdc_ether] Hardwire CDC descriptors when missing
 3. [rndis_host] Use 1KB buffer in rndis_unbind
 4. [rndis_host] Halt device if rndis_bind fails
 5. [rndis_host] Fix rndis packet filter flags
 6. [usbnet] Use wlan device name for RNDIS wireless devices
 7. [rndis_host] Split up rndis_host.c
 8. [rndis_host] export functions
 9. [usbnet] add driver_priv pointer to 'struct usbnet'

Changed patches 10-14:
10. [rndis_host] Add early_init function pointer to 'struct rndis_data'.
11. [rndis_host] Add link_change function pointer to 'struct rndis_data'.
12. [rndis_host] Add RNDIS physical medium checking into generic_rndis_bind()
13. Move usbnet.h and rndis_host.h to include/linux/usb
14. Add new driver 'rndis_wlan' for wireless RNDIS devices.

Devices are now detected by RNDIS physical medium type instead of
vendor/product ids. Driver has new infrastucture/authentication/encryption 
setup code (from ndiswrapper) which fixes issued with WEP and AdHoc. 
List of modes I've tested and work:
 - WEP
 - WPA2 PSK (with CCMP)
 - unencrypted
 - unencrypted ad-hoc
 - hidden unencrypted
 - ad-hoc WEP
 - hidden WEP
That do not work:
 - WPA PSK (with TKIP), I couldn't get this work with Windows driver using
   ndiswrapper and driver from previous patchset and no call were made
   to driver with SIOCSIWENCODEEXT so I'm starting to think problem is with
   the version of wpa_supplicant I have.
 - Hidden WPA, didn't work with earlier driver and as far as I know ndiswrapper
   has the same problem.
Untested:
 - WPA PSK with CCMP
 - WPA2 PSK with TKIP
 - WPA/WPA2 Enterprise

Patches should be applied in order, series apply cleanly to 2.6.24-git1.

 - Jussi Kivilinna
