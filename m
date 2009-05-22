From: Antonio Almeida <vexwek@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Fri, 22 May 2009 18:42:16 +0100
Message-ID: <298f5c050905221042t45017c5q8bc967d13c9b81cb@mail.gmail.com>
References: <20090517201528.GA8552@ami.dom.local>
	 <20090518065629.GA6006@ff.dom.local>
	 <298f5c050905180954m791c14eaxe1f4b2c92f952a2f@mail.gmail.com>
	 <298f5c050905181016w552b283q2bb2ec508433525a@mail.gmail.com>
	 <20090521085116.GC2892@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, devik@cdi.cz,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:10181 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753488AbZEVRmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2009 13:42:16 -0400
Received: by yx-out-2324.google.com with SMTP id 3so1104548yxj.1
        for <netdev@vger.kernel.org>; Fri, 22 May 2009 10:42:17 -0700 (PDT)
In-Reply-To: <20090521085116.GC2892@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 21, 2009 at 9:51 AM, Jarek Poplawski wrote:
> I still have no clue about the reason, but it would be really nice to
> do some short test with more current kernel (>= 2.6.27) and iproute2
> (to exclude the possibility of some incomaptibility in configs e.g.
> rate tables passed to htb).

I installed kernel 2.6.29 (finaly! wasn't easy... I couldn't set
memory split 2G/2G),
but the results are the same. I've already applied gen_estimator.c
patches (works fine).

# tc -s -d class ls dev eth1 | head -24
class htb 1:1 root rate 900000Kbit ceil 900000Kbit burst 113962b/8 mpu
0b overhead 0b cburst 113962b/8 mpu 0b overhead 0b level 7
 Sent 119955303928 bytes 150697618 pkt (dropped 0, overlimits 0 requeues 0)
 rate 621844Kbit 97651pps backlog 0b 0p requeues 0
 lended: 0 borrowed: 0 giants: 0
 tokens: 402 ctokens: 402

class htb 1:10 parent 1:2 rate 900000Kbit ceil 900000Kbit burst
113962b/8 mpu 0b overhead 0b cburst 113962b/8 mpu 0b overhead 0b level
5
 Sent 119955303928 bytes 150697618 pkt (dropped 0, overlimits 0 requeues 0)
 rate 621844Kbit 97651pps backlog 0b 0p requeues 0
 lended: 0 borrowed: 0 giants: 0
 tokens: 402 ctokens: 402

class htb 1:108 parent 1:10 leaf 108: prio 7 quantum 1514 rate
555000Kbit ceil 555000Kbit burst 70901b/8 mpu 0b overhead 0b cburst
70901b/8 mpu 0b overhead 0b level 0
 Sent 119955366812 bytes 150697697 pkt (dropped 76696483, overlimits 0
requeues 0)
 rate 621847Kbit 97652pps backlog 0b 79p requeues 0
 lended: 150697618 borrowed: 0 giants: 0
 tokens: -5 ctokens: -5

class htb 1:2 parent 1:1 rate 900000Kbit ceil 900000Kbit burst
113962b/8 mpu 0b overhead 0b cburst 113962b/8 mpu 0b overhead 0b level
6
 Sent 119955303928 bytes 150697618 pkt (dropped 0, overlimits 0 requeues 0)
 rate 621844Kbit 97651pps backlog 0b 0p requeues 0
 lended: 0 borrowed: 0 giants: 0
 tokens: 402 ctokens: 402


# cat /sys/module/sch_htb/parameters/htb_hysteresis
0

# ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: off
udp fragmentation offload: off
generic segmentation offload: off

# ethtool -k eth1
Offload parameters for eth1:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: off
udp fragmentation offload: off
generic segmentation offload: off


I'm working on a newer iproute2.


  Antonio Almeida
