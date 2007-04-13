From: Stefan Puch <stefan.puch@mail.uni-oldenburg.de>
Subject: prism54: WPA/RSN support for fullmac cards
Date: Fri, 13 Apr 2007 15:56:41 +0200
Message-ID: <461F8C19.5030609@mail.uni-oldenburg.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040909080609040307000206"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpsrv03.uni-oldenburg.de ([134.106.87.11]:54408 "EHLO
	smtpsrv03.uni-oldenburg.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753536AbXDMOmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2007 10:42:50 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040909080609040307000206
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Hi everyone,

I found on this mailinglist the thread from chunkeey who added WPA support for
prism54 fullmac cards

http://www.spinics.net/lists/netdev/msg16224.html

The last days I tried to get this driver working, but I was not able to. After
"googling" and reading the mails I found that Jim Faulkner have had similar
problems, see posting on this mailing list here:

http://www.spinics.net/lists/linux-net/msg14821.html

So I tried to make hopefully "useful" debug traces, perhaps anyone can tell me
why it doesn't work?

The Hardware:
Access point: AVM Fritz!Box Fon WLAN 7170 (last stable Firmware)
Laptop: Fujitsu Siemens Lifebook C
WLAN-Adapter: Netgear WG511 (Fullmac)


The Software:
- Vanilla Kernel 2.6.20.6 (WE-21)
- Wireless Tools version 29-pre17 (The main features is WE-21 support)
- firmware Version 1.0.4.3 (from www.prism54.org)
- wpa_supplicant Version 0.5.5
- as reference ndiswrapper version 1.41

First of all I tried the good old WEP encryption with the prism54 driver: No
problem, it works fine with the firmware 1.0.4.3!!!

Next step was to try get a  WPA connection to the access point. I can load the
kernel module, the firmware is loaded correctly, too.
Only the connection with wpa_supplicant doesn't establish (debug trace attached
this email), here's my wpa_supplicant.conf:

ctrl_interface=/var/run/wpa_supplicant
network={
    ssid="puch.home"
    scan_ssid=1
    proto=WPA
    key_mgmt=WPA-PSK
    psk="ThisIsATestWPA-Key"
}

As reference I tried to connect to the access point using ndiswrapper and
wpa_supplicant (same wpa_supplicant.conf). There the connection is established.
I attached the debug trace, too so everyone can see where the differences are)

Please let me know, if there are important infos missing and CC me in any
responses, because I'm not subscribed to this mailing list.

Thanks in advance for any comment or help,

Stefan Puch


--------------040909080609040307000206
Content-Type: text/plain;
 name="prism54.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="prism54.log"

Initializing interface 'eth1' conf '/etc/wpa_supplicant.conf' driver 'wext' ctrl_interface 'N/A' bridge 'N/A'
Configuration file '/etc/wpa_supplicant.conf' -> '/etc/wpa_supplicant.conf'
Reading configuration file '/etc/wpa_supplicant.conf'
ctrl_interface='/var/run/wpa_supplicant'
Line: 4 - start of a new network block
ssid - hexdump_ascii(len=9):
     70 75 63 68 2e 68 6f 6d 65                        puch.home       
scan_ssid=1 (0x1)
PSK (ASCII passphrase) - hexdump_ascii(len=18):
     54 68 69 73 49 73 41 54 65 73 74 57 50 41 2d 4b   ThisIsATestWPA-K
     65 79                                             ey              
key_mgmt: 0x2
proto: 0x1
PSK (from passphrase) - hexdump(len=32): 44 49 84 4d 00 d4 0c 0a 3a bd 2e 33 89 3b d2 39 bc e2 5c 9c 81 38 43 64 6c 9b c0 4b 00 34 5c e5
Priority group 0
   id=0 ssid='puch.home'
Initializing interface (2) 'eth1'
EAPOL: SUPP_PAE entering state DISCONNECTED
EAPOL: KEY_RX entering state NO_KEY_RECEIVE
EAPOL: SUPP_BE entering state INITIALIZE
EAP: EAP entering state DISABLED
EAPOL: External notification - portEnabled=0
EAPOL: External notification - portValid=0
SIOCGIWRANGE: WE(compiled)=21 WE(source)=19 enc_capa=0x7
  capabilities: key_mgmt 0xf enc 0x7
WEXT: Operstate: linkmode=1, operstate=5
Own MAC address: 00:09:5b:c9:5b:52
wpa_driver_wext_set_wpa
wpa_driver_wext_set_key: alg=0 key_idx=0 set_tx=0 seq_len=0 key_len=0
wpa_driver_wext_set_key: alg=0 key_idx=1 set_tx=0 seq_len=0 key_len=0
wpa_driver_wext_set_key: alg=0 key_idx=2 set_tx=0 seq_len=0 key_len=0
wpa_driver_wext_set_key: alg=0 key_idx=3 set_tx=0 seq_len=0 key_len=0
wpa_driver_wext_set_countermeasures
wpa_driver_wext_set_drop_unencrypted
Setting scan request: 0 sec 100000 usec
Added interface eth1
RTM_NEWLINK: operstate=0 ifi_flags=0x1002 ()
Wireless event: cmd=0x8b06 len=8
RTM_NEWLINK: operstate=0 ifi_flags=0x11043 ([UP][RUNNING][LOWER_UP])
RTM_NEWLINK, IFLA_IFNAME: Interface 'eth1' added
RTM_NEWLINK: operstate=0 ifi_flags=0x11043 ([UP][RUNNING][LOWER_UP])
RTM_NEWLINK, IFLA_IFNAME: Interface 'eth1' added
RTM_NEWLINK: operstate=0 ifi_flags=0x11003 ([UP][LOWER_UP])
RTM_NEWLINK, IFLA_IFNAME: Interface 'eth1' added
RTM_NEWLINK: operstate=0 ifi_flags=0x11003 ([UP][LOWER_UP])
Wireless event: cmd=0x8c02 len=70
WEXT: Custom wireless event: 'Received a beacon from an unkown AP to 00:15:0C:D6:C7:74  (00)'
State: DISCONNECTED -> SCANNING
Starting AP scan (specific SSID)
Scan SSID - hexdump_ascii(len=9):
     70 75 63 68 2e 68 6f 6d 65                        puch.home       
Trying to get current scan results first without requesting a new scan to speed up initial association
Received 207 bytes of scan results (1 BSSes)
Scan results: 1
Selecting BSS from priority group 0
0: 00:15:0c:d6:c7:74 ssid='puch.home' wpa_ie_len=26 rsn_ie_len=0 caps=0x11
   selected based on WPA IE
Trying to associate with 00:15:0c:d6:c7:74 (SSID='puch.home' freq=2412 MHz)
Cancelling scan request
WPA: clearing own WPA/RSN IE
Automatic auth_alg selection: 0x1
WPA: using IEEE 802.11i/D3.0
WPA: Selected cipher suites: group 8 pairwise 8 key_mgmt 2 proto 1
WPA: set AP WPA IE - hexdump(len=26): dd 18 00 50 f2 01 01 00 00 50 f2 02 01 00 00 50 f2 02 01 00 00 50 f2 02 00 00
WPA: clearing AP RSN IE
WPA: using GTK TKIP
WPA: using PTK TKIP
WPA: using KEY_MGMT WPA-PSK
WPA: Set own WPA IE default - hexdump(len=24): dd 16 00 50 f2 01 01 00 00 50 f2 02 01 00 00 50 f2 02 01 00 00 50 f2 02
No keys have been configured - skip key clearing
wpa_driver_wext_set_drop_unencrypted
State: SCANNING -> ASSOCIATING
wpa_driver_wext_set_operstate: operstate 0->0 (DORMANT)
WEXT: Operstate: linkmode=-1, operstate=5
wpa_driver_wext_associate
Setting authentication timeout: 10 sec 0 usec
EAPOL: External notification - EAP success=0
EAPOL: External notification - EAP fail=0
EAPOL: External notification - portControl=Auto
RTM_NEWLINK: operstate=0 ifi_flags=0x11003 ([UP][LOWER_UP])
Wireless event: cmd=0x8b06 len=8
RTM_NEWLINK: operstate=0 ifi_flags=0x11003 ([UP][LOWER_UP])
Wireless event: cmd=0x8b04 len=12
RTM_NEWLINK: operstate=0 ifi_flags=0x11003 ([UP][LOWER_UP])
Wireless event: cmd=0x8b1a len=17
RTM_NEWLINK: operstate=0 ifi_flags=0x11003 ([UP][LOWER_UP])
Wireless event: cmd=0x8c02 len=70
WEXT: Custom wireless event: 'Received a beacon from an unkown AP to 00:C0:49:E1:3B:61  (00)'
RTM_NEWLINK: operstate=0 ifi_flags=0x11003 ([UP][LOWER_UP])
Wireless event: cmd=0x8c02 len=63
WEXT: Custom wireless event: 'Received a probe from client to 00:15:0C:D6:C7:74  (00)'
RTM_NEWLINK: operstate=0 ifi_flags=0x11003 ([UP][LOWER_UP])
Wireless event: cmd=0x8c02 len=70
WEXT: Custom wireless event: 'Received a beacon from an unkown AP to 00:15:0C:D6:C7:74  (00)'
RTM_NEWLINK: operstate=0 ifi_flags=0x11003 ([UP][LOWER_UP])
Wireless event: cmd=0x8c02 len=63
WEXT: Custom wireless event: 'Received a probe from client to 00:15:0C:D6:C7:74  (00)'
RTM_NEWLINK: operstate=0 ifi_flags=0x11003 ([UP][LOWER_UP])
Wireless event: cmd=0x8c02 len=72
WEXT: Custom wireless event: 'Authenticate request (ex) to 00:15:0C:D6:C7:74  : ACCEPTED  (00)'
RTM_NEWLINK: operstate=0 ifi_flags=0x11003 ([UP][LOWER_UP])
Wireless event: cmd=0x8c02 len=72
WEXT: Custom wireless event: 'Authenticate request (ex) to 00:15:0C:D6:C7:74  : ACCEPTED  (00)'
RTM_NEWLINK: operstate=0 ifi_flags=0x11003 ([UP][LOWER_UP])
Wireless event: cmd=0x8c02 len=72
WEXT: Custom wireless event: 'Authenticate request (ex) to 00:15:0C:D6:C7:74  : ACCEPTED  (00)'
RTM_NEWLINK: operstate=0 ifi_flags=0x11003 ([UP][LOWER_UP])
Wireless event: cmd=0x8c02 len=63
WEXT: Custom wireless event: 'Received a probe from client to 00:15:0C:D6:C7:74  (00)'
Authentication with 00:00:00:00:00:00 timed out.
Added BSSID 00:15:0c:d6:c7:74 into blacklist
State: ASSOCIATING -> DISCONNECTED
wpa_driver_wext_set_operstate: operstate 0->0 (DORMANT)
WEXT: Operstate: linkmode=-1, operstate=5
No keys have been configured - skip key clearing
EAPOL: External notification - portEnabled=0
EAPOL: External notification - portValid=0
Setting scan request: 0 sec 0 usec
State: DISCONNECTED -> SCANNING
Starting AP scan (broadcast SSID)
Scan timeout - try to get results
Received 383 bytes of scan results (2 BSSes)
Scan results: 2
Selecting BSS from priority group 0
0: 00:15:0c:d6:c7:74 ssid='puch.home' wpa_ie_len=26 rsn_ie_len=0 caps=0x11
   selected based on WPA IE
Trying to associate with 00:15:0c:d6:c7:74 (SSID='puch.home' freq=2412 MHz)
Cancelling scan request
WPA: clearing own WPA/RSN IE
Automatic auth_alg selection: 0x1
WPA: using IEEE 802.11i/D3.0
WPA: Selected cipher suites: group 8 pairwise 8 key_mgmt 2 proto 1
WPA: set AP WPA IE - hexdump(len=26): dd 18 00 50 f2 01 01 00 00 50 f2 02 01 00 00 50 f2 02 01 00 00 50 f2 02 00 00
WPA: clearing AP RSN IE
WPA: using GTK TKIP
WPA: using PTK TKIP
WPA: using KEY_MGMT WPA-PSK
WPA: Set own WPA IE default - hexdump(len=24): dd 16 00 50 f2 01 01 00 00 50 f2 02 01 00 00 50 f2 02 01 00 00 50 f2 02
No keys have been configured - skip key clearing
wpa_driver_wext_set_drop_unencrypted
State: SCANNING -> ASSOCIATING
wpa_driver_wext_set_operstate: operstate 0->0 (DORMANT)
WEXT: Operstate: linkmode=-1, operstate=5
wpa_driver_wext_associate
Setting authentication timeout: 10 sec 0 usec
EAPOL: External notification - EAP success=0
EAPOL: External notification - EAP fail=0
EAPOL: External notification - portControl=Auto
RTM_NEWLINK: operstate=0 ifi_flags=0x11003 ([UP][LOWER_UP])
Wireless event: cmd=0x8b06 len=8
RTM_NEWLINK: operstate=0 ifi_flags=0x11003 ([UP][LOWER_UP])
Wireless event: cmd=0x8b04 len=12
RTM_NEWLINK: operstate=0 ifi_flags=0x11003 ([UP][LOWER_UP])
Wireless event: cmd=0x8b1a len=17
RTM_NEWLINK: operstate=0 ifi_flags=0x11003 ([UP][LOWER_UP])
Wireless event: cmd=0x8c02 len=63
WEXT: Custom wireless event: 'Received a probe from client to 00:15:0C:D6:C7:74  (00)'
RTM_NEWLINK: operstate=0 ifi_flags=0x11003 ([UP][LOWER_UP])
Wireless event: cmd=0x8c02 len=70
WEXT: Custom wireless event: 'Received a beacon from an unkown AP to 00:15:0C:D6:C7:74  (00)'
RTM_NEWLINK: operstate=0 ifi_flags=0x11003 ([UP][LOWER_UP])
Wireless event: cmd=0x8c02 len=63
WEXT: Custom wireless event: 'Received a probe from client to 00:15:0C:D6:C7:74  (00)'
RTM_NEWLINK: operstate=0 ifi_flags=0x11003 ([UP][LOWER_UP])
Wireless event: cmd=0x8c02 len=72
WEXT: Custom wireless event: 'Authenticate request (ex) to 00:15:0C:D6:C7:74  : ACCEPTED  (00)'
RTM_NEWLINK: operstate=0 ifi_flags=0x11003 ([UP][LOWER_UP])
Wireless event: cmd=0x8c02 len=72
WEXT: Custom wireless event: 'Authenticate request (ex) to 00:15:0C:D6:C7:74  : ACCEPTED  (00)'
RTM_NEWLINK: operstate=0 ifi_flags=0x11003 ([UP][LOWER_UP])
Wireless event: cmd=0x8c02 len=72
WEXT: Custom wireless event: 'Authenticate request (ex) to 00:15:0C:D6:C7:74  : ACCEPTED  (00)'
CTRL-EVENT-TERMINATING - signal 2 received
Removing interface eth1
State: ASSOCIATING -> DISCONNECTED
wpa_driver_wext_set_operstate: operstate 0->0 (DORMANT)
WEXT: Operstate: linkmode=-1, operstate=5
No keys have been configured - skip key clearing
EAPOL: External notification - portEnabled=0
EAPOL: External notification - portValid=0
wpa_driver_wext_set_wpa
wpa_driver_wext_set_drop_unencrypted
wpa_driver_wext_set_countermeasures
No keys have been configured - skip key clearing
WEXT: Operstate: linkmode=0, operstate=6
Removed BSSID 00:15:0c:d6:c7:74 from blacklist (clear)
Cancelling scan request

--------------040909080609040307000206
Content-Type: text/plain;
 name="ndiswrapper.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ndiswrapper.log"

Initializing interface 'wlan0' conf '/etc/wpa_supplicant.conf' driver 'wext' ctrl_interface 'N/A' bridge 'N/A'
Configuration file '/etc/wpa_supplicant.conf' -> '/etc/wpa_supplicant.conf'
Reading configuration file '/etc/wpa_supplicant.conf'
ctrl_interface='/var/run/wpa_supplicant'
Line: 4 - start of a new network block
ssid - hexdump_ascii(len=9):
     70 75 63 68 2e 68 6f 6d 65                        puch.home       
scan_ssid=1 (0x1)
PSK (ASCII passphrase) - hexdump_ascii(len=18):
     54 68 69 73 49 73 41 54 65 73 74 57 50 41 2d 4b   ThisIsATestWPA-K
     65 79                                             ey              
key_mgmt: 0x2
proto: 0x1
PSK (from passphrase) - hexdump(len=32): 44 49 84 4d 00 d4 0c 0a 3a bd 2e 33 89 3b d2 39 bc e2 5c 9c 81 38 43 64 6c 9b c0 4b 00 34 5c e5
Priority group 0
   id=0 ssid='puch.home'
Initializing interface (2) 'wlan0'
EAPOL: SUPP_PAE entering state DISCONNECTED
EAPOL: KEY_RX entering state NO_KEY_RECEIVE
EAPOL: SUPP_BE entering state INITIALIZE
EAP: EAP entering state DISABLED
EAPOL: External notification - portEnabled=0
EAPOL: External notification - portValid=0
SIOCGIWRANGE: WE(compiled)=21 WE(source)=18 enc_capa=0xf
  capabilities: key_mgmt 0xf enc 0xf
WEXT: Operstate: linkmode=1, operstate=5
Own MAC address: 00:09:5b:c9:5b:52
wpa_driver_wext_set_wpa
wpa_driver_wext_set_key: alg=0 key_idx=0 set_tx=0 seq_len=0 key_len=0
wpa_driver_wext_set_key: alg=0 key_idx=1 set_tx=0 seq_len=0 key_len=0
wpa_driver_wext_set_key: alg=0 key_idx=2 set_tx=0 seq_len=0 key_len=0
wpa_driver_wext_set_key: alg=0 key_idx=3 set_tx=0 seq_len=0 key_len=0
wpa_driver_wext_set_countermeasures
wpa_driver_wext_set_drop_unencrypted
Setting scan request: 0 sec 100000 usec
Added interface wlan0
RTM_NEWLINK: operstate=0 ifi_flags=0x1002 ()
Wireless event: cmd=0x8b06 len=8
RTM_NEWLINK: operstate=0 ifi_flags=0x1003 ([UP])
RTM_NEWLINK, IFLA_IFNAME: Interface 'wlan0' added
RTM_NEWLINK: operstate=0 ifi_flags=0x1003 ([UP])
RTM_NEWLINK, IFLA_IFNAME: Interface 'wlan0' added
State: DISCONNECTED -> SCANNING
Starting AP scan (specific SSID)
Scan SSID - hexdump_ascii(len=9):
     70 75 63 68 2e 68 6f 6d 65                        puch.home       
Trying to get current scan results first without requesting a new scan to speed up initial association
Received 489 bytes of scan results (2 BSSes)
Scan results: 2
Selecting BSS from priority group 0
0: 00:15:0c:d6:c7:74 ssid='puch.home' wpa_ie_len=26 rsn_ie_len=0 caps=0x11
   selected based on WPA IE
Trying to associate with 00:15:0c:d6:c7:74 (SSID='puch.home' freq=2412 MHz)
Cancelling scan request
WPA: clearing own WPA/RSN IE
Automatic auth_alg selection: 0x1
WPA: using IEEE 802.11i/D3.0
WPA: Selected cipher suites: group 8 pairwise 8 key_mgmt 2 proto 1
WPA: set AP WPA IE - hexdump(len=26): dd 18 00 50 f2 01 01 00 00 50 f2 02 01 00 00 50 f2 02 01 00 00 50 f2 02 00 00
WPA: clearing AP RSN IE
WPA: using GTK TKIP
WPA: using PTK TKIP
WPA: using KEY_MGMT WPA-PSK
WPA: Set own WPA IE default - hexdump(len=24): dd 16 00 50 f2 01 01 00 00 50 f2 02 01 00 00 50 f2 02 01 00 00 50 f2 02
No keys have been configured - skip key clearing
wpa_driver_wext_set_drop_unencrypted
State: SCANNING -> ASSOCIATING
wpa_driver_wext_set_operstate: operstate 0->0 (DORMANT)
WEXT: Operstate: linkmode=-1, operstate=5
wpa_driver_wext_associate
Setting authentication timeout: 10 sec 0 usec
EAPOL: External notification - EAP success=0
EAPOL: External notification - EAP fail=0
EAPOL: External notification - portControl=Auto
RTM_NEWLINK: operstate=0 ifi_flags=0x1003 ([UP])
Wireless event: cmd=0x8b06 len=8
RTM_NEWLINK: operstate=0 ifi_flags=0x1003 ([UP])
Wireless event: cmd=0x8b04 len=12
RTM_NEWLINK: operstate=0 ifi_flags=0x1003 ([UP])
Wireless event: cmd=0x8b1a len=17
RTM_NEWLINK: operstate=0 ifi_flags=0x11003 ([UP][LOWER_UP])
RTM_NEWLINK, IFLA_IFNAME: Interface 'wlan0' added
RTM_NEWLINK: operstate=0 ifi_flags=0x11003 ([UP][LOWER_UP])
Wireless event: cmd=0x8c07 len=59
AssocReq IE wireless event - hexdump(len=51): 00 09 70 75 63 68 2e 68 6f 6d 65 01 04 02 04 0b 16 32 08 0c 12 18 24 30 48 60 6c dd 16 00 50 f2 01 01 00 00 50 f2 02 01 00 00 50 f2 02 01 00 00 50 f2 02
RTM_NEWLINK: operstate=0 ifi_flags=0x11003 ([UP][LOWER_UP])
Wireless event: cmd=0x8c08 len=24
AssocResp IE wireless event - hexdump(len=16): 01 04 82 84 8b 96 32 08 0c 12 18 24 30 48 60 6c
RTM_NEWLINK: operstate=0 ifi_flags=0x11003 ([UP][LOWER_UP])
Wireless event: cmd=0x8b15 len=20
Wireless event: new AP: 00:15:0c:d6:c7:74
Association info event
req_ies - hexdump(len=51): 00 09 70 75 63 68 2e 68 6f 6d 65 01 04 02 04 0b 16 32 08 0c 12 18 24 30 48 60 6c dd 16 00 50 f2 01 01 00 00 50 f2 02 01 00 00 50 f2 02 01 00 00 50 f2 02
resp_ies - hexdump(len=16): 01 04 82 84 8b 96 32 08 0c 12 18 24 30 48 60 6c
WPA: set own WPA/RSN IE - hexdump(len=24): dd 16 00 50 f2 01 01 00 00 50 f2 02 01 00 00 50 f2 02 01 00 00 50 f2 02
State: ASSOCIATING -> ASSOCIATED
wpa_driver_wext_set_operstate: operstate 0->0 (DORMANT)
WEXT: Operstate: linkmode=-1, operstate=5
Associated to a new BSS: BSSID=00:15:0c:d6:c7:74
No keys have been configured - skip key clearing
Associated with 00:15:0c:d6:c7:74
WPA: Association event - clear replay counter
EAPOL: External notification - portEnabled=0
EAPOL: External notification - portValid=0
EAPOL: External notification - EAP success=0
EAPOL: External notification - portEnabled=1
EAPOL: SUPP_PAE entering state CONNECTING
EAPOL: SUPP_BE entering state IDLE
Setting authentication timeout: 10 sec 0 usec
Cancelling scan request
RX EAPOL from 00:15:0c:d6:c7:74
RX EAPOL - hexdump(len=99): 01 03 00 5f fe 00 89 00 20 00 00 00 00 00 00 00 01 33 dc ab 99 77 cb 37 23 57 10 d9 11 91 cf 06 17 49 f0 27 c7 a4 d3 9b fd b3 ab 25 fe 27 49 fa 48 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
Setting authentication timeout: 10 sec 0 usec
IEEE 802.1X RX: version=1 type=3 length=95
  EAPOL-Key type=254
  key_info 0x89 (ver=1 keyidx=0 rsvd=0 Pairwise Ack)
  key_length=32 key_data_length=0
  replay_counter - hexdump(len=8): 00 00 00 00 00 00 00 01
  key_nonce - hexdump(len=32): 33 dc ab 99 77 cb 37 23 57 10 d9 11 91 cf 06 17 49 f0 27 c7 a4 d3 9b fd b3 ab 25 fe 27 49 fa 48
  key_iv - hexdump(len=16): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  key_rsc - hexdump(len=8): 00 00 00 00 00 00 00 00
  key_id (reserved) - hexdump(len=8): 00 00 00 00 00 00 00 00
  key_mic - hexdump(len=16): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
WPA: RX EAPOL-Key - hexdump(len=99): 01 03 00 5f fe 00 89 00 20 00 00 00 00 00 00 00 01 33 dc ab 99 77 cb 37 23 57 10 d9 11 91 cf 06 17 49 f0 27 c7 a4 d3 9b fd b3 ab 25 fe 27 49 fa 48 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
State: ASSOCIATED -> 4WAY_HANDSHAKE
WPA: RX message 1 of 4-Way Handshake from 00:15:0c:d6:c7:74 (ver=1)
WPA: Renewed SNonce - hexdump(len=32): 2e e3 7a cc cd 1e 3f e1 17 76 10 f1 8b 6e dc 53 5f c0 31 b9 71 40 e2 7b a3 04 75 0c 66 9d 95 01
WPA: PMK - hexdump(len=32): 44 49 84 4d 00 d4 0c 0a 3a bd 2e 33 89 3b d2 39 bc e2 5c 9c 81 38 43 64 6c 9b c0 4b 00 34 5c e5
WPA: PTK - hexdump(len=64): 7c d3 49 82 93 2d fc 6f 23 41 7c 1b 33 cf 5d be c1 2f a2 39 d5 76 c1 20 e9 b3 b1 18 3e 9e 45 74 c2 b7 cb b8 b6 ae ab 63 d3 fd 23 b6 cb 6c 2b 11 1d eb 7a 29 09 97 da fa a4 ea e3 b5 0c a2 af 22
WPA: WPA IE for msg 2/4 - hexdump(len=24): dd 16 00 50 f2 01 01 00 00 50 f2 02 01 00 00 50 f2 02 01 00 00 50 f2 02
WPA: Sending EAPOL-Key 2/4
WPA: TX EAPOL-Key - hexdump(len=123): 01 03 00 77 fe 01 09 00 20 00 00 00 00 00 00 00 01 2e e3 7a cc cd 1e 3f e1 17 76 10 f1 8b 6e dc 53 5f c0 31 b9 71 40 e2 7b a3 04 75 0c 66 9d 95 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 e7 8f 0a 5a 75 f2 89 57 b0 1a 05 ce 6a 8d 81 bc 00 18 dd 16 00 50 f2 01 01 00 00 50 f2 02 01 00 00 50 f2 02 01 00 00 50 f2 02
RX EAPOL from 00:15:0c:d6:c7:74
RX EAPOL - hexdump(len=125): 01 03 00 79 fe 01 c9 00 20 00 00 00 00 00 00 00 02 33 dc ab 99 77 cb 37 23 57 10 d9 11 91 cf 06 17 49 f0 27 c7 a4 d3 9b fd b3 ab 25 fe 27 49 fa 48 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 9a ab b0 de f9 2d d0 1f ca e3 17 b6 45 05 f2 bf 00 1a dd 18 00 50 f2 01 01 00 00 50 f2 02 01 00 00 50 f2 02 01 00 00 50 f2 02 00 00
IEEE 802.1X RX: version=1 type=3 length=121
  EAPOL-Key type=254
  key_info 0x1c9 (ver=1 keyidx=0 rsvd=0 Pairwise Install Ack MIC)
  key_length=32 key_data_length=26
  replay_counter - hexdump(len=8): 00 00 00 00 00 00 00 02
  key_nonce - hexdump(len=32): 33 dc ab 99 77 cb 37 23 57 10 d9 11 91 cf 06 17 49 f0 27 c7 a4 d3 9b fd b3 ab 25 fe 27 49 fa 48
  key_iv - hexdump(len=16): 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  key_rsc - hexdump(len=8): 00 00 00 00 00 00 00 00
  key_id (reserved) - hexdump(len=8): 00 00 00 00 00 00 00 00
  key_mic - hexdump(len=16): 9a ab b0 de f9 2d d0 1f ca e3 17 b6 45 05 f2 bf
WPA: RX EAPOL-Key - hexdump(len=125): 01 03 00 79 fe 01 c9 00 20 00 00 00 00 00 00 00 02 33 dc ab 99 77 cb 37 23 57 10 d9 11 91 cf 06 17 49 f0 27 c7 a4 d3 9b fd b3 ab 25 fe 27 49 fa 48 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 9a ab b0 de f9 2d d0 1f ca e3 17 b6 45 05 f2 bf 00 1a dd 18 00 50 f2 01 01 00 00 50 f2 02 01 00 00 50 f2 02 01 00 00 50 f2 02 00 00
State: 4WAY_HANDSHAKE -> 4WAY_HANDSHAKE
WPA: RX message 3 of 4-Way Handshake from 00:15:0c:d6:c7:74 (ver=1)
WPA: IE KeyData - hexdump(len=26): dd 18 00 50 f2 01 01 00 00 50 f2 02 01 00 00 50 f2 02 01 00 00 50 f2 02 00 00
WPA: Sending EAPOL-Key 4/4
WPA: TX EAPOL-Key - hexdump(len=99): 01 03 00 5f fe 01 09 00 20 00 00 00 00 00 00 00 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0e bb 0b 30 e4 9f aa f4 ba 44 93 4c 01 68 d3 97 00 00
WPA: Installing PTK to the driver.
WPA: RSC - hexdump(len=6): 00 00 00 00 00 00
wpa_driver_wext_set_key: alg=2 key_idx=0 set_tx=1 seq_len=6 key_len=32
State: 4WAY_HANDSHAKE -> GROUP_HANDSHAKE
RX EAPOL from 00:15:0c:d6:c7:74
RX EAPOL - hexdump(len=131): 01 03 00 7f fe 03 a1 00 20 00 00 00 00 00 00 00 03 33 dc ab 99 77 cb 37 23 57 10 d9 11 91 cf 06 17 49 f0 27 c7 a4 d3 9b fd b3 ab 25 fe 27 49 fa 47 49 f0 27 c7 a4 d3 9b fd b3 ab 25 fe 27 49 fa 49 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 2b a2 ed 59 9c 0f e7 1e 70 ba 81 11 44 29 8d 13 00 20 14 72 27 88 67 7e e5 bd e0 fb 45 25 aa ea f5 a3 9a f1 86 35 18 f4 95 e7 71 b6 c0 c1 62 ba 80 97
IEEE 802.1X RX: version=1 type=3 length=127
  EAPOL-Key type=254
  key_info 0x3a1 (ver=1 keyidx=2 rsvd=0 Group Ack MIC Secure)
  key_length=32 key_data_length=32
  replay_counter - hexdump(len=8): 00 00 00 00 00 00 00 03
  key_nonce - hexdump(len=32): 33 dc ab 99 77 cb 37 23 57 10 d9 11 91 cf 06 17 49 f0 27 c7 a4 d3 9b fd b3 ab 25 fe 27 49 fa 47
  key_iv - hexdump(len=16): 49 f0 27 c7 a4 d3 9b fd b3 ab 25 fe 27 49 fa 49
  key_rsc - hexdump(len=8): 00 00 00 00 00 00 00 00
  key_id (reserved) - hexdump(len=8): 00 00 00 00 00 00 00 00
  key_mic - hexdump(len=16): 2b a2 ed 59 9c 0f e7 1e 70 ba 81 11 44 29 8d 13
WPA: RX EAPOL-Key - hexdump(len=131): 01 03 00 7f fe 03 a1 00 20 00 00 00 00 00 00 00 03 33 dc ab 99 77 cb 37 23 57 10 d9 11 91 cf 06 17 49 f0 27 c7 a4 d3 9b fd b3 ab 25 fe 27 49 fa 47 49 f0 27 c7 a4 d3 9b fd b3 ab 25 fe 27 49 fa 49 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 2b a2 ed 59 9c 0f e7 1e 70 ba 81 11 44 29 8d 13 00 20 14 72 27 88 67 7e e5 bd e0 fb 45 25 aa ea f5 a3 9a f1 86 35 18 f4 95 e7 71 b6 c0 c1 62 ba 80 97
WPA: RX message 1 of Group Key or STAKey Handshake from 00:15:0c:d6:c7:74 (ver=1)
State: GROUP_HANDSHAKE -> GROUP_HANDSHAKE
WPA: Group Key - hexdump(len=32): 4e 6c c3 3d 3a c5 a6 49 db 31 9d ab 2e b7 15 6f 38 e9 0a ef 7d 14 7a da a0 fa cb 3e c5 c1 b8 b6
WPA: Installing GTK to the driver (keyidx=2 tx=0).
WPA: RSC - hexdump(len=6): 00 00 00 00 00 00
wpa_driver_wext_set_key: alg=2 key_idx=2 set_tx=0 seq_len=6 key_len=32
WPA: Sending EAPOL-Key 2/2
WPA: TX EAPOL-Key - hexdump(len=99): 01 03 00 5f fe 03 21 00 20 00 00 00 00 00 00 00 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 59 fb ed dc 79 e9 fd 4f 65 e1 41 67 42 97 c8 58 00 00
WPA: Key negotiation completed with 00:15:0c:d6:c7:74 [PTK=TKIP GTK=TKIP]
Cancelling authentication timeout
State: GROUP_HANDSHAKE -> COMPLETED
CTRL-EVENT-CONNECTED - Connection to 00:15:0c:d6:c7:74 completed (auth) [id=0 id_str=]
wpa_driver_wext_set_operstate: operstate 0->1 (UP)
WEXT: Operstate: linkmode=-1, operstate=6
EAPOL: External notification - portValid=1
EAPOL: External notification - EAP success=1
EAPOL: SUPP_PAE entering state AUTHENTICATING
EAPOL: SUPP_BE entering state SUCCESS
EAP: EAP entering state DISABLED
EAPOL: SUPP_PAE entering state AUTHENTICATED
EAPOL: SUPP_BE entering state IDLE
RTM_NEWLINK: operstate=1 ifi_flags=0x11043 ([UP][RUNNING][LOWER_UP])
RTM_NEWLINK, IFLA_IFNAME: Interface 'wlan0' added
RX EAPOL from 00:15:0c:d6:c7:74
RX EAPOL - hexdump(len=131): 01 03 00 7f fe 03 a1 00 20 00 00 00 00 00 00 00 04 33 dc ab 99 77 cb 37 23 57 10 d9 11 91 cf 06 17 49 f0 27 c7 a4 d3 9b fd b3 ab 25 fe 27 49 fa 47 49 f0 27 c7 a4 d3 9b fd b3 ab 25 fe 27 49 fa 49 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 64 97 6b 70 91 95 9e c6 ab 10 f1 d0 61 1d 55 7c 00 20 14 72 27 88 67 7e e5 bd e0 fb 45 25 aa ea f5 a3 9a f1 86 35 18 f4 95 e7 71 b6 c0 c1 62 ba 80 97
IEEE 802.1X RX: version=1 type=3 length=127
  EAPOL-Key type=254
  key_info 0x3a1 (ver=1 keyidx=2 rsvd=0 Group Ack MIC Secure)
  key_length=32 key_data_length=32
  replay_counter - hexdump(len=8): 00 00 00 00 00 00 00 04
  key_nonce - hexdump(len=32): 33 dc ab 99 77 cb 37 23 57 10 d9 11 91 cf 06 17 49 f0 27 c7 a4 d3 9b fd b3 ab 25 fe 27 49 fa 47
  key_iv - hexdump(len=16): 49 f0 27 c7 a4 d3 9b fd b3 ab 25 fe 27 49 fa 49
  key_rsc - hexdump(len=8): 00 00 00 00 00 00 00 00
  key_id (reserved) - hexdump(len=8): 00 00 00 00 00 00 00 00
  key_mic - hexdump(len=16): 64 97 6b 70 91 95 9e c6 ab 10 f1 d0 61 1d 55 7c
WPA: RX EAPOL-Key - hexdump(len=131): 01 03 00 7f fe 03 a1 00 20 00 00 00 00 00 00 00 04 33 dc ab 99 77 cb 37 23 57 10 d9 11 91 cf 06 17 49 f0 27 c7 a4 d3 9b fd b3 ab 25 fe 27 49 fa 47 49 f0 27 c7 a4 d3 9b fd b3 ab 25 fe 27 49 fa 49 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 64 97 6b 70 91 95 9e c6 ab 10 f1 d0 61 1d 55 7c 00 20 14 72 27 88 67 7e e5 bd e0 fb 45 25 aa ea f5 a3 9a f1 86 35 18 f4 95 e7 71 b6 c0 c1 62 ba 80 97
WPA: RX message 1 of Group Key or STAKey Handshake from 00:15:0c:d6:c7:74 (ver=1)
State: COMPLETED -> GROUP_HANDSHAKE
WPA: Group Key - hexdump(len=32): 4e 6c c3 3d 3a c5 a6 49 db 31 9d ab 2e b7 15 6f 38 e9 0a ef 7d 14 7a da a0 fa cb 3e c5 c1 b8 b6
WPA: Installing GTK to the driver (keyidx=2 tx=0).
WPA: RSC - hexdump(len=6): 00 00 00 00 00 00
wpa_driver_wext_set_key: alg=2 key_idx=2 set_tx=0 seq_len=6 key_len=32
WPA: Sending EAPOL-Key 2/2
WPA: TX EAPOL-Key - hexdump(len=99): 01 03 00 5f fe 03 21 00 20 00 00 00 00 00 00 00 04 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1e 1a 45 42 95 40 d8 d7 ab b5 58 53 40 e0 5a e8 00 00
WPA: Group rekeying completed with 00:15:0c:d6:c7:74 [GTK=TKIP]
State: GROUP_HANDSHAKE -> COMPLETED
EAPOL: startWhen --> 0
CTRL-EVENT-TERMINATING - signal 2 received
Removing interface wlan0
State: COMPLETED -> DISCONNECTED
wpa_driver_wext_set_operstate: operstate 1->0 (DORMANT)
WEXT: Operstate: linkmode=-1, operstate=5
wpa_driver_wext_deauthenticate
wpa_driver_wext_set_key: alg=0 key_idx=0 set_tx=0 seq_len=0 key_len=0
wpa_driver_wext_set_key: alg=0 key_idx=1 set_tx=0 seq_len=0 key_len=0
wpa_driver_wext_set_key: alg=0 key_idx=2 set_tx=0 seq_len=0 key_len=0
wpa_driver_wext_set_key: alg=0 key_idx=3 set_tx=0 seq_len=0 key_len=0
wpa_driver_wext_set_key: alg=0 key_idx=0 set_tx=0 seq_len=0 key_len=0
EAPOL: External notification - portEnabled=0
EAPOL: SUPP_PAE entering state DISCONNECTED
EAPOL: SUPP_BE entering state INITIALIZE
EAPOL: External notification - portValid=0
wpa_driver_wext_set_wpa
wpa_driver_wext_set_drop_unencrypted
wpa_driver_wext_set_countermeasures
No keys have been configured - skip key clearing
WEXT: Operstate: linkmode=0, operstate=6
Cancelling scan request

--------------040909080609040307000206
Content-Type: text/plain;
 name="we.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="we.log"

DRIVER NDISWRAPPER:

[root@caelum space]# iwconfig -v 
iwconfig  Wireless-Tools version 29
          Compatible with Wireless Extension v11 to v21.

Kernel    Currently compiled with Wireless Extension v21.

wlan0     Recommend Wireless Extension v18 or later,
          Currently compiled with Wireless Extension v21.

[root@caelum space]#

----------------------------------------------------------

DRIVER PRISM54:

[root@caelum space]# iwconfig -v
iwconfig  Wireless-Tools version 29
          Compatible with Wireless Extension v11 to v21.

Kernel    Currently compiled with Wireless Extension v21.

eth1      Recommend Wireless Extension v19 or later,
          Currently compiled with Wireless Extension v21.

[root@caelum space]# 



--------------040909080609040307000206--
