From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/3] bpf: Use 1<<16 as ceiling for immediate
 alignment in verifier.
Date: Fri, 19 May 2017 19:16:15 -0400 (EDT)
Message-ID: <20170519.191615.136362788931426782.davem@davemloft.net>
References: <a0a47297-4765-3ba0-3ea2-013dda40e84a@solarflare.com>
        <20170519.164154.368589666756458942.davem@davemloft.net>
        <a4a1fe92-fa35-1d3f-1b3c-e094d715db2c@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ecree@solarflare.com, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59076 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751049AbdESXQT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 19:16:19 -0400
In-Reply-To: <a4a1fe92-fa35-1d3f-1b3c-e094d715db2c@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Fri, 19 May 2017 14:37:56 -0700

> On 5/19/17 1:41 PM, David Miller wrote:
>> From: Edward Cree <ecree@solarflare.com>
>> Date: Fri, 19 May 2017 18:17:42 +0100
>>
>>> One question: is there a way to build the verifier as userland code
>>>  (or at least as a module), or will I have to reboot every time I
>>>  want to test a change?
>>
>> There currently is no such machanism, you will have to reboot every
>> time.
>>
>> I have considered working on making the code buildable outside of the
>> kernel.  It shouldn't be too hard.
> 
> it's not hard.
> We did it twice and both times abandoned.
> First time to have 'user space verifier' to check programs before
> loading and second time for fuzzing via llvm.
> Abandoned since it diverges very quickly from kernel.
> 

Well, my idea was the create an environment in which kernel verifier.c
could be built as-is.

Maybe there would be some small compromises in verifier.c such as an
ifdef test or two, but that should be it.

It really is just a piece of what amounts to compiler infrastructure
and not very kernel specific.
