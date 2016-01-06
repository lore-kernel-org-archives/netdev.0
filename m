From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC PATCH 00/12] drop the qdisc lock for pfifo_fast/mq
Date: Wed, 6 Jan 2016 08:14:44 -0500
Message-ID: <568D1344.1090602@mojatatu.com>
References: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>, daniel@iogearbox.net,
	eric.dumazet@gmail.com, aduyck@mirantis.com, brouer@redhat.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:35308 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601AbcAFNOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 08:14:53 -0500
Received: by mail-io0-f181.google.com with SMTP id 77so186691200ioc.2
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 05:14:52 -0800 (PST)
In-Reply-To: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Sorry for not being as responsive as i would like to be
(theman calls and i have to go).
This looks like a good (tc workshop) candidate discussion, if still
active by netdev11 time.

On 15-12-30 12:50 PM, John Fastabend wrote:
> Hi,
>
> This is a first take at removing the qdisc lock on the xmit path
> where qdiscs actually have queues of skbs. The ingress qdisc
> which is already lockless was "easy" at least in the sense that
> we did not need any lock-free data structures to hold skbs.
>

I did some testing over the holidays for a netdev11 paper submission
and the ingress qdisc side of things looks very impressive (on
an average packet size) on a single (i7 class) cpu.
It can handle about 3x what an egress side pktgen type test (not
very real life) can handle. Analysis shows the lock is killing us.
So if you are looking at low hanging fruit, the egress is
the place to look.
I have a pktgen change that may be useful for you - I will post
it next time i get cycles.
I am also a willing guinea pig (given upcoming netdev11) to do
some perf testing ;->

cheers,
jamal
