From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 3/4] flowcache: make struct flow_cache_percpu::hash_rnd_recalc
 bool
Date: Wed, 22 Mar 2017 13:38:05 +0300
Message-ID: <CACVxJT9sC2Zmqd5XBQQ0b0vGaEPaH1MiursFP-dJxxg5PURM3g@mail.gmail.com>
References: <20170319222743.GC17015@avx2> <20170321.190948.1404708055619408272.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f177.google.com ([209.85.216.177]:34117 "EHLO
        mail-qt0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932323AbdCVKiH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 06:38:07 -0400
Received: by mail-qt0-f177.google.com with SMTP id n21so150301440qta.1
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 03:38:06 -0700 (PDT)
In-Reply-To: <20170321.190948.1404708055619408272.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 22, 2017 at 5:09 AM, David Miller <davem@davemloft.net> wrote:
> From: Alexey Dobriyan <adobriyan@gmail.com>
> Date: Mon, 20 Mar 2017 01:27:43 +0300
>
>> ->hash_rnd_recalc is only used in boolean context.
>>
>> Space savings on x86_64 come from the fact that "MOV rm8, imm8" is
>> shorter than "MOV rm32, imm32" by at least 3 bytes.
>>
>>       add/remove: 0/0 grow/shrink: 0/3 up/down: 0/-10 (-10)
>>       function                                     old     new   delta
>>       flow_cache_new_hashrnd                       166     163      -3
>>       flow_cache_cpu_up_prep                       171     168      -3
>>       flow_cache_lookup                           1148    1144      -4
>>       Total: Before=170822872, After=170822862, chg -0.00%
>>
>> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
>
> I agree with Eric Dumazet that we might have atomicity issues in the
> future because of this change.
>
> Why don't you drop this and resubmit just the other 3 patches which
> seem to be much less controversial?

Sure, bool patch was last minute change.
