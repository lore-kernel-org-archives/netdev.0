From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] net: sched: atm: destroy main filter chain
Date: Fri, 24 Mar 2017 18:55:40 +0100
Message-ID: <20170324175540.GA1897@nanopsycho>
References: <1490362789-7293-1-git-send-email-jiri@resnulli.us>
 <CAM_iQpVu=SCDZ7YdZDa3J9bugOsDb1Hzz=GnAS3r=-gAXik6gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>, mlxsw@mellanox.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35109 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753960AbdCXRzn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 13:55:43 -0400
Received: by mail-wm0-f67.google.com with SMTP id z133so2063313wmb.2
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 10:55:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpVu=SCDZ7YdZDa3J9bugOsDb1Hzz=GnAS3r=-gAXik6gw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Mar 24, 2017 at 06:46:55PM CET, xiyou.wangcong@gmail.com wrote:
>On Fri, Mar 24, 2017 at 6:39 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> In atm_tc_destroy, the flow qdisc filter chains are destroyed. However
>> the main chain is not. So fix this memory and reference leak.
>
>Are you sure? 'link' is on the 'flows' already according

Ah. You are correct. Scratch this. Thanks.

Btw, I think that in atm_tc_change:
list_add(&flow->list, &p->link.list);
should be:
list_add(&flow->list, &p->flows);



>to this comment:
>
>struct atm_qdisc_data {
>        struct atm_flow_data    link;           /* unclassified skbs go here */
>        struct list_head        flows;          /* NB: "link" is also on this
>                                                   list */
>        struct tasklet_struct   task;           /* dequeue tasklet */
>};
