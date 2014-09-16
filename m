From: Cong Wang <cwang@twopensource.com>
Subject: Re: [net-next PATCH 3/3] net: sched: cls_cgroup fix possible memory
 leak of 'new'
Date: Mon, 15 Sep 2014 20:04:37 -0700
Message-ID: <CAHA+R7Pz2sCRC7BYAtd2P48gy2oxb=YfJqmx4=+8gKEyLwvMBA@mail.gmail.com>
References: <20140916024729.3010.47421.stgit@nitbit.x32>
	<20140916024831.3010.64477.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:38465 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752914AbaIPDEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 23:04:38 -0400
Received: by mail-lb0-f182.google.com with SMTP id u10so1984144lbd.41
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 20:04:37 -0700 (PDT)
In-Reply-To: <20140916024831.3010.64477.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2014 at 7:48 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
> index 3b75487..52b7900 100644
> --- a/net/sched/cls_cgroup.c
> +++ b/net/sched/cls_cgroup.c
> @@ -127,16 +127,16 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
>         err = nla_parse_nested(tb, TCA_CGROUP_MAX, tca[TCA_OPTIONS],
>                                cgroup_policy);
>         if (err < 0)
> -               return err;
> +               goto errout;
>
>         tcf_exts_init(&e, TCA_CGROUP_ACT, TCA_CGROUP_POLICE);
>         err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e, ovr);
>         if (err < 0)
> -               return err;
> +               goto errout;
>
>         err = tcf_em_tree_validate(tp, tb[TCA_CGROUP_EMATCHES], &t);
>         if (err < 0)
> -               return err;
> +               goto errout;
>

I think you need to call tcf_exts_destroy() too after tcf_exts_validate(),
while you are on it. :)
