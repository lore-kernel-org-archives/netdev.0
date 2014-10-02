From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH V5] qdisc: bulk dequeue support for qdiscs with
 TCQ_F_ONETXQUEUE
Date: Thu, 02 Oct 2014 09:02:29 -0400
Message-ID: <542D4CE5.5050202@mojatatu.com>
References: <20140930085114.24043.81310.stgit@dragon>	<542A8EF9.10403@mojatatu.com>	<20140930.142038.235338672810639160.davem@davemloft.net>	<542BFEF3.7020302@mojatatu.com>	<CA+mtBx8rVu9FXtnc18n22L9LP=t=3Pso7U2yvvLcnny57w8aXg@mail.gmail.com>	<542C1F1F.90404@mojatatu.com>	<20141001192840.5679a671@redhat.com>	<542C4E0D.4050404@mojatatu.com>	<20141001214700.18b16387@redhat.com>	<542C5E8B.7070204@mojatatu.com>	<20141001223229.6cbaac07@redhat.com> <CAA93jw5orK2FeD20zcFpXGkqGa=kF8E-vGtkdUs7vr54R5AE6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	=?UTF-8?B?VG9rZSBIw7hpbGFuZA==?= =?UTF-8?B?LUrDuHJnZW5zZW4=?=
	<toke@toke.dk>
To: Dave Taht <dave.taht@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:57140 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbaJBNCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 09:02:32 -0400
Received: by mail-ig0-f182.google.com with SMTP id hn18so2318187igb.3
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 06:02:31 -0700 (PDT)
In-Reply-To: <CAA93jw5orK2FeD20zcFpXGkqGa=kF8E-vGtkdUs7vr54R5AE6g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/02/14 01:18, Dave Taht wrote:

> I am not huge on averages. Network theorists tend to think about things in
> terms of fluid models. Van Jacobson's analogy of a water fountain's
> operation is very profound...
>
> While it is nearly impossible for a conventional Van Neuman time sliced
> CPU + network to actually act that way, things like BQL and dedicated
> pipelining systems like those in DPDK are getting closer to that ideal.
>
> An example of where averages let you down is on the classic 5 minute
> data reduction things like mrtg do, where you might see `60% of the
> bandwidth (capacity/5 minutes) in use, yet still see drops because
> over shorter intervals (capacity/10ms) you have bursts arriving.
>

I think in this case, averages makes sense because we are measuring
resource utilization - CPU (ab)use. Assuming it costs more when
we dont bulk and we make up for it when we bulk, then over the
measurement period we can find if it is an overall win.
Same thing with bandwidth utilization - instantenous bursts dont tell
you the overall utilization (so a double leaky bucket gives you
a better picture).

cheers,
jamal
