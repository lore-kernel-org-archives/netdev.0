From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: tc rsvp filter show broke
Date: Sun, 28 Sep 2014 14:48:18 -0400
Message-ID: <542857F2.8090100@mojatatu.com>
References: <5425A545.1040907@gmail.com> <5425ED2D.1000005@mojatatu.com> <5425F5CC.4070507@intel.com> <542823CE.9020301@mojatatu.com> <CAM_iQpXzXHc7o1WOtkNnF+io_WZFP+DP4zWm8PZbwX7SC38=Pw@mail.gmail.com> <54284A51.5080805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: John Fastabend <john.fastabend@gmail.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:53568 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753470AbaI1SsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 14:48:22 -0400
Received: by mail-ie0-f176.google.com with SMTP id ar1so17807045iec.7
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 11:48:21 -0700 (PDT)
In-Reply-To: <54284A51.5080805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/28/14 13:50, John Fastabend wrote:
> On 09/28/2014 10:15 AM, Cong Wang wrote:

>                           act->type = exts->type = TCA_OLD_COMPAT;
>                           list_add(&act->list, &exts->actions);
>              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>

Right.

Note, this exts->xx thing we should eventually kill. It was intended to
allow for old binary compatibility (for about 10 years now).
In the earlier days, policer was a speacial action and one could invoke
it directly from "tc filter ....."
But over time, the more sane way is:
"tc filter .. action police ..."
We have killed ability to compile in the kernel policer to support to
allow old tools to continue to use it at least 5 years ago.
tc still has support but I doubt if anyone uses it. Otherwise there
would have been a lot of fallout from
commit 4bfb21ca2043dc5251102e4debcc0ae27f7304e7 in iproute2.

So if there are any takers for patches, i think the first thing is
to kill every call in iproute2 which calls police directly.
And if nobody whines, then get rid of most of exts->XXX (at minimal
there would be no need for exts->police)

cheers,
jamal
