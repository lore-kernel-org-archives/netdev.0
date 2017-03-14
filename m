From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [net-next sample action optimization 3/3] openvswitch: Optimize
 sample action for the clone use cases
Date: Mon, 13 Mar 2017 23:20:39 -0700
Message-ID: <CAOrHB_Ciq+txB+-yY5YKKxVCA61WS9y8HOUAjQjApwC2UKd9dw@mail.gmail.com>
References: <1489193500-15260-1-git-send-email-azhou@ovn.org>
 <1489193500-15260-4-git-send-email-azhou@ovn.org> <CAOrHB_CNyhQM5wVJvYNQtE8+RKLAbPrjsrQtbGe-poHi+5AW+g@mail.gmail.com>
 <CABKoBm14S4QRZCNYqBdfcVXrmvDnf3xrRXbDsBKGsMufdgeXZQ@mail.gmail.com> <CABKoBm01ieuSrbhf7yZH9AzZkTNB=kiOAhYTDoinXRtDhQoFoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Joe Stringer <joe@ovn.org>
To: Andy Zhou <azhou@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:36222 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750858AbdCNGUn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 02:20:43 -0400
Received: from mfilter14-d.gandi.net (mfilter14-d.gandi.net [217.70.178.142])
        by relay6-d.mail.gandi.net (Postfix) with ESMTP id DAAA7FB8A4
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 07:20:41 +0100 (CET)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
        by mfilter14-d.gandi.net (mfilter14-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id xMlmMEsxqFaD for <netdev@vger.kernel.org>;
        Tue, 14 Mar 2017 07:20:40 +0100 (CET)
Received: from mail-wr0-f170.google.com (mail-wr0-f170.google.com [209.85.128.170])
        (Authenticated sender: pshelar@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 6E910FB8A3
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 07:20:40 +0100 (CET)
Received: by mail-wr0-f170.google.com with SMTP id g10so117092512wrg.2
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 23:20:40 -0700 (PDT)
In-Reply-To: <CABKoBm01ieuSrbhf7yZH9AzZkTNB=kiOAhYTDoinXRtDhQoFoQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 13, 2017 at 4:39 PM, Andy Zhou <azhou@ovn.org> wrote:
>>>> -       skb = skb_clone(skb, GFP_ATOMIC);
>>>> -       if (!skb)
>>>> -               /* Skip the sample action when out of memory. */
>>>> -               return 0;
>>>> +       if (key) {
>>>> +               err = do_execute_actions(dp, skb, key, actions, rem);
>>>> +       } else if (!add_deferred_actions(skb, orig, actions, rem)) {
>>>>
>>> We can refactor this code to avoid duplicate code all actions
>>> implementation. This way there could be single function dealing with
>>> both defered action and key fifo arrays.
>>
>> O.K. I will make the change in the next version.
>
> After looking more at it, the sample action and recirc action are different
> enough that I don't see clean ways refactor them. For example, recirc
> needs to deal with setting recirc_id.  recirc calls
> ovs_dp_process_packet, and sample calls do_execute_action.
>
Actions parameter which hints if it is recirc or sample. We can add
recic-id param and set it if it is recic case.
will this work?

>>> I am not sure if we can put sample or recirc in "may not change flow"
>>> actions list. Consider following set of actions:
>>> sample(sample(set-IP)),userpsace(),...
>>> In this case the userspace action could recieve skb with inconsistent
>>> flow due to preceding of set action nested in the sample action.
>>
>> Good catch.  Will fix.
>
> What's the objection on recirc action? It always works on clone key.

ok. recic does not have the issue.
