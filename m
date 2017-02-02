From: Andy Zhou <azhou@ovn.org>
Subject: Re: [net-next ovs clone action 3/3] openvswitch: kernel datapath
 clone action
Date: Wed, 1 Feb 2017 19:31:03 -0800
Message-ID: <CABKoBm38whikMMJPnjj_E71pbXOhO0FYogDosTyQ9nNMMPo3pQ@mail.gmail.com>
References: <1485881247-6683-1-git-send-email-azhou@ovn.org>
 <1485881247-6683-3-git-send-email-azhou@ovn.org> <CAOrHB_D5_4+3MZ6yuU1FMJkjFO-Gv2fav55dg3=hZt8cB+g6SQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:42152 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750858AbdBBDbt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 22:31:49 -0500
Received: from mfilter17-d.gandi.net (mfilter17-d.gandi.net [217.70.178.145])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id EEC0F17209B
        for <netdev@vger.kernel.org>; Thu,  2 Feb 2017 04:31:46 +0100 (CET)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter17-d.gandi.net (mfilter17-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 9rOkKTl7y326 for <netdev@vger.kernel.org>;
        Thu,  2 Feb 2017 04:31:45 +0100 (CET)
Received: from mail-ot0-f176.google.com (mail-ot0-f176.google.com [74.125.82.176])
        (Authenticated sender: azhou@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 70673172095
        for <netdev@vger.kernel.org>; Thu,  2 Feb 2017 04:31:45 +0100 (CET)
Received: by mail-ot0-f176.google.com with SMTP id f9so2970091otd.1
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 19:31:45 -0800 (PST)
In-Reply-To: <CAOrHB_D5_4+3MZ6yuU1FMJkjFO-Gv2fav55dg3=hZt8cB+g6SQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 1, 2017 at 6:30 PM, Pravin Shelar <pshelar@ovn.org> wrote:
> On Tue, Jan 31, 2017 at 8:47 AM, Andy Zhou <azhou@ovn.org> wrote:
>> Add 'clone' kernel datapath support. In case the actions within clone
>> do not modify the current flow, the actions are executed without
>> making a copy of current key before execution. This analysis is
>> done once per flow installation.
>>
>> On the other hand, in case the actions within clone may modify
>> current flow key, a key has to be copied. In case the percpu
>> 'flow_keys' is available for the next 'exec_actions_level', the clone
>> actions will be executed without using the deferred fifo. Otherwise,
>> deferred fifo is used this clone action.
>>
>
> I think we can use sample action to clone packet and apply
> optimization to sample action. That will allow greater use of existing
> action without additional complexity.
>
O.K. I will rework the patch series to apply the optimizations to the sample
action.  Thanks for the review and comment.
