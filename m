From: Antonio Almeida <vexwek@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Tue, 19 May 2009 15:31:30 +0100
Message-ID: <298f5c050905190731xf7e5f10v940ea731ef472443@mail.gmail.com>
References: <20090517201528.GA8552@ami.dom.local>
	 <200905191404.50464.denys@visp.net.lb>
	 <20090519111857.GC5521@ff.dom.local>
	 <200905191421.28519.denys@visp.net.lb>
	 <20090519112828.GA6918@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, devik@cdi.cz,
	Eric Dumazet <dada1@cosmosbay.com>
To: Jarek Poplawski <jarkao2@gmail.com>,
	Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:37812 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212AbZESOba convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 10:31:30 -0400
Received: by yx-out-2324.google.com with SMTP id 3so2414444yxj.1
        for <netdev@vger.kernel.org>; Tue, 19 May 2009 07:31:31 -0700 (PDT)
In-Reply-To: <20090519112828.GA6918@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I tested it with BFIFO using limit 6875000. (Analyser keeps sending
950Mbits/s of 800 bytes tcp packets - lots of drops for sure)
Backlog is now huge but the throughout stays much higher than the
configured ceil.

# tc -s -d class ls dev eth1
class htb 1:10 parent 1:2 rate 900000Kbit ceil 900000Kbit burst
113962b/8 mpu 0b overhead 0b cburst 113962b/8 mpu 0b overhead 0b level
5
 Sent 9542831672 bytes 11988482 pkt (dropped 0, overlimits 0 requeues 0=
)
 rate 621765Kbit 97639pps backlog 0b 0p requeues 0
 lended: 0 borrowed: 0 giants: 0
 tokens: -186 ctokens: -186

class htb 1:1 root rate 900000Kbit ceil 900000Kbit burst 113962b/8 mpu
0b overhead 0b cburst 113962b/8 mpu 0b overhead 0b level 7
 Sent 9542831672 bytes 11988482 pkt (dropped 0, overlimits 0 requeues 0=
)
 rate 621765Kbit 97639pps backlog 0b 0p requeues 0
 lended: 0 borrowed: 0 giants: 0
 tokens: -186 ctokens: -186

class htb 1:2 parent 1:1 rate 900000Kbit ceil 900000Kbit burst
113962b/8 mpu 0b overhead 0b cburst 113962b/8 mpu 0b overhead 0b level
6
 Sent 9542831672 bytes 11988482 pkt (dropped 0, overlimits 0 requeues 0=
)
 rate 621765Kbit 97639pps backlog 0b 0p requeues 0
 lended: 0 borrowed: 0 giants: 0
 tokens: -186 ctokens: -186

class htb 1:108 parent 1:10 leaf 108: prio 7 quantum 1514 rate
555000Kbit ceil 555000Kbit burst 70901b/8 mpu 0b overhead 0b cburst
70901b/8 mpu 0b overhead 0b level 0
 Sent 9549705928 bytes 11997118 pkt (dropped 6092846, overlimits 0 requ=
eues 0)
 rate 621764Kbit 97639pps backlog 0b 8636p requeues 0
 lended: 11988482 borrowed: 0 giants: 0
 tokens: -1008 ctokens: -1008



# tc -s -d qdisc ls dev eth1
qdisc htb 1: root r2q 10 default 0 direct_packets_stat 11955 ver 3.17
 Sent 9608660872 bytes 12071182 pkt (dropped 6124502, overlimits
18190041 requeues 0)
 rate 0bit 0pps backlog 0b 8636p requeues 0
qdisc bfifo 108: parent 1:108 limit 6875000b
 Sent 9599144692 bytes 12059227 pkt (dropped 6124502, overlimits 0 requ=
eues 0)
 rate 0bit 0pps backlog 6874256b 8636p requeues 0


  Antonio Almeida



On Tue, May 19, 2009 at 12:28 PM, Jarek Poplawski <jarkao2@gmail.com> w=
rote:
> On Tue, May 19, 2009 at 02:21:28PM +0300, Denys Fedoryschenko wrote:
>> On Tuesday 19 May 2009 14:18:57 Jarek Poplawski wrote:
>> >
>> > Sure, if the queue is too short we could have a problem with reach=
ing
>> > the expected rate; but here it's all backwards - it could actually
>> > "help" with the stats. ;-)
>> >
>> > Jarek P.
>> Well, i had real experience on HTB, when i set too short buffers on =
=A0my QoS
>> qdiscs, the incoming rate jumped too high than overall. When i set l=
arger
>> buffers (and by the way dropped sfq and use bfifo) - it is dropped. =
=A0No idea
>> why, bug or specific things in =A0protocols congestion control. Mayb=
e worth to
>> try...
>>
>
> Very strange. Anyway, "overlimits 0" suggests HTB always got packets
> when it needed...
>
> Jarek P.
>
