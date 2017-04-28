From: Alexei Starovoitov <ast@fb.com>
Subject: Re: llvm-objdump...
Date: Fri, 28 Apr 2017 10:18:07 -0700
Message-ID: <43292fe3-f257-c8b8-c98b-de31f77f1c31@fb.com>
References: <612f0df6-711c-b6b1-4bd7-596a7f329737@fb.com>
 <20170428.121710.1780087759147659481.davem@davemloft.net>
 <c9e9eaa7-0fa8-440a-dc75-2d4020b8c429@fb.com>
 <20170428.123818.2002639536695380745.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:50631 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1164744AbdD1RSl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 13:18:41 -0400
In-Reply-To: <20170428.123818.2002639536695380745.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/28/17 9:38 AM, David Miller wrote:
> From: Alexei Starovoitov <ast@fb.com>
> Date: Fri, 28 Apr 2017 09:22:32 -0700
>
>> On 4/28/17 9:17 AM, David Miller wrote:
>>> Even if I give it -triple=bpfeb it emits immediates incorrectly.
>>>
>>> The bug is certainly in the insn field fetcher of the disassembler.
>>
>> got it. so the binary looks correct, but disasm output is wrong?
>
> F.e.
>
>       12:       07 70 00 00 00 00 00 06         r0 += 100663296
>
> Should be "r0 += 6"

Pushed the fix into the llvm trunk:
https://reviews.llvm.org/rL301653

if buildbots don't yell at me in the next few hours then it's
probably good.
