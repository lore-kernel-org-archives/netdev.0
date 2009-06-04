From: Antonio Almeida <vexwek@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Thu, 4 Jun 2009 14:50:06 +0100
Message-ID: <298f5c050906040650y31de6fdcv865e775d52bc977c@mail.gmail.com>
References: <298f5c050906020445n3941b4ceic1167a4a028005bf@mail.gmail.com>
	 <4A251EEE.4060903@trash.net> <20090602130857.GA7690@ff.dom.local>
	 <4A252714.2020008@trash.net> <20090602213723.GB2850@ami.dom.local>
	 <4A259EB2.5010500@gmail.com> <4A2620FD.8030708@trash.net>
	 <20090603074049.GA5254@ff.dom.local> <4A262BE7.4090807@trash.net>
	 <20090603095412.GC5644@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, davem@davemloft.net, devik@cdi.cz,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:48251 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753723AbZFDNuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 09:50:05 -0400
Received: by yw-out-2324.google.com with SMTP id 5so455801ywb.1
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2009 06:50:06 -0700 (PDT)
In-Reply-To: <20090603095412.GC5644@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 3, 2009 at 10:54 AM, Jarek Poplawski wrote:
> Antonio, could you give this patch a try (with all the previous) and
> repeat those HFSC tests you did before (plus maybe a few tries with
> lower rates)?

For me, HTB values are just perfect! I would say that they're better
than HFSC, since sent rate stays below the configured ceil (but that's
for me)
After applying the patch you sent (to sch_hfsc.c) I got these values for HFSC:

configuration	analyser RX	error (%)
  10000000	10062688		0,63
  20000000	20096961		0,48
  30000000	30135028		0,45
  40000000	40186190		0,47
  50000000	50294890		0,59
  60000000	60294553		0,49
  70000000	70284220		0,41
  80000000	80414272		0,52
  90000000	90354675		0,39
100000000	100453024		0,45
200000000	200962041		0,48
250000000	251467886		0,59
300000000	301422613		0,47
400000000	402123479		0,53
500000000	502356820		0,47
550000000	552988253		0,54
600000000	602956905		0,49
700000000	703405632		0,49
750000000	753949085		0,53
800000000	804315169		0,54
900000000	904584208		0,51

As usually, generating 970Mbit/s of tcp traffic of 800 bytes packets.

Here's the setup picture:
# tc -s -d class ls dev eth1
class hfsc 1: root
 Sent 253924 bytes 319 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 period 0 level 4

class hfsc 1:1 parent 1: sc m1 0bit d 0us m2 1000Mbit ul m1 0bit d 0us
m2 1000Mbit
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 period 2 work 299437688 bytes level 3

class hfsc 1:10 parent 1:2 sc m1 0bit d 0us m2 1000Mbit ul m1 0bit d
0us m2 1000Mbit
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 period 2 work 299437688 bytes level 1

class hfsc 1:2 parent 1:1 sc m1 0bit d 0us m2 1000Mbit ul m1 0bit d
0us m2 1000Mbit
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 period 2 work 299437688 bytes level 2

class hfsc 1:108 parent 1:10 sc m1 0bit d 50.0ms m2 500000Kbit ul m1
0bit d 0us m2 500000Kbit
 Sent 300178764 bytes 377109 pkt (dropped 349464, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 931p requeues 0
 period 2 work 299437688 bytes rtwork 299437688 bytes level 0


If you'd like any other values just ask. I'll be away till the fourteenth.
Thanks a lot! Good job!
  Antonio Almeida
