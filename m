From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 1/6] bpf: introduce BPF_PROG_TEST_RUN command
Date: Thu, 30 Mar 2017 20:24:57 -0700
Message-ID: <35b22fbd-546b-779b-9dc0-1f9a914e33cf@fb.com>
References: <20170331013157.3298003-1-ast@fb.com>
 <20170331013157.3298003-2-ast@fb.com>
 <9105ab34-8fee-fab4-96fe-3bfe7f3a84b7@huawei.com>
 <d8c30545-b247-6831-41cc-a546404d6b0a@fb.com>
 <67b19080-26f9-67ac-d7fa-e621a90c54bb@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "Wangnan (F)" <wangnan0@huawei.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:33414 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753755AbdCaDZq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 23:25:46 -0400
In-Reply-To: <67b19080-26f9-67ac-d7fa-e621a90c54bb@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/30/17 8:12 PM, Wangnan (F) wrote:
>
>
> On 2017/3/31 10:57, Alexei Starovoitov wrote:
>> On 3/30/17 7:53 PM, Wangnan (F) wrote:
>>> I suggest using a CONFIG option to enable/disable code in
>>> test_run.o to reduce attack plane.
>>
>> attack plane? what attack do you see and how config helps?
>>
>
> I think all testing features are not required to be compiled
> for a production system. A feature which should never be used
> looks dangerous to me.

It is required on production system, since xdp testing and
xdp production has to use the same kernel. We cannot
keep rebooting the server back and forth to test and then to run.
It's not testing the kernel features, it's testing bpf programs
which are technically user space components.

> I suggest adding a CONFIG option like CONFIG_BPF_PROGRAM_TEST_RUN
> to control whether the kernel should be compiled with this feature
> or not. We can enable by default, and give people a chance to
> turn it off. At least in my company people tends to turn all
> unneeded features off. If you don't provide a config option they
> will make one by themselves.

Using this logic huawei should be turning off xdp as well.
Sorry we're not going stub xdp facility out of the core
and the drivers just because you don't use it.
