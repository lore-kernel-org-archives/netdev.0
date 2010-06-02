From: Johannes Berg <johannes@sipsolutions.net>
Subject: sysfs class/net/ problem
Date: Wed, 02 Jun 2010 15:16:51 +0200
Message-ID: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:55423 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757704Ab0FBNQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 09:16:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I didn't find anything related in the archives, if I missed it I'd
appreciate a pointer. I'm currently experiencing the following:

# ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN qlen 1000
    link/ether 52:54:00:12:34:56 brd ff:ff:ff:ff:ff:ff
# ls -l /sys/class/net/
total 0
lrwxrwxrwx 1 root root 0 Jun  2 13:12 eth0 -> ../../devices/pci0000:00/0000:00:03.0/net/eth0
lrwxrwxrwx 1 root root 0 Jun  2 13:12 lo -> ../../devices/virtual/net/lo
# insmod cfg80211.ko ; insmod mac80211.ko ; insmod mac80211_hwsim.ko  radios=3 
# ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN qlen 1000
    link/ether 52:54:00:12:34:56 brd ff:ff:ff:ff:ff:ff
5: wlan0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 02:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
6: wlan1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 02:00:00:00:01:00 brd ff:ff:ff:ff:ff:ff
7: wlan2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 02:00:00:00:02:00 brd ff:ff:ff:ff:ff:ff
8: hwsim0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN 
    link/ieee802.11/radiotap 12:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
# ls -l /sys/class/net/
total 0
lrwxrwxrwx 1 root root 0 Jun  2 13:12 eth0 -> ../../devices/pci0000:00/0000:00:03.0/net/eth0
lrwxrwxrwx 1 root root 0 Jun  2 13:14 hwsim0 -> ../../devices/virtual/net/hwsim0
lrwxrwxrwx 1 root root 0 Jun  2 13:12 lo -> ../../devices/virtual/net/lo
lrwxrwxrwx 1 root root 0 Jun  2 13:14 wlan0 -> ../../devices/virtual/mac80211_hwsim/hwsim0/wlan0
lrwxrwxrwx 1 root root 0 Jun  2 13:14 wlan1 -> ../../devices/virtual/mac80211_hwsim/hwsim1/wlan1
lrwxrwxrwx 1 root root 0 Jun  2 13:14 wlan2 -> ../../devices/virtual/mac80211_hwsim/hwsim2/wlan2
# rmmod mac80211_hwsim mac80211 cfg80211
# ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN qlen 1000
    link/ether 52:54:00:12:34:56 brd ff:ff:ff:ff:ff:ff
# ls -l /sys/class/net/
total 0
lrwxrwxrwx 1 root root 0 Jun  2 13:12 eth0 -> ../../devices/pci0000:00/0000:00:03.0/net/eth0
lrwxrwxrwx 1 root root 0 Jun  2 13:12 lo -> ../../devices/virtual/net/lo
lrwxrwxrwx 1 root root 0 Jun  2 13:14 wlan0 -> ../../devices/virtual/mac80211_hwsim/hwsim0/wlan0
lrwxrwxrwx 1 root root 0 Jun  2 13:14 wlan1 -> ../../devices/virtual/mac80211_hwsim/hwsim1/wlan1
lrwxrwxrwx 1 root root 0 Jun  2 13:14 wlan2 -> ../../devices/virtual/mac80211_hwsim/hwsim2/wlan2


The same problem doesn't happen with veth, so I'm not sure what's
causing the problem.

Help please?

johannes

