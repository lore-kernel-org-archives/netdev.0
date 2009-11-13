From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Fri, 13 Nov 2009 16:54:50 +0800
Message-ID: <412e6f7f0911130054i7a508a6ah16368f11bdc7353d@mail.gmail.com>
References: <412e6f7f0911122216u6880e855g6a15dac29ad6a100@mail.gmail.com>
	 <20091113074508.GA6605@ff.dom.local>
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
Received: from mail-pz0-f171.google.com ([209.85.222.171]:65011 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754820AbZKMIyo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 03:54:44 -0500
Received: by pzk1 with SMTP id 1so1159772pzk.33
        for <netdev@vger.kernel.org>; Fri, 13 Nov 2009 00:54:50 -0800 (PST)
In-Reply-To: <20091113074508.GA6605@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2009 at 3:45 PM, Jarek Poplawski <jarkao2@gmail.com> wr=
ote:
> On 13-11-2009 07:16, Changli Gao wrote:
>
> I don't think so. There would be a lot of code duplication and later
> maintenance problems only because of the scheduling method. The main
> question is to establish if there is really no performance difference
> (which I doubt) - unless Changli can show some tests for various
> setups now. On the other hand, if there is a difference, why keep
> ineffective solution - similar thing should be possible to do in the
> softirq context as well.
>
> So it should not be a big problem to do it a bit messy for some
> testing time. Since we can use separate ->ndo_start_xmit() etc. it
> shouldn't be too messy, I guess.
>

I have done a simple test. I run a simple program on computer A, which
sends SYN packets with random source ports to Computer B's 80 port (No
socket listens on that port, so tcp reset packets will be sent) in
90kpps. On computer B, I redirect the traffic to IFB. At the same
time, I ping from B to A to get the RTT between them. I can't see any
difference between the original IFB and my MQ version. They are both:

CPU idle: 50%
Latency: 0.3-0.4ms, burst 2ms.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
