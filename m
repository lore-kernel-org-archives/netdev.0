From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 1/2] net_sched: move tc_action into tcf_common
Date: Thu, 21 Jul 2016 09:50:00 -0700
Message-ID: <CAM_iQpVY0Bs1nQDcZzzSKtGGFJ+qeZoXsjSHg4e8hg+MjWxtug@mail.gmail.com>
References: <1469078614-13540-1-git-send-email-xiyou.wangcong@gmail.com>
 <1469078614-13540-2-git-send-email-xiyou.wangcong@gmail.com> <1ce68bcb-7a73-013c-bdd7-639dce465ea7@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:32814 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753301AbcGUQuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 12:50:20 -0400
Received: by mail-io0-f193.google.com with SMTP id y195so5754445iod.0
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 09:50:20 -0700 (PDT)
In-Reply-To: <1ce68bcb-7a73-013c-bdd7-639dce465ea7@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 21, 2016 at 12:38 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> It is an involved change (and i was fond of the container_of()
> trickery;)).
>
> Looking at this patch I cant grok some parts - maybe i need to apply it
> when i am not in a hurry to see clearly.
> Mostly this around things like:
> ---
> const struct tc_action *a
> struct tcf_mirred *m = to_mirred(a)
> ---
>
> Essentially this reduces to
> struct tcf_mirred *m = (struct tcf_mirred *)a
>
> How would that work?

This works because we always put struct tc_action
as the first member of each specific action, e.g. tcf_mirred,

struct tcf_mirred {
        struct tc_action        common;
        int                     tcfm_eaction;
        int                     tcfm_ifindex;
        int                     tcfm_ok_push;
        struct net_device __rcu *tcfm_dev;
        struct list_head        tcfm_list;
};

We can put a container_of() if you want to relax this rule,
but we already use the same trick in many other places
in networking subsystem. ;)

> Do we still need the void *priv

No, I already removed it in this patch.

Thanks.
