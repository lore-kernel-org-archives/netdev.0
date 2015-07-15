From: Phil Sutter <phil@nwl.cc>
Subject: Sending IPv6 packets broken in net-next
Date: Thu, 16 Jul 2015 00:20:46 +0200
Message-ID: <20150715222046.GE14670@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: YOSHIFUJI =?utf-8?B?SGlkZWFraS/lkInol6Toi7HmmI4=?=
	<hideaki.yoshifuji@miraclelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:49554 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753121AbbGOWUs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jul 2015 18:20:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Commit 9131f3d ("ipv6: Do not iterate over all interfaces when finding
source address on specific interface") breaks local output of IPv6
packets. Here is a simple reproducer:

---- 8< -----
ip link add eth6 type veth peer name eth7
ip netns add test
ip link set eth7 netns test
ip netns exec test ip link set eth7 up
ip netns exec test ip a a feed:babe::1/64 dev eth7

ip link set eth6 up
ip a a feed:babe::2/64 dev eth6

ping6 feed:babe::1
---- 8< -----

Output from 'tcpdump -npi eth6':

| 00:08:24.214584 IP6 :: > feed:babe::1: ICMP6, echo request, seq 22, length 64
| 00:08:25.214540 IP6 :: > feed:babe::1: ICMP6, echo request, seq 23, length 64

Cheers, Phil
