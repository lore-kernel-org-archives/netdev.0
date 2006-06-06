From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Problem authenticating using WPA with bcm43xx-softmac
Date: Tue, 06 Jun 2006 14:24:27 -0500
Message-ID: <4485D66B.7080108@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:23252 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1750990AbWFFTYa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jun 2006 15:24:30 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since my Linksys WRT54G V1 died and was replaced with a V5 (Yes, I know it was a mistake.), I have 
been unable to authenticate using WPA-PSK TKIP with bcm43xx-softmac. I'm sure that my wpa_supplicant 
setup is OK as it has not been changed since the AP was changed, and the system works if I use 
ndiswrapper with the Windows driver.

The logged messages are:

Jun  6 13:34:08 larrylap kernel: bcm43xx: set security called
Jun  6 13:34:08 larrylap kernel: bcm43xx:    .level = 0
Jun  6 13:34:08 larrylap kernel: bcm43xx:    .enabled = 0
Jun  6 13:34:08 larrylap kernel: bcm43xx:    .encrypt = 0
Jun  6 13:34:09 larrylap kernel: SoftMAC: Start scanning with channel: 1
Jun  6 13:34:09 larrylap kernel: SoftMAC: Scanning 11 channels
Jun  6 13:34:09 larrylap kernel: SoftMAC: Scanning finished
Jun  6 13:34:09 larrylap kernel: SoftMAC: Associate: Scanning for networks first.
Jun  6 13:34:09 larrylap kernel: SoftMAC: Start scanning with channel: 1
Jun  6 13:34:09 larrylap kernel: SoftMAC: Scanning 11 channels
Jun  6 13:34:09 larrylap kernel: SoftMAC: Scanning finished
Jun  6 13:34:09 larrylap kernel: SoftMAC: Associate: Scanning for networks first.
Jun  6 13:34:09 larrylap kernel: SoftMAC: Start scanning with channel: 1
Jun  6 13:34:09 larrylap kernel: SoftMAC: Scanning 11 channels
Jun  6 13:34:09 larrylap kernel: SoftMAC: Associate: Scanning for networks first.
Jun  6 13:34:09 larrylap kernel: SoftMAC: Start scanning with channel: 1
Jun  6 13:34:09 larrylap kernel: SoftMAC: Scanning 11 channels
Jun  6 13:34:09 larrylap kernel: SoftMAC: Queueing Authentication Request to 00:14:bf:85:49:fa
Jun  6 13:34:09 larrylap kernel: SoftMAC: cannot associate without being authenticated, requested 
authentication
Jun  6 13:34:09 larrylap kernel: SoftMAC: Sent Authentication Request to 00:14:bf:85:49:fa.
Jun  6 13:34:10 larrylap kernel: SoftMAC: Open Authentication completed with 00:14:bf:85:49:fa
Jun  6 13:34:10 larrylap kernel: SoftMAC: sent association request!
Jun  6 13:34:10 larrylap kernel: SoftMAC: Scanning finished
Jun  6 13:34:10 larrylap kernel: SoftMAC: sent association request!
Jun  6 13:34:10 larrylap kernel: SoftMAC: generic IE set to 
ffffffdd160050fffffff20101000050fffffff20201000050fffffff20201000050fffffff202
Jun  6 13:34:10 larrylap kernel: SoftMAC: associating failed due to invalid pairwise cipher
Jun  6 13:34:10 larrylap kernel: SoftMAC: sent association request!
Jun  6 13:34:10 larrylap kernel: SoftMAC: associating failed due to invalid pairwise cipher

The debug output from wpa_supplicant is as follows:

larrylap:~ # wpa_supplicant -iwlan0 -c/etc/wpa_supplicant.conf -Dwext -ddd
Initializing interface 'wlan0' conf '/etc/wpa_supplicant.conf' driver 'wext' ctrl_interface 'N/A'
Configuration file '/etc/wpa_supplicant.conf' -> '/etc/wpa_supplicant.conf'
Reading configuration file '/etc/wpa_supplicant.conf'
ctrl_interface='/var/run/wpa_supplicant'
Line: 3 - start of a new network block
ssid - hexdump_ascii(len=6):
      6c 77 66 64 6a 66                                 lwfdjf
scan_ssid=1 (0x1)
key_mgmt: 0x2
proto: 0x1
pairwise: 0x18
group: 0x18
PSK (ASCII passphrase) - hexdump_ascii(len=27): [REMOVED]
priority=3 (0x3)
PSK (from passphrase) - hexdump(len=32): [REMOVED]
Priority group 3
    id=0 ssid='lwfdjf'
Initializing interface (2) 'wlan0'
EAPOL: SUPP_PAE entering state DISCONNECTED
EAPOL: KEY_RX entering state NO_KEY_RECEIVE
EAPOL: SUPP_BE entering state INITIALIZE
EAP: EAP entering state DISABLED
EAPOL: External notification - portEnabled=0
EAPOL: External notification - portValid=0
SIOCGIWRANGE: WE(compiled)=20 WE(source)=18 enc_capa=0xf
   capabilities: key_mgmt 0xf enc 0xf
Own MAC address: 00:06:25:40:6f:03
wpa_driver_wext_set_wpa
WEXT auth param 7 value 0x1 -
wpa_driver_wext_set_key: alg=0 key_idx=0 set_tx=0 seq_len=0 key_len=0
wpa_driver_wext_set_key: alg=0 key_idx=1 set_tx=0 seq_len=0 key_len=0
wpa_driver_wext_set_key: alg=0 key_idx=2 set_tx=0 seq_len=0 key_len=0
wpa_driver_wext_set_key: alg=0 key_idx=3 set_tx=0 seq_len=0 key_len=0
wpa_driver_wext_set_countermeasures
WEXT auth param 4 value 0x0 -
wpa_driver_wext_set_drop_unencrypted
WEXT auth param 5 value 0x1 -
Setting scan request: 0 sec 100000 usec
Added interface wlan0
Wireless event: cmd=0x8b06 len=8
State: DISCONNECTED -> SCANNING
Starting AP scan (specific SSID)
Scan SSID - hexdump_ascii(len=6):
      6c 77 66 64 6a 66                                 lwfdjf
Wireless event: cmd=0x8b19 len=8
Received 395 bytes of scan results (2 BSSes)
Scan results: 2
Selecting BSS from priority group 3
0: 00:14:bf:85:49:fa ssid='lwfdjf' wpa_ie_len=26 rsn_ie_len=0 caps=0x11
    selected based on WPA IE
Trying to associate with 00:14:bf:85:49:fa (SSID='lwfdjf' freq=0 MHz)
Cancelling scan request
WPA: clearing own WPA/RSN IE
Automatic auth_alg selection: 0x1
WEXT auth param 6 value 0x1 -
WPA: using IEEE 802.11i/D3.0
WPA: Selected cipher suites: group 8 pairwise 8 key_mgmt 2
WPA: set AP WPA IE - hexdump(len=26): dd 18 00 50 f2 01 01 00 00 50 f2 02 01 00 00 50 f2 02 01 00 00 
50 f2 02 00 00
WPA: clearing AP RSN IE
WPA: using GTK TKIP
WPA: using PTK TKIP
WPA: using KEY_MGMT WPA-PSK
WPA: Set own WPA IE default - hexdump(len=24): dd 16 00 50 f2 01 01 00 00 50 f2 02 01 00 00 50 f2 02 
01 00 00 50 f2 02
No keys have been configured - skip key clearing
wpa_driver_wext_set_drop_unencrypted
WEXT auth param 5 value 0x1 -
State: SCANNING -> ASSOCIATING
wpa_driver_wext_associate
wpa_driver_wext_set_gen_ie
WEXT auth param 0 value 0x2 -
WEXT auth param 1 value 0x4 -
WEXT auth param 2 value 0x4 -
WEXT auth param 3 value 0x2 -
WEXT auth param 10 value 0x1 -
WEXT auth param 8 value 0x0 -
Setting authentication timeout: 10 sec 0 usec
EAPOL: External notification - EAP success=0
EAPOL: External notification - EAP fail=0
EAPOL: External notification - portControl=Auto
Wireless event: cmd=0x8b06 len=8
Wireless event: cmd=0x8b1a len=15
Authentication with 00:00:00:00:00:00 timed out.
Added BSSID 00:00:00:00:00:00 into blacklist
State: ASSOCIATING -> DISCONNECTED
No keys have been configured - skip key clearing
EAPOL: External notification - portEnabled=0
EAPOL: External notification - portValid=0
Setting scan request: 0 sec 0 usec
State: DISCONNECTED -> SCANNING
Starting AP scan (broadcast SSID)
Wireless event: cmd=0x8b19 len=8
Received 395 bytes of scan results (2 BSSes)
Scan results: 2
Selecting BSS from priority group 3
0: 00:14:bf:85:49:fa ssid='lwfdjf' wpa_ie_len=26 rsn_ie_len=0 caps=0x11
    selected based on WPA IE
Trying to associate with 00:14:bf:85:49:fa (SSID='lwfdjf' freq=0 MHz)
Cancelling scan request
WPA: clearing own WPA/RSN IE
Automatic auth_alg selection: 0x1
WEXT auth param 6 value 0x1 -
WPA: using IEEE 802.11i/D3.0
WPA: Selected cipher suites: group 8 pairwise 8 key_mgmt 2
WPA: set AP WPA IE - hexdump(len=26): dd 18 00 50 f2 01 01 00 00 50 f2 02 01 00 00 50 f2 02 01 00 00 
50 f2 02 00 00
WPA: clearing AP RSN IE
WPA: using GTK TKIP
WPA: using PTK TKIP
WPA: using KEY_MGMT WPA-PSK
WPA: Set own WPA IE default - hexdump(len=24): dd 16 00 50 f2 01 01 00 00 50 f2 02 01 00 00 50 f2 02 
01 00 00 50 f2 02
No keys have been configured - skip key clearing
wpa_driver_wext_set_drop_unencrypted
WEXT auth param 5 value 0x1 -
State: SCANNING -> ASSOCIATING
wpa_driver_wext_associate
wpa_driver_wext_set_gen_ie
WEXT auth param 0 value 0x2 -
WEXT auth param 1 value 0x4 -
WEXT auth param 2 value 0x4 -
WEXT auth param 3 value 0x2 -
WEXT auth param 10 value 0x1 -
WEXT auth param 8 value 0x0 -
Setting authentication timeout: 10 sec 0 usec
EAPOL: External notification - EAP success=0
EAPOL: External notification - EAP fail=0
EAPOL: External notification - portControl=Auto
Wireless event: cmd=0x8b06 len=8
Wireless event: cmd=0x8b1a len=15
Authentication with 00:00:00:00:00:00 timed out.
BSSID 00:00:00:00:00:00 blacklist count incremented to 2
State: ASSOCIATING -> DISCONNECTED
No keys have been configured - skip key clearing
EAPOL: External notification - portEnabled=0
EAPOL: External notification - portValid=0
Setting scan request: 0 sec 0 usec
State: DISCONNECTED -> SCANNING

---repeats forever----

Why does SoftMAC set a generic IE rather than get one from wpa_supplicant? I would appreciate help 
with this problem.

Larry
