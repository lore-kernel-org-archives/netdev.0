From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 00/12] drop the qdisc lock for pfifo_fast/mq
Date: Thu, 07 Jan 2016 15:30:58 -0800
Message-ID: <568EF532.4040307@gmail.com>
References: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810> <568D1344.1090602@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>, daniel@iogearbox.net,
	eric.dumazet@gmail.com, aduyck@mirantis.com, brouer@redhat.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34660 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752181AbcAGXbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 18:31:16 -0500
Received: by mail-pf0-f176.google.com with SMTP id q63so519849pfb.1
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 15:31:16 -0800 (PST)
In-Reply-To: <568D1344.1090602@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-01-06 05:14 AM, Jamal Hadi Salim wrote:
> 
> Sorry for not being as responsive as i would like to be
> (theman calls and i have to go).
> This looks like a good (tc workshop) candidate discussion, if still
> active by netdev11 time.
> 
> On 15-12-30 12:50 PM, John Fastabend wrote:
>> Hi,
>>
>> This is a first take at removing the qdisc lock on the xmit path
>> where qdiscs actually have queues of skbs. The ingress qdisc
>> which is already lockless was "easy" at least in the sense that
>> we did not need any lock-free data structures to hold skbs.
>>
> 
> I did some testing over the holidays for a netdev11 paper submission
> and the ingress qdisc side of things looks very impressive (on
> an average packet size) on a single (i7 class) cpu.
> It can handle about 3x what an egress side pktgen type test (not
> very real life) can handle. Analysis shows the lock is killing us.
> So if you are looking at low hanging fruit, the egress is
> the place to look.

So this series drops the qdisc lock which should hopefully per
some older data I have bring it on par with the ingress side. But
I need to retest this latest patch series.

> I have a pktgen change that may be useful for you - I will post
> it next time i get cycles.
> I am also a willing guinea pig (given upcoming netdev11) to do
> some perf testing ;->
> 

I typically test this by putting vlan's on top of a dev with the
qdisc I want to test and running pktgen on the vlans the entry point
of the skb is pretty much where I want it in this case.

> cheers,
> jamal
> 
> 
