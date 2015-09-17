From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next 1/2] cls_bpf: introduce integrated actions
Date: Thu, 17 Sep 2015 15:13:31 +0200
Message-ID: <55FABC7B.6060502@iogearbox.net>
References: <1442383543-4720-1-git-send-email-ast@plumgrid.com> <1442383543-4720-2-git-send-email-ast@plumgrid.com> <55FAB40E.304@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34510 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752322AbbIQNNe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 09:13:34 -0400
In-Reply-To: <55FAB40E.304@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jamal,

On 09/17/2015 02:37 PM, Jamal Hadi Salim wrote:
> On 09/16/15 02:05, Alexei Starovoitov wrote:
>> From: Daniel Borkmann <daniel@iogearbox.net>
>>
>> Often cls_bpf classifier is used with single action drop attached.
>> Optimize this use case and let cls_bpf return both classid and action.
>> For backwards compatibility reasons enable this feature under
>> TCA_BPF_FLAG_ACT_DIRECT flag.
>>
>
> This is going off in a different direction really.
> You are replicating the infrastructure inside bpf.

Hmm, I don't really agree. With cls_bpf you have non-linear
classifications as opposed to walking a chain of classifiers:
worst case, I have to walk through N classifiers just to find
out that the last one matches that I need to drop - this doesn't
scale at all. Given that we can make this decision right here,
we can use this fact and have simple return codes provided as
well. It only supplements non-linear classification that was
from the very beginning of cls_bpf a core part of it.

Thanks,
Daniel
