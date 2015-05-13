From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH -next] net: sched: use counter to break reclassify loops
Date: Wed, 13 May 2015 07:18:57 -0400
Message-ID: <55533321.302@mojatatu.com>
References: <1431366641-24735-1-git-send-email-fw@strlen.de> <5551E62D.5040507@mojatatu.com> <20150512130029.GA22387@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:35207 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933242AbbEMLS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 07:18:59 -0400
Received: by iebpz10 with SMTP id pz10so28655614ieb.2
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 04:18:58 -0700 (PDT)
In-Reply-To: <20150512130029.GA22387@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/12/15 09:00, Florian Westphal wrote:
> Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> Florian,
>> In general i am in support of removing this - since the use case never
>> materialized as being useful. However, this is not the same logic that
>> was there before. To get equivalency you need to pass the limit into
>> tc_classify_compat() so i can be reset.
>
> AFAICS this re-set only happens when we return something other
> than RECLASSIFY which means the caller will not check the limit.
>
> So in fact it should be ok to remove this since the counter will always
> start from 0 on next tc_classify() invocation.
>

Florian, consider the following scenario:
Assume X is the max allowed reclassified before bells start ringing.
If we see upto X back-to-back reclassify - we are very much likely in
a loop. We should see fire trucks arrive and bail out.
If we see X-1  "reclassify" followed by a "pipe" followed by
X-1 "reclassify" followed by "ok" then that looks like a healthy
policy. But that is a a total of 2X-2 reclassifies. You will
bail out at X reclassifies; what i am saying is you shouldnt.
And existing logic doesnt. Does that make sense?
Pass the &limit and reset it as before to 0 when you see something
other than reclassify.

cheers,
jamal
