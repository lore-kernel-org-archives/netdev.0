From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH 0/2][v2] Add the ability to do BPF directed error
 injection
Date: Tue, 31 Oct 2017 18:58:00 -0700
Message-ID: <d01b9aa5-2571-2c43-a521-ea47567ab0d1@fb.com>
References: <1509464757-2222-1-git-send-email-josef@toxicpanda.com>
 <20171101.105502.2238912905275925246.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <ast@kernel.org>, <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>, <josef@toxicpanda.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:54746 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932210AbdKAB6M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 21:58:12 -0400
In-Reply-To: <20171101.105502.2238912905275925246.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/17 6:55 PM, David Miller wrote:
> From: Josef Bacik <josef@toxicpanda.com>
> Date: Tue, 31 Oct 2017 11:45:55 -0400
>
>> v1->v2:
>> - moved things around to make sure that bpf_override_return could really only be
>>   used for an ftrace kprobe.
>> - killed the special return values from trace_call_bpf.
>> - renamed pc_modified to bpf_kprobe_state so bpf_override_return could tell if
>>   it was being called from an ftrace kprobe context.
>> - reworked the logic in kprobe_perf_func to take advantage of bpf_kprobe_state.
>> - updated the test as per Alexei's review.
>>
>> A lot of our error paths are not well tested because we have no good way of
>> injecting errors generically.  Some subystems (block, memory) have ways to
>> inject errors, but they are random so it's hard to get reproduceable results.
>>
>> With BPF we can add determinism to our error injection.  We can use kprobes and
>> other things to verify we are injecting errors at the exact case we are trying
>> to test.  This patch gives us the tool to actual do the error injection part.
>> It is very simple, we just set the return value of the pt_regs we're given to
>> whatever we provide, and then override the PC with a dummy function that simply
>> returns.
>>
>> Right now this only works on x86, but it would be simple enough to expand to
>> other architectures.  Thanks,
>
> This appears to moreso target the tracing tree than the networking tree.
>
> Let me know if that's not the case and I should be the one intergrating
> these changes.

i don't think it will apply to anything but net-next. If it goes any
other tree we will have major conflicts during merge window.
btw I haven't reviewed them for the second time.
