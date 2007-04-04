From: "Denys" <denys@visp.net.lb>
Subject: one more... iproute commands lockup whole system
Date: Wed, 4 Apr 2007 03:03:12 +0300
Message-ID: <20070404000054.M58020@visp.net.lb>
References: <20070321175951.M73913@visp.net.lb> <46026717.9060909@trash.net> <20070322124533.M79867@visp.net.lb> <46027FF2.6020001@trash.net> <20070322101224.3e6bb899@freekitty>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:55638 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992500AbXDDAMC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2007 20:12:02 -0400
In-Reply-To: <20070322101224.3e6bb899@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm not sure it is mistake or error, but i feel it is dangerous, cause 
commands locking up the system, no kernel panic, no oops, so only watchdog 
can save poor server (and not sure this even)

Commands to lockup system (just i am giving my example, i didnt sort out what 
exactly locked up system, i guess redirecting to eth0.5, which is not 
intended for that):

vconfig add eth0 5
ifconfig eth0.5 192.168.1.2 netmask 255.255.255.128

tc qdisc add dev eth0 ingress
tc filter add dev eth0 parent ffff: protocol ip prio 6 u32 \
match ip src 195.69.208.252/32 flowid 1:16 \
action police rate 64kbit burst 90k pipe \
action mirred egress mirror dev eth0.5

--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

