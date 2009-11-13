From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Fri, 13 Nov 2009 17:38:56 +0800
Message-ID: <412e6f7f0911130138td181935w36cab3119972753e@mail.gmail.com>
References: <412e6f7f0911122216u6880e855g6a15dac29ad6a100@mail.gmail.com>
	 <20091113074508.GA6605@ff.dom.local>
	 <412e6f7f0911130054i7a508a6ah16368f11bdc7353d@mail.gmail.com>
	 <20091113091825.GA7449@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:64897 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755631AbZKMJiu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 04:38:50 -0500
Received: by pzk1 with SMTP id 1so1181141pzk.33
        for <netdev@vger.kernel.org>; Fri, 13 Nov 2009 01:38:56 -0800 (PST)
In-Reply-To: <20091113091825.GA7449@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2009 at 5:18 PM, Jarek Poplawski <jarkao2@gmail.com> wr=
ote:
> On Fri, Nov 13, 2009 at 04:54:50PM +0800, Changli Gao wrote:
>> On Fri, Nov 13, 2009 at 3:45 PM, Jarek Poplawski <jarkao2@gmail.com>=
 wrote:
>>
>> I have done a simple test. I run a simple program on computer A, whi=
ch
>> sends SYN packets with random source ports to Computer B's 80 port (=
No
>> socket listens on that port, so tcp reset packets will be sent) in
>> 90kpps. On computer B, I redirect the traffic to IFB. At the same
>> time, I ping from B to A to get the RTT between them. I can't see an=
y
>> difference between the original IFB and my MQ version. They are both=
:
>>
>> CPU idle: 50%
>> Latency: 0.3-0.4ms, burst 2ms.
>>
>
> I'm mostly concerned with routers doing forwarding with 1Gb or 10Gb
> NICs (including multiqueue). Alas/happily I don't have such a problem=
,
> but can't help you with testing either.
>

Oh, :) . I know more than one companies use kernel threads to forward
packets, and there isn't explicit extra overhead at all. And as you
know, as throughput increases, NAPI will bind the NIC to a CPU, and
softirqd will be waked up to do the work, which should be done in
SoftIRQ context. At that time, there isn't any difference between my
approach and the current kernel's.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
