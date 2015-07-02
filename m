From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 6/6] net_sched: act: remove spinlock in fast
 path
Date: Thu, 02 Jul 2015 22:59:10 +0200
Message-ID: <1435870750.11970.37.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1435842455-30501-1-git-send-email-edumazet@google.com>
	 <1435842455-30501-7-git-send-email-edumazet@google.com>
	 <5595684D.90500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <edumazet@gmail.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:35189 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754329AbbGBU7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 16:59:14 -0400
Received: by wiga1 with SMTP id a1so162788672wig.0
        for <netdev@vger.kernel.org>; Thu, 02 Jul 2015 13:59:13 -0700 (PDT)
In-Reply-To: <5595684D.90500@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-07-02 at 09:35 -0700, John Fastabend wrote:
> > +	if (gact->tcf_tm.lastuse != jiffies)
> > +		gact->tcf_tm.lastuse = jiffies;
> 
> I'm missing the point of the if block. Is that really good enough
> for the 32bit system case? I would have expected some wrapper to
> handle it here something like u64_stats_() maybe _u64_jiffies(). Maybe
> after a coffee I'll make sense of it.
> 

Point is to not dirty cache line for every packet ?

Doing the test means we attempt dirtying only ~HZ times per second,
which really matters to handle millions of packets per second.

My tests show a good enough performance, not sure we want a percpu thing
for this lastuse field.
