From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 4/6] tools/lib/bpf: expose
 bpf_program__set_type()
Date: Thu, 30 Mar 2017 19:56:24 -0700
Message-ID: <9459104d-3c7b-c77a-be59-c236dc495952@fb.com>
References: <20170331013157.3298003-1-ast@fb.com>
 <20170331013157.3298003-5-ast@fb.com>
 <b4ebf55a-d509-f4b8-8d71-c5dfc31f9c9d@huawei.com>
 <1e3156bf-7334-53fe-1069-7d7bd9dc09fb@fb.com>
 <97e058b2-08e6-c99e-48ae-09a836696ad8@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "Wangnan (F)" <wangnan0@huawei.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:59005 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752773AbdCaC47 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 22:56:59 -0400
In-Reply-To: <97e058b2-08e6-c99e-48ae-09a836696ad8@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/30/17 7:48 PM, Wangnan (F) wrote:
>
>
> On 2017/3/31 10:37, Alexei Starovoitov wrote:
>> On 3/30/17 7:33 PM, Wangnan (F) wrote:
>>>> +void bpf_program__set_type(struct bpf_program *prog, enum
>>>> bpf_prog_type type);
>>>>
>>>
>>> This makes libbpf.h depend on uapi/linux/bpf.h (because of enum
>>> bpf_prog_type), which is not always available.
>>>
>>> What about defining another enum inside libbpf.h?
>>
>> how about just including bpf.h? or making it 'int' instead of enum?
>>
>
> Including either kernel header into libbpf.h makes a lot of trouble,
> because kernel header and uapi have many other things we don't need
> and may conflict with existing code.

I'm not proposing to include kernel headers. Regular 
/usr/include/linux/bpf.h is enough. This library isn't going to be 
compiled on distros
that don't have bpf support anyway.

> Making it 'int' looks like a backdoor. We still need macro to define
> each program type.

macro for each program wasn't the greatest idea. It always
behind new program types and not usable for this use case.
See patches 5 and 6.
