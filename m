From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next 1/2] cls_bpf: introduce integrated actions
Date: Thu, 17 Sep 2015 08:19:16 -0700
Message-ID: <55FAD9F4.1010603@plumgrid.com>
References: <1442383543-4720-1-git-send-email-ast@plumgrid.com>
 <1442383543-4720-2-git-send-email-ast@plumgrid.com>
 <55FAB40E.304@mojatatu.com> <55FABC7B.6060502@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36224 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778AbbIQPTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 11:19:16 -0400
Received: by padhk3 with SMTP id hk3so22385301pad.3
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 08:19:16 -0700 (PDT)
In-Reply-To: <55FABC7B.6060502@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/17/15 6:13 AM, Daniel Borkmann wrote:
> Hi Jamal,
>
> On 09/17/2015 02:37 PM, Jamal Hadi Salim wrote:
>> On 09/16/15 02:05, Alexei Starovoitov wrote:
>>> From: Daniel Borkmann <daniel@iogearbox.net>
>>>
>>> Often cls_bpf classifier is used with single action drop attached.
>>> Optimize this use case and let cls_bpf return both classid and action.
>>> For backwards compatibility reasons enable this feature under
>>> TCA_BPF_FLAG_ACT_DIRECT flag.
>>>
>>
>> This is going off in a different direction really.
>> You are replicating the infrastructure inside bpf.
>
> Hmm, I don't really agree. With cls_bpf you have non-linear
> classifications as opposed to walking a chain of classifiers:
> worst case, I have to walk through N classifiers just to find
> out that the last one matches that I need to drop - this doesn't
> scale at all. Given that we can make this decision right here,
> we can use this fact and have simple return codes provided as
> well. It only supplements non-linear classification that was
> from the very beginning of cls_bpf a core part of it.

I don't see the replication either. May be the commit log was
misread as bpf program now executes the actions and bypasses
tcf_exts_exec() ? Well, that may be interesting idea for
the future, but that's not what the patch is doing.
With this patch cls_bpf can return single integer like
TC_ACT_SHOT/TC_ACT_OK that gact/act_bpf can already do as
an _optimization_ to avoid extra hops. To do full-fledged
action chaining the tcf_exts_exec() is used.
