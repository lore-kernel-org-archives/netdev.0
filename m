From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 6/9] bpf: fix stack_depth usage by test_bpf.ko
Date: Wed, 31 May 2017 15:41:09 -0700
Message-ID: <0da22ba6-bb34-23da-2722-3e45fd195e17@fb.com>
References: <20170530203135.3642768-7-ast@fb.com>
 <20170531.141502.1137764740674039078.davem@davemloft.net>
 <73af1b50-38b0-b7f3-5c74-e425d47209b6@fb.com>
 <20170531.144320.1591618196176086735.davem@davemloft.net>
 <f79ef874-55a1-cd58-a0e4-9859401a9249@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:32873 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751551AbdEaWll (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 18:41:41 -0400
In-Reply-To: <f79ef874-55a1-cd58-a0e4-9859401a9249@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/31/17 11:45 AM, Alexei Starovoitov wrote:
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

btw, when added a bunch of these '.stack_depth = 40'
I was thinking to randomize these values in [40, 512]
range to stress test interpreter and JITs more,
but then decided not to do that to avoid questions
why these numbers don't match the instructions.
Now I'm thinking we should actually do it for two reasons:
- to stress test stuff
- and to demonstrate more clearly that test_bpf.ko can
really do things that user space cannot and that's the
purpose of this .ko
Thoughts?
