From: Daniel Wagner <wagi@monom.org>
Subject: No local loopback for mac80211_hwsim test setup
Date: Fri, 3 Apr 2009 14:38:22 +0200
Message-ID: <20090403123822.GA26100@toronto053.server4you.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from toronto053.server4you.de ([62.75.220.53]:59109 "EHLO
	toronto053.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764988AbZDCNGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2009 09:06:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'd like to setup a wireless test network using the mac80211_hwsim
driver.  The main idea is to use one simulated device as access point
(e.g wlan13) and the other as normal station (e.g. wlan20).

I was able to get hostapd and dhcpd listining on wlan13 and handling the
request coming from wlan20. So after that the configuration looks like this:

[wagi@stardust ~]$ ip addr show dev wlan13
12: wlan13: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 02:00:00:00:03:00 brd ff:ff:ff:ff:ff:ff
    inet 10.0.13.1/32 scope global wlan13
    inet6 fe80::ff:fe00:300/64 scope link
       valid_lft forever preferred_lft forever

[wagi@stardust ~]$ ip addr show dev wlan20
26: wlan20: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 02:00:00:00:0a:00 brd ff:ff:ff:ff:ff:ff
    inet 10.0.13.10/24 brd 10.0.13.255 scope global wlan20
    inet6 fe80::ff:fe00:a00/64 scope link
       valid_lft forever preferred_lft forever

[wagi@stardust ~]$ ip route show
10.0.13.0/24 dev wlan20  proto kernel  scope link  src 10.0.13.10  metric 2
192.168.122.0/24 dev virbr0  proto kernel  scope link  src 192.168.122.1
192.168.0.0/16 dev eth0  proto kernel  scope link  src 192.168.101.53  metric 1
default via 192.168.0.254 dev eth0  proto static

[wagi@stardust ~]$ ip route show dev wlan13 table local
local 10.0.13.1  proto kernel  scope host  src 10.0.13.1

[wagi@stardust ~]$ ip route show dev wlan20 table local
local 10.0.13.10  proto kernel  scope host  src 10.0.13.10
broadcast 10.0.13.255  proto kernel  scope link  src 10.0.13.10
broadcast 10.0.13.0  proto kernel  scope link  src 10.0.13.10

If I 'ping 10.0.13.1' then the ip packets are not going through 
mac80211_hwsim because of the local route entry. So I tried
to remove this entry with the result that I know see:

[wagi@stardust ~]$ sudo tcpdump -i wlan13
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on wlan13, link-type EN10MB (Ethernet), capture size 96 bytes
14:31:05.431507 arp who-has 10.0.13.1 tell 10.0.13.10
14:31:05.431448 arp who-has 10.0.13.1 tell 10.0.13.10
14:31:06.431486 arp who-has 10.0.13.1 tell 10.0.13.10
...

Fidling with the arp entries was not helping either. I'm a bit at a
loss. I've searched the web, nothing found what helped.

So my question is this possible what I'd like to do? If so, what's the
trick to get it working?

thanks,
daniel





