From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net 1/3] sched: cls_bpf: fix panic on filter replace
Date: Fri, 17 Jul 2015 14:31:02 -0700
Message-ID: <55A97416.60709@plumgrid.com>
References: <cover.1437163466.git.daniel@iogearbox.net>
 <094e34b7e8d45a323c5cf18a366665654b3f3e45.1437163466.git.daniel@iogearbox.net>
 <55A96E05.2090002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, jhs@mojatatu.com, edumazet@google.com,
	netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:32817 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751977AbbGQVbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 17:31:06 -0400
Received: by padck2 with SMTP id ck2so66501677pad.0
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 14:31:05 -0700 (PDT)
In-Reply-To: <55A96E05.2090002@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/17/15 2:05 PM, John Fastabend wrote:
> On 15-07-17 01:38 PM, Daniel Borkmann wrote:
>> >The following test case causes a NULL pointer dereference in cls_bpf:
>> >
>> >   FOO="1,6 0 0 4294967295,"
>> >   tc filter add dev foo parent 1: bpf bytecode "$FOO" flowid 1:1 action ok
>> >   tc filter replace dev foo parent 1: pref 49152 handle 0x1 \
>> >             bpf bytecode "$FOO" flowid 1:1 action drop
>> >
>> >The problem is that commit 1f947bf151e9 ("net: sched: rcu'ify cls_bpf")
>> >accidentally swapped the arguments of list_replace_rcu(), the old
>> >element needs to be the first argument and the new element the second.
>> >
>> >Fixes: 1f947bf151e9 ("net: sched: rcu'ify cls_bpf")
>> >Signed-off-by: Daniel Borkmann<daniel@iogearbox.net>
>> >---
> Thanks Daniel. Apparently I got this right in cls_basic but botched it
> here and in cls_flow.
>
> FWIW,
>
> Acked-by: John Fastabend<john.r.fastabend@intel.com>

Thanks for the quick fix.
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
