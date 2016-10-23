From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net] sched, cls: don't dump kernel addr into tc monitors
 on delete event
Date: Sun, 23 Oct 2016 11:24:36 -0400
Message-ID: <9f962150-0ca8-7712-be4a-14cfe1dcc3f4@mojatatu.com>
References: <f7e28cd6ec298a90dc33fcc85e7361eb92025690.1476821268.git.daniel@iogearbox.net>
 <c02ce4f1-ba99-f54c-d35d-ca81cc771c8a@mojatatu.com>
 <CAM_iQpW4RdVo72=nQVaehkUCA98yq8+PyFQUTxis-Bx7XgVkFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33937 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753174AbcJWPYi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2016 11:24:38 -0400
Received: by mail-it0-f68.google.com with SMTP id e203so7072987itc.1
        for <netdev@vger.kernel.org>; Sun, 23 Oct 2016 08:24:38 -0700 (PDT)
In-Reply-To: <CAM_iQpW4RdVo72=nQVaehkUCA98yq8+PyFQUTxis-Bx7XgVkFw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-10-18 07:14 PM, Cong Wang wrote:
> On Tue, Oct 18, 2016 at 2:21 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> I was sitting on this patch I was going to send ;->
>> Does this resolve it?
>
> Your patch makes more sense to me. Maybe we can remove the
> event != RTM_DELTFILTER special case too?
>

We cant entirely get rid of that. Events other than
deletion require that a dump follows.
Probably what you mean is:
We could remove extra line inside "if (RTM_DELTFILTER != event)"
which does "tcm->tcm_handle = 0;"
It would be more reasonable to actually audit the callers of
tcf_fill_node() and make sure they pass the correct fh.

In any case, can we make that a followup - because this is a bug
fix?
I will send it and you could still comment if you dont find that
sufficient.

cheers,
jamal
