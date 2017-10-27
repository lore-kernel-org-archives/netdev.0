From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next v2 2/2] net sched act_vlan: VLAN action rewrite
 to use RCU lock/unlock and update
Date: Fri, 27 Oct 2017 14:44:15 -0700
Message-ID: <CAM_iQpVeWn1hTVtcQ_H3Jc-gOe91ej0R0XTaMcLHRjOhFkTbJQ@mail.gmail.com>
References: <1509137368-15387-1-git-send-email-manish.kurup@verizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Alexander Aring <aring@mojatatu.com>,
        Roman Mashak <mrv@mojatatu.com>,
        Manish Kurup <manish.kurup@verizon.com>
To: Manish Kurup <kurup.manish@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:46331 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751515AbdJ0Vog (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 17:44:36 -0400
Received: by mail-pf0-f196.google.com with SMTP id p87so5824231pfj.3
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 14:44:36 -0700 (PDT)
In-Reply-To: <1509137368-15387-1-git-send-email-manish.kurup@verizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 27, 2017 at 1:49 PM, Manish Kurup <kurup.manish@gmail.com> wrote:
>  static inline u32 tcf_vlan_action(const struct tc_action *a)
>  {
> -       return to_vlan(a)->tcfv_action;
> +       u32 tcfv_action;
> +
> +       rcu_read_lock();
> +       tcfv_action = rcu_dereference(to_vlan(a)->vlan_p)->tcfv_action;
> +       rcu_read_unlock();
> +
> +       return tcfv_action;
>  }

It seems we need rcu_read_lock_bh() rather than just rcu_read_lock()?
If so, same for other tcf_vlan_*() helpers.
