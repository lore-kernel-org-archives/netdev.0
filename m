From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v8 5/6] openvswitch: Sample action without side effects
Date: Wed, 23 Jul 2014 18:02:17 -0700
Message-ID: <CALnjE+rsyyVaPKAFhgETxtgJF4R=-oZb9uRLgMLNUNY6XikXDQ@mail.gmail.com>
References: <1406054116-1758-1-git-send-email-pshelar@nicira.com>
	<20140723.144759.1498389231853548910.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Simon Horman <horms@verge.net.au>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog133.obsmtp.com ([74.125.149.82]:52013 "HELO
	na3sys009aog133.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755444AbaGXBCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 21:02:19 -0400
Received: by mail-vc0-f170.google.com with SMTP id lf12so3647815vcb.15
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 18:02:18 -0700 (PDT)
In-Reply-To: <20140723.144759.1498389231853548910.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 23, 2014 at 2:47 PM, David Miller <davem@davemloft.net> wrote:
> From: Pravin B Shelar <pshelar@nicira.com>
> Date: Tue, 22 Jul 2014 11:35:16 -0700
>
>> * As sample() provides a cloned skb in the unlikely case where there are
>>   nested actions other than a single userspace action it is no longer
>>   necessary to clone the skb in do_execute_actions() when executing a
>>   recirculation action just because the keep_skb parameter is set:
>
> This commit log message talks about recirculation, which has been removed
> from this series.
>
ok, I will update msg.

> And in fact, I think, for my suggested implementation of recirculation
> by just returning and re-running the stack, this whole skb clone issue
> either goes away or needs to happen in a different place.
>
> If you recirculate by just returning and re-processing the packet at
> the top-level entry point into openvswitch, then that's where you
> would clone.

This patch is about sample action.
sample action needs skb_clone() in some case. OVS sample action has
list of actions which can be one or more output actions or another
(nested) sample action. A port output consumes skb, therefore
depending on action list we need to clone skb before it is sent to a
port. This patch try to optimize this as you have pointed out. It try
to avoid skb_clone() in case where sample action is last action.
same applies to recirculation action.
