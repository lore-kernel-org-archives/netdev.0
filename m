From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net] sched, cls: check if we could overwrite actions when
 changing a filter
Date: Wed, 16 Apr 2014 08:30:08 -0400
Message-ID: <534E77D0.8000307@mojatatu.com>
References: <1397605563-29756-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:42993 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756084AbaDPMaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 08:30:19 -0400
Received: by mail-ig0-f177.google.com with SMTP id ur14so959761igb.4
        for <netdev@vger.kernel.org>; Wed, 16 Apr 2014 05:30:19 -0700 (PDT)
In-Reply-To: <1397605563-29756-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/15/14 19:46, Cong Wang wrote:
> From: Cong Wang <cwang@twopensource.com>
>
> When actions are attached to a filter, they are a part of the filter
> itself, so when changing a filter we should allow to overwrite the actions
> inside as well.
>
> In my specific case, when I tried to _append_ a new action to an existing
> filter which already has an action, I got EEXIST since kernel refused
> to overwrite the existing one in kernel.
>
> This patch checks if we are changing the filter checking NLM_F_CREATE flag
> (Sigh, filters don't use NLM_F_REPLACE...) and then passes the boolean down
> to actions. This fixes the problem above.


What are you trying to achieve?
These are general netlink rules (which can be streamlined by
the object).
Append means "I dont care if this exists, add it to the end"
In that case, you would specify the an existing filter rule but
in order to resolve ambiguity tc classifiers provide priorities
(i.e just specify a different priority) and the rule will be added
before or after  the conflicting rule.
If you dont do that then you will get back EEXIST to tell you
there is a conflict.
You cant replace an existing filter in particular when it has
a graph of actions attached to it. You can replace the paremetrization
of an existing bound action - but i am not sure that is what you
are trying to do here. For that address the specific action directly.
i.e tc action ....
If otoh you wanted to replace the filter + action graph with a backup
rule, then just add it lower in the priority list and delete the
existing one etc.

cheers,
jamal
