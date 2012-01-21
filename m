From: Tom Gundersen <teg@jklm.no>
Subject: Possible 3.3-rc1 regression: "ICMPv6 RA: ndisc_router_discovery()
 failed to add default route."
Date: Sat, 21 Jan 2012 18:37:13 +0100
Message-ID: <CAG-2HqUBLN42REv1oojO0dD7nuVuM65_c3YQEF_gfByF0YbRMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:39351 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846Ab2AURhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2012 12:37:35 -0500
Received: by wgbgn7 with SMTP id gn7so387405wgb.1
        for <netdev@vger.kernel.org>; Sat, 21 Jan 2012 09:37:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys,

I'm getting a new error message in dmesg as of 3.3-rc1. Let me know if
you need any additional info:

# dmesg -level=err -kernel | grep ICMP
[  400.472561] ICMPv6 RA: ndisc_router_discovery() failed to add default route.
[  700.174416] ICMPv6 RA: ndisc_router_discovery() failed to add default route.
[  902.743138] ICMPv6 RA: ndisc_router_discovery() failed to add default route.
[ 1590.414022] ICMPv6 RA: ndisc_router_discovery() failed to add default route.
[ 2183.924517] ICMPv6 RA: ndisc_router_discovery() failed to add default route.
[ 2470.567114] ICMPv6 RA: ndisc_router_discovery() failed to add default route.
[ 2988.283030] ICMPv6 RA: ndisc_router_discovery() failed to add default route.
[ 3365.451899] ICMPv6 RA: ndisc_router_discovery() failed to add default route.
[ 4254.981325] ICMPv6 RA: ndisc_router_discovery() failed to add default route.
[ 4593.022162] ICMPv6 RA: ndisc_router_discovery() failed to add default route.
[ 5145.391054] ICMPv6 RA: ndisc_router_discovery() failed to add default route.
[ 5821.066689] ICMPv6 RA: ndisc_router_discovery() failed to add default route.
[ 6030.083974] ICMPv6 RA: ndisc_router_discovery() failed to add default route.
[ 6415.757530] ICMPv6 RA: ndisc_router_discovery() failed to add default route.
[ 6920.336755] ICMPv6 RA: ndisc_router_discovery() failed to add default route.
[ 7616.524676] ICMPv6 RA: ndisc_router_discovery() failed to add default route.
[ 8574.824201] ICMPv6 RA: ndisc_router_discovery() failed to add default route.
[ 9041.117907] ICMPv6 RA: ndisc_router_discovery() failed to add default route.
[ 9528.942178] ICMPv6 RA: ndisc_router_discovery() failed to add default route.
[10068.660634] ICMPv6 RA: ndisc_router_discovery() failed to add default route.

# ip addr show dev eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP qlen 1000
    link/ether 00:1d:60:67:1d:8e brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.43/24 brd 192.168.1.255 scope global eth0
    inet6 2a01:e35:2f24:93f0:21d:60ff:fe67:1d8e/64 scope global dynamic
       valid_lft 85815sec preferred_lft 85815sec
    inet6 fe80::21d:60ff:fe67:1d8e/64 scope link
       valid_lft forever preferred_lft forever

# ip route show
default via 192.168.1.254 dev eth0  proto static
192.168.1.0/24 dev eth0  proto kernel  scope link  src 192.168.1.43  metric 1

Cheers,

Tom
