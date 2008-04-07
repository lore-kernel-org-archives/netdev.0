From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: Re: [NET_SCHED 00/04]: External SFQ classifiers/flow classifier
Date: Mon, 07 Apr 2008 16:14:14 +0100
Message-ID: <47FA3A46.20207@andyfurniss.entadsl.com>
References: <20080131175758.25151.20370.sendpatchset@localhost.localdomain> <47A4FB81.80700@fatooh.org> <47A74FEE.6080103@trash.net> <47EED247.50801@andyfurniss.entadsl.com> <47F22CF5.4080806@trash.net> <47F28758.1010401@andyfurniss.entadsl.com> <47F37139.9080303@andyfurniss.entadsl.com> <47F37E04.4010001@trash.net> <47F3B3C5.6000701@andyfurniss.entadsl.com> <47F6062E.9050804@andyfurniss.entadsl.com> <47F606D8.108@trash.net> <47F65EDE.3010507@andyfurniss.entadsl.com> <47F6794D.7070302@andyfurniss.entadsl.com> <47FA2509.8060303@andyfurniss.entadsl.com> <47FA2543.1080609@trash.net>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Corey Hickey <bugfood-ml@fatooh.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.ukfsn.org ([77.75.108.10]:39410 "EHLO mail.ukfsn.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751483AbYDGPM3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Apr 2008 11:12:29 -0400
In-Reply-To: <47FA2543.1080609@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Andy Furniss wrote:

>> --- sch_sfq.c.orig      2008-04-07 11:42:36.000000000 +0100
>> +++ sch_sfq.c   2008-04-07 11:46:41.000000000 +0100
>> @@ -317,6 +317,7 @@
>>                         q->next[x] = q->next[q->tail];
>>                         q->next[q->tail] = x;
>>                         q->tail = x;
>> +                       q->allot[x] = 0;
> 
> 
> That might fix the symptom, but I don't think its correct.
> As I said, you can't simply reset to zero since it might cause
> unfairness of bursty flows against non-bursty flows.

I guess it would be nice in some ways to make a drr that has memory but 
I think this is a bug.

It was the same pre jhash when perturb was needed so the slots would 
change anyway.

If it were intended to be a memory of allot it fails because allot 
should never be as wide as +/- 32k (maybe that could be fixed - but only 
recently became practical with jhash/no perturb).

Currently a new flow (but not the fist) gets dealt a seemingly random 
allot of +/- 32k which means it either gets to monopolise the link until 
it has wound down to <=0 or if allot is -ve it gets disadvantaged in the 
case that it's packet size is < than the others until its allot has 
crept up to 0. If it's packets are MTU size it just gets 1 packet per 
round and allot stays -ve.

Andy.



