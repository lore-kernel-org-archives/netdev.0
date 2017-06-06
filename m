From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 6/9] bpf: fix stack_depth usage by test_bpf.ko
Date: Tue, 06 Jun 2017 12:19:39 +0200
Message-ID: <593681BB.5080306@iogearbox.net>
References: <20170530203135.3642768-7-ast@fb.com> <20170531.141502.1137764740674039078.davem@davemloft.net> <73af1b50-38b0-b7f3-5c74-e425d47209b6@fb.com> <20170531.144320.1591618196176086735.davem@davemloft.net> <f79ef874-55a1-cd58-a0e4-9859401a9249@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50510 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751329AbdFFKTn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 06:19:43 -0400
In-Reply-To: <f79ef874-55a1-cd58-a0e4-9859401a9249@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/31/2017 08:45 PM, Alexei Starovoitov wrote:
> On 5/31/17 11:43 AM, David Miller wrote:
>> From: Alexei Starovoitov <ast@fb.com>
>> Date: Wed, 31 May 2017 11:39:37 -0700
>>
>>> On 5/31/17 11:15 AM, David Miller wrote:
>>>> From: Alexei Starovoitov <ast@fb.com>
>>>> Date: Tue, 30 May 2017 13:31:32 -0700
>>>>
>>>>> test_bpf.ko doesn't call verifier before selecting interpreter or
>>>>> JITing,
>>>>> hence the tests need to manually specify the amount of stack they
>>>>> consume.
>>>>>
>>>>> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
>>>>> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
>>>>
>>>> I do not like this and the previous patch, it seems so error prone.
>>>
>>> in what sense 'error prone' ?
>>
>> In the sense that a human computes these numbers, and nothing checks
>> if it is correct or not until program perhaps crashes if the value is
>> wrong.
>
> right. that's how all these tests are.
> See bpf_fill_ld_abs_vlan_push_pop() for example.
> If that codegen has a bug, it will crash the kernel.
> That's why it's done from kernel module to do things
> that user space cannot do.

Would probably have been easier to just default the tests to use
MAX_BPF_STACK if nothing further is specified, but I think it may
still be useful to test JIT implementations supporting this for
the non-default cases.
