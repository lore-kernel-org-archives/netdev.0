From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] net/sched: act_pedit: limit negative offset
Date: Sun, 27 Nov 2016 21:39:33 -0800
Message-ID: <CAM_iQpX1at1w=3OfRFchn3STTDJGXj640tGetxXToR=EyddpEw@mail.gmail.com>
References: <20161127155815.10359-1-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33886 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751623AbcK1Fjy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 00:39:54 -0500
Received: by mail-io0-f194.google.com with SMTP id r94so20641517ioe.1
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 21:39:54 -0800 (PST)
In-Reply-To: <20161127155815.10359-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 27, 2016 at 7:58 AM, Amir Vadai <amir@vadai.me> wrote:
> Should not allow setting a negative offset that goes below the skb head.
...
> diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
> index b54d56d4959b..e79e8a88f2d2 100644
> --- a/net/sched/act_pedit.c
> +++ b/net/sched/act_pedit.c
> @@ -154,8 +154,11 @@ static int tcf_pedit(struct sk_buff *skb, const struct tc_action *a,
>                         }
>
>                         ptr = skb_header_pointer(skb, off + offset, 4, &_data);
> -                       if (!ptr)
> +                       if ((unsigned char *)ptr < skb->head) {


ptr returned could be &_data, which is on stack, so why this comparison
makes sense for this case?


> +                               pr_info("tc filter pedit offset out of bounds\n");
>                                 goto bad;
> +                       }
> +
>                         /* just do it, baby */
>                         *ptr = ((*ptr & tkey->mask) ^ tkey->val);
>                         if (ptr == &_data)
> --
> 2.10.2
>
