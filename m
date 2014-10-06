From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net-next] net_sched: refactor out tcf_exts
Date: Mon, 6 Oct 2014 09:56:01 -0700
Message-ID: <CAHA+R7PpLzGoDqctTC8DKBkYqsbnY5a8xMTdTe3PzWy8Gc3gqQ@mail.gmail.com>
References: <1412376709-25564-1-git-send-email-xiyou.wangcong@gmail.com>
	<5431F4A1.3040107@gmail.com>
	<543206B4.7090504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:63941 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825AbaJFQ4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 12:56:04 -0400
Received: by mail-la0-f54.google.com with SMTP id gm9so4644660lab.41
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 09:56:02 -0700 (PDT)
In-Reply-To: <543206B4.7090504@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 5, 2014 at 8:04 PM, John Fastabend <john.fastabend@gmail.com> wrote:
> On 10/05/2014 06:47 PM, John Fastabend wrote:
>>
>> On 10/03/2014 03:51 PM, Cong Wang wrote:
>>>
>>> As Jamal pointed it out, tcf_exts is really unnecessary,
>>> we can definitely refactor it out without losing any functionality.
>>> This could also remove an indirect layer which makes the code
>>> much easier to read.
>>>
>>> This patch:
>>>
>>> 1) moves exts->action and exts->police into tp->ops, since they
>>> are statically assigned
>>>
>>> 2) moves exts->actions list head out
>>>
>>> 3) removes exts->type, act->type does the same thing
>>>
>>> 4) renames tcf_exts_*() functions to tcf_act_*()
>>>
>>> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>>> Cc: John Fastabend <john.r.fastabend@intel.com>
>>> Cc: "David S. Miller" <davem@davemloft.net>
>>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>>> ---
>>
>>
>> Looks OK to me and removes a layer of abstraction without changing
>> the code much. This is going to conflict with my series so I'll hold
>> off resubmitting it until this is dealt with. I need to respin that
>> ematch fix up to drop the ingress lock.
>>
>> Acked-by: John Fastabend <john.r.fastabend@intel.com>
>>
>> [...]
>>
>
> But after running my test kit I see a null pointer dereference
> in cls_cgroup in tcf_act_change().
>
> Looks like you dropped an initializer...

Oops, yeah, should have an INIT_LIST_HEAD()...

I will send an update.

Thanks!
