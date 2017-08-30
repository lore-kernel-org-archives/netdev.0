From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net_sched: add reverse binding for tc class
Date: Wed, 30 Aug 2017 15:01:06 -0700
Message-ID: <CAM_iQpU9B71C5cWs969k464T7HvNhcwps7NYNQx8Q3KCijOfnA@mail.gmail.com>
References: <20170830213036.24250-1-xiyou.wangcong@gmail.com> <59A732B8.6020405@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:38829 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751746AbdH3WB1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 18:01:27 -0400
Received: by mail-pg0-f42.google.com with SMTP id b8so23472174pgn.5
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 15:01:27 -0700 (PDT)
In-Reply-To: <59A732B8.6020405@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 30, 2017 at 2:48 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 08/30/2017 11:30 PM, Cong Wang wrote:
> [...]
>>
>> Note, we still can NOT totally get rid of those class lookup in
>> ->enqueue() because cgroup and flow filters have no way to determine
>> the classid at setup time, they still have to go through dynamic lookup.
>
> [...]
>>
>> ---
>>   include/net/sch_generic.h |  1 +
>>   net/sched/cls_basic.c     |  9 +++++++
>>   net/sched/cls_bpf.c       |  9 +++++++
>
>
> Same is for cls_bpf as well, so bind_class wouldn't work there
> either as we could return dynamic classids. bind_class cannot
> be added here, too.

I think you are probably right, but the following code is
misleading there:

        if (tb[TCA_BPF_CLASSID]) {
                prog->res.classid = nla_get_u32(tb[TCA_BPF_CLASSID]);
                tcf_bind_filter(tp, &prog->res, base);
        }

If the classid is dynamic, why this tb[TCA_BPF_CLASSID]?
