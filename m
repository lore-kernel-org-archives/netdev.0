From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] net: filter: initialize A and X registers
Date: Wed, 23 Apr 2014 13:45:50 +0200
Message-ID: <5357A7EE.6040404@redhat.com>
References: <1398223137-5463-1-git-send-email-ast@plumgrid.com>  <20140422.235745.1219194947074686642.davem@davemloft.net> <1398229980.29914.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ast@plumgrid.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11788 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752589AbaDWLp5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 07:45:57 -0400
In-Reply-To: <1398229980.29914.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/23/2014 07:13 AM, Eric Dumazet wrote:
> On Tue, 2014-04-22 at 23:57 -0400, David Miller wrote:
>> From: Alexei Starovoitov <ast@plumgrid.com>
>> Date: Tue, 22 Apr 2014 20:18:57 -0700
>>
>>> exisiting BPF verifier allows uninitialized access to registers,
>>> 'ret A' is considered to be a valid filter.
>>> So initialize A and X to zero to prevent leaking kernel memory
>>> In the future BPF verifier will be rejecting such filters
>>>
>>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>>
>> Has the code always been like this?
>>
>> Did the eBPF changes introduce this problem either directly or
>> indirectly?
>
> Original code was fine AFAIK

Yep.

> Fixes: bd4cf0ed331a2 ("net: filter: rework/optimize internal BPF interpreter's instruction set")
>
> David, is it possible for you to push net-next tree ?

I think this would need to go into net tree first and then
for the upcoming changes, net would need to be merged into
net-next. This will create a minor merge conflict with the
BPF prandom extension; fix is to remove the defines near
__get_random_u32(), as they will be above __sk_run_filter()
already.
