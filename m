From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 3/6] net_sched: cls_bpf: remove faulty use of
 list_for_each_entry_rcu
Date: Wed, 03 Dec 2014 09:37:46 -0500
Message-ID: <547F203A.3080208@mojatatu.com>
References: <1417539636-12710-1-git-send-email-jiri@resnulli.us> <1417539636-12710-4-git-send-email-jiri@resnulli.us> <547F0743.4040301@mojatatu.com> <20141203132635.GH1860@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:44463 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752409AbaLCOhs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 09:37:48 -0500
Received: by mail-ig0-f177.google.com with SMTP id z20so12790300igj.4
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 06:37:48 -0800 (PST)
In-Reply-To: <20141203132635.GH1860@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/14 08:26, Jiri Pirko wrote:
> Wed, Dec 03, 2014 at 01:51:15PM CET, jhs@mojatatu.com wrote:

>> I think this may be problematic. Doesnt a flush operation also use the
>> walker?
>
> I don't believe so. Just look at tc_dump_tfilter.
>

Actually we cant flush filters (we could actions).

> But even if that would the the case, _rcu variant is wrong (yep, it
> would have to be replaced by _safe variant then).
>

Sorry, still humping on the get part:
that gets invoked for del for a filter that may be in use in the
datapath. del uses rcu - should get not use rcu in such a case?

cheers,
jamal
