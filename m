From: =?koi8-r?B?4c7Uz84=?= <Taoga@yandex.ru>
Subject: ar9280+802.11na+ath9k+kismet don't capture data packets
Date: Mon, 25 Apr 2011 21:54:32 +0400
Message-ID: <98231303754072@web63.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward1.mail.yandex.net ([77.88.46.6]:45094 "EHLO
	forward1.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756078Ab1DYSBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 14:01:21 -0400
Received: from web63.yandex.ru (web63.yandex.ru [77.88.46.54])
	by forward1.mail.yandex.net (Yandex) with ESMTP id 2C33B1240F43
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 21:54:34 +0400 (MSD)
Received: from localhost (localhost.localdomain [127.0.0.1])
	by web63.yandex.ru (Yandex) with ESMTP id 22953B1803A
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 21:54:34 +0400 (MSD)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

The platform uses D-link DIR-825 Atheros AR7161, with two AR9280(802.11=
bgn and 802.11an)
kismet-2010-07-R1 is installed to OpenWrt Backfire Trunk. Used driver a=
th9k of compat-wireless-2011-04-19.
=46or tests I use D-Link Dir-825 AP and D-Link DWA-160. Connection spee=
d is 300 Mbps at 36 channel.
Kismet captures PHY and Control packets, and don't capture the data pac=
kets.

/etc/config/wireless

config wifi-device radio0
option type mac80211
option channel 11
option macaddr 00:18:e7:ec:b0:5f
option hwmode 11ng
option hwmode_11n g
option htmode HT40+
list ht_capab HT40-
list ht_capab HT40+
list ht_capab HT20

config wifi-iface
option device radio0
option mode monitor

config wifi-device radio1
option type mac80211
option channel 36
option macaddr 00:18:e7:ec:b0:60
option hwmode 11na
option hwmode_11n a
option htmode HT40+
list ht_capab HT40-
list ht_capab HT40+
list ht_capab HT20

config wifi-iface
option device radio1
option mode monitor

device wlan0 entered promiscuous mode
device wlan1 entered promiscuous mode

iwconfig

wlan0 IEEE 802.11bgn Mode:Monitor Tx-Power=3D27 dBm
RTS thr:off Fragment thr:off
Power Management:on

wlan1 IEEE 802.11an Mode:Monitor Tx-Power=3D17 dBm
RTS thr:off Fragment thr:off
Power Management:on

Transferred to file 600 Mb
After that ifconfig issued:
ifconfig
wlan0 Link encap:UNSPEC HWaddr 00-18-E7-EC-B0-5F-00-47-00-00-00-00-00-0=
0-0
UP BROADCAST RUNNING PROMISC MULTICAST MTU:1500 Metric:1
RX packets:9865 errors:0 dropped:0 overruns:0 frame:0
TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:1000
RX bytes:3043414 (2.9 MiB) TX bytes:0 (0.0 B)

wlan1 Link encap:UNSPEC HWaddr 00-18-E7-EC-B0-60-00-47-00-00-00-00-00-0=
0-0
UP BROADCAST RUNNING PROMISC MULTICAST MTU:1500 Metric:1
RX packets:365275 errors:0 dropped:0 overruns:0 frame:0
TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:1000
RX bytes:20117793 (19.1 MiB) TX bytes:0 (0.0 B)

Sniffing result:
MAC Src =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9AMAC Dst =9A=9A=
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9AChannel Signal Type Crypt =9A=9A=
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9APackets SSID
00:18:E7:FD:8E:D8 =9A=9A00:19:5B:7E:09:CE =9A6 =9A=9A=9A=9A=9A=9A=9A=9A=
=9A-42 =9A=9A=9A=9A=9AAP =9A=9A=9AWEP =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A=9A=9A7629 =9A=9A=9A=9A=9Aq183
00:18:E7:FD:8E:DA =9AF0:7D:68:71:40:DC =9A36 =9A=9A=9A=9A=9A=9A=9A=9A-6=
0 =9A=9A=9A=9A=9AAP =9A=9A=9ATKIP WPA PSK... 1703 =9A=9A=9A=9A=9Aq183-m=
edia
1C:65:9D:21:27:8F =9A=9A=9A00:18:E7:FD:8E:D8 =9A=9A6 =9A=9A=9A=9A=9A=9A=
=9A=9A-65 =9A=9A=9A=9A=9AAP =9A=9A=9A=9AWEP =9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A2607 =9A=9A=9A=9A=9Aq183
00:00:00:00:00:00 =9A=9A=9A=9A00:18:E7:FD:8E:D8 =9A=9A- =9A=9A=9A=9A=9A=
=9A=9A=9A=9A-65 =9A=9A=9A=9A=9AAP =9A=9A=9A=9A- =9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A370415 =9A=9A-
00:19:5B:7E:09:CE =9A=9A00:18:E7:FD:8E:D8 =9A=9A- =9A=9A=9A=9A=9A=9A=9A=
=9A=9A-67 =9A=9A=9A=9A=9AProbe WEP =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A=9A124 =9A=9A=9A=9A=9A=9A=9Aq183
=460:7D:68:71:40:DC =9A=9A00:18:E7:FD:8E:DA =9A=9A- =9A=9A=9A=9A=9A=9A=9A=
=9A=9A-39 =9A=9A=9A=9AAP =9A=9A=9A=9A=9ATKIP WPA PSK... 41 =9A=9A=9A=9A=
=9A=9A=9A=9A=9Aq183-media

Captures the driver ath9k data packets in the mode 802.11na? Can be sai=
d about this with 100% certainty? Checked it?
