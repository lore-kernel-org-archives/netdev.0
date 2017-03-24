From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net-next] net: sched: atm: destroy main filter chain
Date: Fri, 24 Mar 2017 10:46:55 -0700
Message-ID: <CAM_iQpVu=SCDZ7YdZDa3J9bugOsDb1Hzz=GnAS3r=-gAXik6gw@mail.gmail.com>
References: <1490362789-7293-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36069 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932767AbdCXRrc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 13:47:32 -0400
Received: by mail-wm0-f67.google.com with SMTP id x124so1977478wmf.3
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 10:47:26 -0700 (PDT)
In-Reply-To: <1490362789-7293-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 24, 2017 at 6:39 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> In atm_tc_destroy, the flow qdisc filter chains are destroyed. However
> the main chain is not. So fix this memory and reference leak.

Are you sure? 'link' is on the 'flows' already according
to this comment:

struct atm_qdisc_data {
        struct atm_flow_data    link;           /* unclassified skbs go here */
        struct list_head        flows;          /* NB: "link" is also on this
                                                   list */
        struct tasklet_struct   task;           /* dequeue tasklet */
};
