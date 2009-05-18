From: Antonio Almeida <vexwek@gmail.com>
Subject: Re: HTB accuracy for high speed
Date: Mon, 18 May 2009 13:05:32 +0100
Message-ID: <298f5c050905180505i2e8d7357ia64f67739c386adf@mail.gmail.com>
References: <298f5c050905150745p13dc226eia1ff50ffa8c4b300@mail.gmail.com>
	 <298f5c050905150749s3597328dr8dd15adbd7a37532@mail.gmail.com>
	 <20090516083158.GA3013@ami.dom.local>
	 <298f5c050905180339k77006e21ka0955958489c41c7@mail.gmail.com>
	 <20090518111411.GB11162@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net,
	devik@cdi.cz
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:56080 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260AbZERMFe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 08:05:34 -0400
Received: by fxm2 with SMTP id 2so3189191fxm.37
        for <netdev@vger.kernel.org>; Mon, 18 May 2009 05:05:32 -0700 (PDT)
In-Reply-To: <20090518111411.GB11162@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The analyser traffic is tcp. Setting tso off the accuracy stays the sam=
e

# ethtool -K eth0 tso off
# ethtool -K eth1 tso off

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


# tc -s -d class ls dev eth1 | head -24
class htb 1:10 parent 1:2 rate 900000Kbit ceil 900000Kbit burst
113962b/8 mpu 0b overhead 0b cburst 113962b/8 mpu 0b overhead 0b level
5
 Sent 164938012460 bytes 206824215 pkt (dropped 0, overlimits 0 requeue=
s 0)
 rate 652715Kbit 97655pps backlog 0b 0p requeues 0
 lended: 0 borrowed: 0 giants: 0
 tokens: 402 ctokens: 402

class htb 1:1 root rate 900000Kbit ceil 900000Kbit burst 113962b/8 mpu
0b overhead 0b cburst 113962b/8 mpu 0b overhead 0b level 7
 Sent 164938012460 bytes 206824215 pkt (dropped 0, overlimits 0 requeue=
s 0)
 rate 652715Kbit 97655pps backlog 0b 0p requeues 0
 lended: 0 borrowed: 0 giants: 0
 tokens: 402 ctokens: 402

class htb 1:2 parent 1:1 rate 900000Kbit ceil 900000Kbit burst
113962b/8 mpu 0b overhead 0b cburst 113962b/8 mpu 0b overhead 0b level
6
 Sent 164938012460 bytes 206824215 pkt (dropped 0, overlimits 0 requeue=
s 0)
 rate 652715Kbit 97655pps backlog 0b 0p requeues 0
 lended: 0 borrowed: 0 giants: 0
 tokens: 402 ctokens: 402

class htb 1:108 parent 1:10 leaf 108: prio 7 quantum 1514 rate
555000Kbit ceil 555000Kbit burst 70901b/8 mpu 0b overhead 0b cburst
70901b/8 mpu 0b overhead 0b level 0
 Sent 164938040048 bytes 206824248 pkt (dropped 25827911, overlimits 0
requeues 0)
 rate 652715Kbit 97655pps backlog 0b 33p requeues 0
 lended: 206824215 borrowed: 0 giants: 0
 tokens: -6 ctokens: -6


I'm applying the patches now. I'll get back to you.

  Antonio Almeida



On Mon, May 18, 2009 at 12:14 PM, Jarek Poplawski <jarkao2@gmail.com> w=
rote:
> On Mon, May 18, 2009 at 11:39:02AM +0100, Antonio Almeida wrote:
>> Hi!
>>
>> Here the information you asked:
>
> Very nice, but there are some questions:
> - if this analyser uses tcp we definitely need tso off as well during
> =A0these tests,
> - it would be nice to use two patches I've sent to exclude known (now=
)
> =A0reasons.
>
> With the above I expect accuracy should be better, but definitely not
> like hfsc (plus no higher than 1000Mbit rate reported after stopping
> effect).
>
> Thanks,
> Jarek P.
>
>>
>> # ethtool -k eth0
>> Offload parameters for eth0:
>> rx-checksumming: on
>> tx-checksumming: on
>> scatter-gather: on
>> tcp segmentation offload: on
>> udp fragmentation offload: off
>> generic segmentation offload: off
>>
>> # ethtool -k eth1
>> Offload parameters for eth1:
>> rx-checksumming: on
>> tx-checksumming: on
>> scatter-gather: on
>> tcp segmentation offload: on
>> udp fragmentation offload: off
>> generic segmentation offload: off
>>
>> The bridge is between eth0 and eth1
> ...
>
