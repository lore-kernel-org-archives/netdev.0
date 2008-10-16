From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 4/6] pkt_sched: Add qdisc->ops->peek() implementation.
Date: Thu, 16 Oct 2008 12:54:13 +0000
Message-ID: <20081016125413.GB20302@ff.dom.local>
References: <20081016094804.GE19019@ff.dom.local> <48F732F9.8010806@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:6278 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbYJPMyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 08:54:21 -0400
Received: by ug-out-1314.google.com with SMTP id k3so1683195ugf.37
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2008 05:54:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48F732F9.8010806@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 16, 2008 at 02:26:33PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> Add qdisc->ops->peek() implementation for work-conserving qdiscs.
>>
>> diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
>> index 915f314..155648d 100644
>> --- a/net/sched/sch_multiq.c
>> +++ b/net/sched/sch_multiq.c
>
> I haven't looked at sch_multiq in detail yet, but isn't it supposed to
> be used as root qdisc? In that case we wouldn't need a ->peek operation.
>

It's recommended, but IMHO, could be useful as a child too, especially
for testing. I've thought if it shouldn't be rather treated as non-work-
conserving, but I don't think there is a reason for preventing such test
or other non-optimal usage.

>> diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
>> index d35ef05..8d7acd8 100644
>> --- a/net/sched/sch_teql.c
>> +++ b/net/sched/sch_teql.c
>
> teql is also meant to be used as root qdisc. It doesn't seem to enfore
> it though.

Probably like above: there is not much of this code, but it could be
cut, no problem.

Jarek P.
