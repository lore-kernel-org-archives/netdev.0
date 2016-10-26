From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/3] bpf: Add new cgroups prog type to enable
 sock modifications
Date: Tue, 25 Oct 2016 20:05:39 -0600
Message-ID: <660435c4-6cea-9648-0106-afb3ab6910fc@cumulusnetworks.com>
References: <1477434613-3169-1-git-send-email-dsa@cumulusnetworks.com>
 <1477434613-3169-3-git-send-email-dsa@cumulusnetworks.com>
 <580FEA98.1090809@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: daniel@zonque.org, ast@fb.com
To: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36503 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751015AbcJZCFm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 22:05:42 -0400
Received: by mail-pf0-f178.google.com with SMTP id e6so129323218pfk.3
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2016 19:05:42 -0700 (PDT)
In-Reply-To: <580FEA98.1090809@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/16 5:28 PM, Daniel Borkmann wrote:
>> +BPF_CALL_3(bpf_sock_store_u32, struct sock *, sk, u32, offset, u32, val)
>> +{
>> +    u8 *ptr = (u8 *)sk;
>> +
>> +    if (unlikely(offset > sizeof(*sk)))
>> +        return -EFAULT;
>> +
>> +    *((u32 *)ptr) = val;
>> +
>> +    return 0;
>> +}
> 
> Seems strange to me. So, this helper allows to overwrite arbitrary memory
> of a struct sock instance. Potentially we could crash the kernel.
> 
> And in your sock_filter_convert_ctx_access(), you already implement inline
> read/write for the context ...
> 
> Your demo code does in pseudocode:
> 
>   r1 = sk
>   r2 = offsetof(struct bpf_sock, bound_dev_if)
>   r3 = idx
>   r1->sk_bound_dev_if = idx
>   sock_store_u32(r1, r2, r3) // updates sk_bound_dev_if again to idx
>   return 1
> 
> Dropping that helper from the patch, the only thing a program can do here
> is to read/write the sk_bound_dev_if helper per cgroup. Hmm ... dunno. So
> this really has to be for cgroups v2, right?

Showing my inexperience with the bpf code. The helper can be dropped. I'll do that for v2.

Yes, Daniel's patch set provides the infra for this one and it has a cgroups v2 limitation.
