From: Tomas Hruby <thruby@gmail.com>
Subject: Re: [RFC net-next 0/4] gianfar: Use separate NAPI for Tx confirmation processing
Date: Wed, 8 Aug 2012 16:06:33 -0700
Message-ID: <CAOy7UX2AW2w8TE0=7HGqRDJnX3Te5XZmW8UfC8F6HZg1RdWCYw@mail.gmail.com>
References: <1344428810-29923-1-git-send-email-claudiu.manoil@freescale.com>
	<20120808162423.GC11043@windriver.com>
	<1344444267.28967.225.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:43802 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758318Ab2HHXGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2012 19:06:34 -0400
Received: by qcro28 with SMTP id o28so869815qcr.19
        for <netdev@vger.kernel.org>; Wed, 08 Aug 2012 16:06:33 -0700 (PDT)
In-Reply-To: <1344444267.28967.225.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 8, 2012 at 9:44 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2012-08-08 at 12:24 -0400, Paul Gortmaker wrote:
>> [[RFC net-next 0/4] gianfar: Use separate NAPI for Tx confirmation processing] On 08/08/2012 (Wed 15:26) Claudiu Manoil wrote:
>>
>> > Hi all,
>> > This set of patches basically splits the existing napi poll routine into
>> > two separate napi functions, one for Rx processing (triggered by frame
>> > receive interrupts only) and one for the Tx confirmation path processing
>> > (triggerred by Tx confirmation interrupts only). The polling algorithm
>> > behind remains much the same.
>> >
>> > Important throughput improvements have been noted on low power boards with
>> > this set of changes.
>> > For instance, for the following netperf test:
>> > netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
>> > yields a throughput gain from oscilating ~500-~700 Mbps to steady ~940 Mbps,
>> > (if the Rx/Tx paths are processed on different cores), w/ no increase in CPU%,
>> > on a p1020rdb - 2 core machine featuring etsec2.0 (Multi-Queue Multi-Group
>> > driver mode).
>>
>> It would be interesting to know more about what was causing that large
>> an oscillation -- presumably you will have it reappear once one core
>> becomes 100% utilized.  Also, any thoughts on how the change will change
>> performance on an older low power single core gianfar system (e.g.  83xx)?
>
> I also was wondering if this low performance could be caused by BQL
>
> Since TCP stack is driven by incoming ACKS, a NAPI run could have to
> handle 10 TCP acks in a row, and resulting xmits could hit BQL and
> transit on qdisc (Because NAPI handler wont handle TX completions in the
> middle of RX handler)

Does disabling BQL help? Is the BQL limit stable? To what value is it
set? I would be very much interested in more data if the issue is BQL
related.
