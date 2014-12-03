From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 3/6] net_sched: cls_bpf: remove faulty use of
 list_for_each_entry_rcu
Date: Wed, 3 Dec 2014 16:20:51 +0100
Message-ID: <20141203152051.GK1860@nanopsycho.orion>
References: <1417539636-12710-1-git-send-email-jiri@resnulli.us>
 <1417539636-12710-4-git-send-email-jiri@resnulli.us>
 <547F0743.4040301@mojatatu.com>
 <20141203132635.GH1860@nanopsycho.orion>
 <547F203A.3080208@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:39074 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751665AbaLCPUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 10:20:53 -0500
Received: by mail-wi0-f174.google.com with SMTP id h11so31759527wiw.7
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 07:20:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <547F203A.3080208@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 03, 2014 at 03:37:46PM CET, jhs@mojatatu.com wrote:
>On 12/03/14 08:26, Jiri Pirko wrote:
>>Wed, Dec 03, 2014 at 01:51:15PM CET, jhs@mojatatu.com wrote:
>
>>>I think this may be problematic. Doesnt a flush operation also use the
>>>walker?
>>
>>I don't believe so. Just look at tc_dump_tfilter.
>>
>
>Actually we cant flush filters (we could actions).
>
>>But even if that would the the case, _rcu variant is wrong (yep, it
>>would have to be replaced by _safe variant then).
>>
>
>Sorry, still humping on the get part:
>that gets invoked for del for a filter that may be in use in the
>datapath. del uses rcu - should get not use rcu in such a case?

Yep, but this is updater, protected by rtnl. _rcu list travelsal variant
should be used by reader only (classify callback in cls case).

get op is only called from tc_ctl_tfilter which is always called with
rtnl held.

>
>cheers,
>jamal
