From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next v2 2/2] net_sched: add network namespace support
 for tc actions
Date: Wed, 24 Feb 2016 10:37:09 -0800
Message-ID: <CAM_iQpUkM6KUm=H6CV-wd0+zcOESMHREai1=Q9nrv0GQeFqdhQ@mail.gmail.com>
References: <1456185473-25403-1-git-send-email-xiyou.wangcong@gmail.com>
	<1456185473-25403-3-git-send-email-xiyou.wangcong@gmail.com>
	<56CC5B35.4060408@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:33170 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758399AbcBXShK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 13:37:10 -0500
Received: by mail-yk0-f177.google.com with SMTP id z13so11773698ykd.0
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 10:37:09 -0800 (PST)
In-Reply-To: <56CC5B35.4060408@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 23, 2016 at 5:14 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> -       int     (*walk)(struct sk_buff *, struct netlink_callback *, int,
>> struct tc_action *);
>> +       int     (*walk)(struct net *, struct sk_buff *,
>> +                       struct netlink_callback *, int, struct tc_action
>> *);
>> +};
>> +
>
>
> Do you really need to pass struct net to walk(); is deriving from skb
> not sufficient?

Unfortunately, we have to pass it to walk(), because tca_action_flush()
allocates the skb without setting sk, so we can't get net from skb.
rtnetlink_send() accepts both net and skb too.

So, overall, all of your concerns with regarding to v2 are answered,
can I have your Acked-by now? ;)

Thanks.
