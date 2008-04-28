From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: 2.6.25 crash: EIP: [<c02e2f14>] xfrm_output_resume+0x64/0x100 ss:esp 0068:c03a1e5c
Date: Mon, 28 Apr 2008 12:18:59 +0200
Message-ID: <BAY103-DAV16C270BEEB34A42A676B1B2DE0@phx.gbl>
References: <BAY103-DAV11F874912A45144805FC26B2DE0@phx.gbl> <20080428.024208.153440332.davem@davemloft.net>
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	"Marco Berizzi" <pupilla@hotmail.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc2-s7.bay0.hotmail.com ([65.54.246.143]:8784 "EHLO
	bay0-omc2-s7.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752618AbYD1KVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 06:21:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

> Netdev added to CC:, please include in all bug reports as
> that's where the networking developers sit.

ok.
Two different systems have crashed since
2.6.25 upgrade (I upgraded a total of 8
systems).

For now, the only two boxes that crashed
have these modules loaded (where the other
systems doesn't have these modules loaded):

sch_sfq 6088 3
sch_htb 15208 1
cls_fw 3848 1

Here is the script for setup htb (which classify
traffic inside the ipsec tunnels):

tc qdisc add dev eth0 root handle 1:0 htb default 11

tc class add dev eth0 parent 1:0 classid 1:1 htb rate 1700kbit ceil
1700kbit burst 15k
tc class add dev eth0 parent 1:1 classid 1:10 htb rate 200kbit ceil
400kbit burst 5k
tc class add dev eth0 parent 1:1 classid 1:11 htb rate 600kbit ceil
1600kbit burst 5k
tc class add dev eth0 parent 1:1 classid 1:12 htb rate 800kbit ceil
1700kbit burst 15k
tc qdisc add dev eth0 parent 1:10 handle 10:0 sfq perturb 10
tc qdisc add dev eth0 parent 1:11 handle 20:0 sfq perturb 5
tc qdisc add dev eth0 parent 1:12 handle 30:0 sfq perturb 10

FW="tc filter add dev eth0 protocol ip parent 1:0 prio 1"
$FW handle 110 fw flowid 1:10
$FW handle 111 fw flowid 1:11
$FW handle 112 fw flowid 1:12


