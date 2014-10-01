From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH V5] qdisc: bulk dequeue support for qdiscs with
 TCQ_F_ONETXQUEUE
Date: Wed, 01 Oct 2014 14:55:09 -0400
Message-ID: <542C4E0D.4050404@mojatatu.com>
References: <20140930085114.24043.81310.stgit@dragon>	<542A8EF9.10403@mojatatu.com>	<20140930.142038.235338672810639160.davem@davemloft.net>	<542BFEF3.7020302@mojatatu.com>	<CA+mtBx8rVu9FXtnc18n22L9LP=t=3Pso7U2yvvLcnny57w8aXg@mail.gmail.com>	<542C1F1F.90404@mojatatu.com> <20141001192840.5679a671@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
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
	Dave Taht <dave.taht@gmail.com>,
	=?windows-1252?Q?Toke_H=F8iland-J=F8rgensen?= <toke@toke.dk>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:62126 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751453AbaJASzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 14:55:12 -0400
Received: by mail-ig0-f170.google.com with SMTP id l13so697469iga.3
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 11:55:11 -0700 (PDT)
In-Reply-To: <20141001192840.5679a671@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/01/14 13:28, Jesper Dangaard Brouer wrote:

> Thus, code is activated only when q->qlen is >= 1. And I have already
> shown that we see a win with just bulking 2 packets:

If you can get 2 packets, indeed you win. If you can on average get >1
over a long period, you still win.
You have clearly demonstrated you can do that with traffic
generators (udp or in kernel pktgen). I was more worried about the
common use case scenario (handwaved as 1-24 TCP streams).

The key here is: *if you never hit bulking* then the cost is
_per packet_ for sch_direct_xmit bypass.
Question is what is that cost for the common case as defined above?
Can you hit a bulk level >1 on 1-24 TCP streams?
I would be happy if your answer is *yes*. If your answer is no (since
it is hard to achieve) - then how far off is it from before your
patches (since now you have added at minimal a branch check).
I think it is fair for you to quantify that, no?
Feature is still useful for the other cases.

Note:
This is what i referred to as the "no animals were hurt during the
making of these patches" statement. I am sorry again for raining on
the parade.

cheers,
jamal
