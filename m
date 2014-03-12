From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RCU PATCH 00/14] Remove qdisc lock around ingress Qdisc
Date: Wed, 12 Mar 2014 02:58:16 -0400
Message-ID: <53200588.5060805@mojatatu.com>
References: <20140310170008.3011.73599.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>, xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:46285 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756476AbaCLG61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 02:58:27 -0400
Received: by mail-ea0-f177.google.com with SMTP id h10so4725972eak.8
        for <netdev@vger.kernel.org>; Tue, 11 Mar 2014 23:58:26 -0700 (PDT)
In-Reply-To: <20140310170008.3011.73599.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/10/14 13:03, John Fastabend wrote:
> This series drops the qdisc lock that is currently protecting the
> ingress qdisc. This can be done after the tcf filters are made
> lockless and the statistic accounting is safe to run without locks.
>
> To do this the classifiers are converted to use RCU. This requires
> updating each classifier individually to handle the new copy/update
> requirement and also to update the core list traversals. This is
> done in patches 2-11. This also makes the assumption that updates
> to the tables are infrequent in comparison to the packet per second
> being classified. On a 10Gbps running near line rate we can easily
> produce 12+ million packets per second so IMO this is a reasonable
> assumption. And the updates are serialized by RTNL.
>


I am in travel mode and dont have much cycles to do full review
and the patch set seems to be based on what we discussed earlier.
I worry on whether the assumption that table updates being
infrequent is going to cripple some of the use cases that have
made the interface powerful.  Cant find a presentation i did a
while back nor my data (i will look when i get back)- but one of the
things we prided on was ability to do extremely fast updates (both
latency and throughput) even in presence of datapath activity.
My comparison at the time was against netfilter (we were about
a magnitude faster).
So a good metric is to pick some classifier and action - then do
table updates with no traffic as a base metric and with your changes
after. Likewise with traffic.

BTW: does this mean there may be lack of sync between what the
control update is doing and what is being used in the datapath?

cheers,
jamal
