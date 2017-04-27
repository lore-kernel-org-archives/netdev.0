From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 4/6] bpf: track if the bpf program was loaded
 with SYS_ADMIN capabilities
Date: Thu, 27 Apr 2017 13:39:24 +0200
Message-ID: <2a6762cb-fbf5-42ce-ed41-4f1a6c84ae44@stressinduktion.org>
References: <20170426182419.14574-1-hannes@stressinduktion.org>
 <20170426182419.14574-5-hannes@stressinduktion.org>
 <59010B5A.6060509@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.com, jbenc@redhat.com,
        aconole@bytheb.org
To: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:49435 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S936006AbdD0Lj2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 07:39:28 -0400
In-Reply-To: <59010B5A.6060509@iogearbox.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26.04.2017 23:04, Daniel Borkmann wrote:
> On 04/26/2017 08:24 PM, Hannes Frederic Sowa wrote:
>> diff --git a/net/core/filter.c b/net/core/filter.c
>> index 9a37860a80fc78..dc020d40bb770a 100644
>> --- a/net/core/filter.c
>> +++ b/net/core/filter.c
>> @@ -1100,7 +1100,7 @@ int bpf_prog_create(struct bpf_prog **pfp,
>> struct sock_fprog_kern *fprog)
>>       if (!bpf_check_basics_ok(fprog->filter, fprog->len))
>>           return -EINVAL;
>>
>> -    fp = bpf_prog_alloc(bpf_prog_size(fprog->len), 0);
>> +    fp = bpf_prog_alloc(bpf_prog_size(fprog->len), 0, false);
>>       if (!fp)
>>           return -ENOMEM;
>>
> 
> Did you check that transferring allow_ptr_leaks doesn't have a side
> effect on the nfp JIT? I believe it can also do cbpf migrations to
> a certain extend.

Initially I grepped allow_ptr_leaks usages and didn't see it. I just
looked through the code path and didn't see how it could have an impact.
Also, cbpf programs shouldn't depend on allow_ptr_leak to the best of my
knowledge, no?

Thanks,
Hannes
