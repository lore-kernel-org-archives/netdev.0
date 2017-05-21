From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net-next 2/2] net/sched: fix filter flushing
Date: Sat, 20 May 2017 17:16:45 -0700
Message-ID: <CAM_iQpWha6aCV3kOfCEFsBLNiC7LFTh=K=QaL17rH4=PUoeUmQ@mail.gmail.com>
References: <20170520130132.1626-1-jiri@resnulli.us> <20170520130132.1626-2-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Simon Horman <simon.horman@netronome.com>, mlxsw@mellanox.com,
        Colin King <colin.king@canonical.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:36058 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751457AbdEUARG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 May 2017 20:17:06 -0400
Received: by mail-wm0-f44.google.com with SMTP id 7so28468383wmo.1
        for <netdev@vger.kernel.org>; Sat, 20 May 2017 17:17:06 -0700 (PDT)
In-Reply-To: <20170520130132.1626-2-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 20, 2017 at 6:01 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> +static void tcf_chain_destroy(struct tcf_chain *chain)
> +{
> +       list_del(&chain->list);
> +       tcf_chain_flush(chain);
>         kfree(chain);
>  }
>
> @@ -510,7 +517,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
>
>         if (n->nlmsg_type == RTM_DELTFILTER && prio == 0) {
>                 tfilter_notify_chain(net, skb, n, chain, RTM_DELTFILTER);
> -               tcf_chain_destroy(chain);
> +               tcf_chain_flush(chain);


I wonder if we should return EBUSY and do nothing in case of busy?
The chain is no longer visual to new actions after your list_del(), but
the old one could still use and see it.
