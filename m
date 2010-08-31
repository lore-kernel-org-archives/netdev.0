From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [RFC][PATCH] QoS TBF and latency configuration misbehavior
Date: Wed, 1 Sep 2010 01:48:08 +0400
Message-ID: <20100831214808.GA32141@ms2.inr.ac.ru>
References: <AANLkTik4Mrzjfk_-u7Qg-B9Q-4tn_seqkkgmwnqQ8FOq@mail.gmail.com> <20100831210101.3c059a91@leibniz> <4C7D5EBD.103@gmail.com> <AANLkTikMJ2rtSNsBeaVTsVtw1ZmKpLjjyeYL=c+AgoFZ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>
To: Dan Kruchinin <dkruchinin@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:56177 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1750909Ab0HaVsa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Aug 2010 17:48:30 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTikMJ2rtSNsBeaVTsVtw1ZmKpLjjyeYL=c+AgoFZ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

> Documentation describes latency as something intuitively clear: "the
> maximum amount of time a packet can sit in the TBF"
> but tc implementation handles it something like: "an additional time
> packet can sit int the TBF after main waiting queue which size is
> equal to the burst size is completely full.". It doesn't seem to have
> any sense.

Seems, I still can tell what I really meant there:
burst is supposed to be handled instantly (unless peak rate is not infinite).
So that, latency is really (limit - burst)/rate.
Indeed, the case when limit < burst was missed in tc,
latency should be 0 in this case.

So, think: formula latency = limit/rate, which you suggest, is obviously
wrong (correct me): everything which is out of bucket is drained with rate of tbf,
but everyhing inside the burst is drained with rate of the device, which
cannot even be estimated on base of tbf parameters. (Again, here I ignore
the case when peak rate is set)

So, it looks like tc is almost correct, only it should print 0 instead
of negative value. And the phrase in documentation should sound like:
"maximal queuing delay introduced by TBF".

Alexey



