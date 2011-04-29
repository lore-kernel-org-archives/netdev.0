From: Florian Westphal <fw@strlen.de>
Subject: IPv6 PREFSRC behaves different than IPv4 PREFSRC?
Date: Fri, 29 Apr 2011 10:09:16 +0200
Message-ID: <20110429080916.GB11260@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Walter <sahne@0x90.at>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:37810 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755551Ab1D2IJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 04:09:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I tested todays net-next and tried to use the new ipv6 prefsrc
patch that went in this month.

But as far as I can say it does not work, or at least
the behaviour I see is unexpected.

Test setup:
eth0 has addresses 192.168.10.100/24 and dead:1::100/64

With IPv4,
I get this behaviour:

$ ip addr add  192.168.10.101 dev eth0
$ ip route get 192.168.10.1
192.168.10.1 dev eth0  src 192.168.10.100
    cache
$ ip route add 192.168.10.1 src 192.168.10.101 dev eth0
$ ip route get 192.168.10.1
192.168.10.1 dev eth0  src 192.168.10.101
     cache
$ ip route get  192.168.10.2
192.168.10.2 dev eth0  src 192.168.10.100
    cache

And that is what I would have expected... But with ipv6 the behaviour
differs:

ipv6
$ ip route get dead:1::1
dead:1::1 via dead:1::1 dev eth0  src dead:1::100  metric 0
    cache
$ ip addr add dead:1::101/64 dev eth0
$ ip route add dead:1::1 src dead:1::101
$ ip route get dead:1::1
dead:1::1 via dead:1::1 dev eth0  src dead:1::101  metric 0
    cache

$ ip route add dead:1::2 src dead:1::100
$ ip route get dead:1::2
dead:1::2 via dead:1::2 dev eth0  src dead:1::101  metric 0

-> src is dead:1:101, and not 100 as I had expected...

This behaviour is rather irritating.
What am I doing wrong?

Thanks,
Florian
