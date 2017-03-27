From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH v2] xfrm: branchless addr4_match() on 64-bit
Date: Mon, 27 Mar 2017 16:11:32 +0300
Message-ID: <CACVxJT9NJtqpteJ5hVX8FnBYo00_-NokuB2zgq_tuK2b_qA51A@mail.gmail.com>
References: <20170323233247.GE31372@avx2> <063D6719AE5E284EB5DD2968C1650D6DCFFB93A8@AcuExch.aculab.com>
 <20170325163712.GA4950@avx2> <20170325164117.GB4950@avx2> <20170327103719.GI23004@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Laight <David.Laight@aculab.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:33417 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752786AbdC0NLj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 09:11:39 -0400
Received: by mail-qk0-f193.google.com with SMTP id p22so7647797qka.0
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 06:11:38 -0700 (PDT)
In-Reply-To: <20170327103719.GI23004@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 27, 2017 at 1:37 PM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> On Sat, Mar 25, 2017 at 07:41:17PM +0300, Alexey Dobriyan wrote:
>> After (no branches):
>>
>>       mov    r8d,0x20
>>       mov    rdx,0xffffffffffffffff
>>       mov    esi,DWORD PTR [rsi+0x2c]
>>       mov    ecx,r8d
>>       sub    cl,BYTE PTR [rdi+0x2a]
>>       xor    esi,DWORD PTR [rbx]
>>       mov    rdi,rdx
>>       xor    eax,eax
>>       shl    rdi,cl
>>       bswap  edi
>>
>> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
>
> Also applied to ipsec-next, thanks for the patches Alexey!

Speaking of optimizations.
1) All those ntohl() invocations inside hashes are likely
unnecessary (hashing is hashing after all).

2) I din't look closely but it can be further optimized by storing
32 - prefixlen (or 128 - prefixlen) but I don't know if you'll accept
such horror. :-)
