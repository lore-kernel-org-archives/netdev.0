From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] net: sched: fix a use-after-free error on chain on the
 error exit path
Date: Sat, 20 May 2017 09:13:15 +0200
Message-ID: <20170520071315.GB1833@nanopsycho>
References: <20170518140702.6072-1-colin.king@canonical.com>
 <CAM_iQpX+aSOK8+K5eU1s=2LJzZgBdCvWBkhuT3ByZSqKWpSSvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Colin King <colin.king@canonical.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S . Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36179 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751049AbdETHNT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 May 2017 03:13:19 -0400
Received: by mail-wm0-f68.google.com with SMTP id k15so20592329wmh.3
        for <netdev@vger.kernel.org>; Sat, 20 May 2017 00:13:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpX+aSOK8+K5eU1s=2LJzZgBdCvWBkhuT3ByZSqKWpSSvw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, May 19, 2017 at 07:17:59PM CEST, xiyou.wangcong@gmail.com wrote:
>On Thu, May 18, 2017 at 7:07 AM, Colin King <colin.king@canonical.com> wrote:
>> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
>> index 4020b8d932a1..82ebdc3fcb2e 100644
>> --- a/net/sched/cls_api.c
>> +++ b/net/sched/cls_api.c
>> @@ -511,6 +511,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
>>         if (n->nlmsg_type == RTM_DELTFILTER && prio == 0) {
>>                 tfilter_notify_chain(net, skb, n, chain, RTM_DELTFILTER);
>>                 tcf_chain_destroy(chain);
>
>
>Jiri, how does this work...? An action could hold a refcnt to a filter
>chain, but here you destroy a whole chain without respecting
>the refcnt???

Correct. I missed this. Will fix, thanks.


>
>
>> +               chain = NULL;
>>                 err = 0;
>>                 goto errout;
>
>Colin, not your fault, I think we may miss something more serious
>when reviewing Jiri's patchset. ;)
>
>Thanks.
