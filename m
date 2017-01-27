From: Andy Zhou <azhou@ovn.org>
Subject: Re: [net-next] openvswitch: Simplify do_execute_actions().
Date: Fri, 27 Jan 2017 13:25:52 -0800
Message-ID: <CABKoBm3=MGv+sdL6T3=2_=pTh+Wukp66ZdDUx99tD7t482nodA@mail.gmail.com>
References: <1485408261-31999-1-git-send-email-azhou@ovn.org> <CAOrHB_C3C_pcPpS=TSvKD0pF8eKRZMVgCK6eNKfbJnT_-xs1xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:56265 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751281AbdA0V1I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 16:27:08 -0500
Received: from mfilter20-d.gandi.net (mfilter20-d.gandi.net [217.70.178.148])
        by relay6-d.mail.gandi.net (Postfix) with ESMTP id 522C6FB89E
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 22:26:35 +0100 (CET)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
        by mfilter20-d.gandi.net (mfilter20-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 5tArDDQdpfSz for <netdev@vger.kernel.org>;
        Fri, 27 Jan 2017 22:26:34 +0100 (CET)
Received: from mail-ua0-f169.google.com (mail-ua0-f169.google.com [209.85.217.169])
        (Authenticated sender: azhou@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id C469FFB87D
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 22:26:33 +0100 (CET)
Received: by mail-ua0-f169.google.com with SMTP id i68so214023920uad.0
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 13:26:33 -0800 (PST)
In-Reply-To: <CAOrHB_C3C_pcPpS=TSvKD0pF8eKRZMVgCK6eNKfbJnT_-xs1xw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 27, 2017 at 12:42 PM, Pravin Shelar <pshelar@ovn.org> wrote:
> On Wed, Jan 25, 2017 at 9:24 PM, Andy Zhou <azhou@ovn.org> wrote:
>> do_execute_actions() implements a worthwhile optimization: in case
>> an output action is the last action in an action list, skb_clone()
>> can be avoided by outputing the current skb. However, the
>> implementation is more complicated than necessary.  This patch
>> simplify this logic.
>>
>> Signed-off-by: Andy Zhou <azhou@ovn.org>
>> ---
>>  net/openvswitch/actions.c | 40 +++++++++++++++++++---------------------
>>  1 file changed, 19 insertions(+), 21 deletions(-)
>>
>> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
>> index 514f7bc..3866608 100644
>> --- a/net/openvswitch/actions.c
>> +++ b/net/openvswitch/actions.c
>> @@ -830,6 +830,9 @@ static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port,
>>  {
>>         struct vport *vport = ovs_vport_rcu(dp, out_port);
>>
>> +       if (unlikely(!skb))
>> +               return;
>> +
> Patch looks good to me. But I wanted to know if you considered moving
> this check to do_execute_actions() in case skb-clone is done? This way
> we can avoid this unlikely check from likely case :)
>
Good point.  O.K. I will repost a version without this check.  Thanks
for the review and comment.
