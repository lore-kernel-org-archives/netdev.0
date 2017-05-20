From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v2 1/3] bpf: Use 1<<16 as ceiling for immediate alignment
 in verifier.
Date: Fri, 19 May 2017 17:20:58 -0700
Message-ID: <e3e3e6b6-2ce5-2567-2d1c-b006522389bc@fb.com>
References: <a0a47297-4765-3ba0-3ea2-013dda40e84a@solarflare.com>
 <20170519.164154.368589666756458942.davem@davemloft.net>
 <a4a1fe92-fa35-1d3f-1b3c-e094d715db2c@fb.com>
 <20170519.191615.136362788931426782.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ecree@solarflare.com>, <daniel@iogearbox.net>,
        <alexei.starovoitov@gmail.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:37780 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750814AbdETAVY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 20:21:24 -0400
In-Reply-To: <20170519.191615.136362788931426782.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/19/17 4:16 PM, David Miller wrote:
> From: Alexei Starovoitov <ast@fb.com>
> Date: Fri, 19 May 2017 14:37:56 -0700
>
>> On 5/19/17 1:41 PM, David Miller wrote:
>>> From: Edward Cree <ecree@solarflare.com>
>>> Date: Fri, 19 May 2017 18:17:42 +0100
>>>
>>>> One question: is there a way to build the verifier as userland code
>>>>  (or at least as a module), or will I have to reboot every time I
>>>>  want to test a change?
>>>
>>> There currently is no such machanism, you will have to reboot every
>>> time.
>>>
>>> I have considered working on making the code buildable outside of the
>>> kernel.  It shouldn't be too hard.
>>
>> it's not hard.
>> We did it twice and both times abandoned.
>> First time to have 'user space verifier' to check programs before
>> loading and second time for fuzzing via llvm.
>> Abandoned since it diverges very quickly from kernel.
>>
>
> Well, my idea was the create an environment in which kernel verifier.c
> could be built as-is.
>
> Maybe there would be some small compromises in verifier.c such as an
> ifdef test or two, but that should be it.

that's exactly what we did the first time. Added few ifdef to verifier.c
Second time we went even further by compiling kernel/bpf/verifier.c
as-is and linking everything magically via user space hooks
all the way that test_verifier.c runs as-is but calling
bpf_check() function that was compiled for user space via clang.
That code is here:
https://github.com/iovisor/bpf-fuzzer
It's definitely possible to refresh it and make it work again.

My point that unless we put such 'lets build verifier.c for user space'
as part of tools/testing/selftests/ or something, such project is
destined to bit rot.
