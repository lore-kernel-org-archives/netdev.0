From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 00/10] BPF: sockmap and sk redirect support
Date: Wed, 16 Aug 2017 12:34:44 -0700
Message-ID: <59949E54.8050202@gmail.com>
References: <20170816.112819.1162151697604053267.davem@davemloft.net>    <20170816.113501.1961184995639656444.davem@davemloft.net>       <599497BC.6010205@gmail.com>    <20170816.121305.1824274693019781357.davem@davemloft.net> <1502911033.4936.144.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: daniel@iogearbox.net, ast@fb.com, tgraf@suug.ch,
        netdev@vger.kernel.org, tom@herbertland.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33640 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752569AbdHPTez (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 15:34:55 -0400
Received: by mail-pg0-f65.google.com with SMTP id u185so6114553pgb.0
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 12:34:55 -0700 (PDT)
In-Reply-To: <1502911033.4936.144.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/16/2017 12:17 PM, Eric Dumazet wrote:
> On Wed, 2017-08-16 at 12:13 -0700, David Miller wrote:
>> From: John Fastabend <john.fastabend@gmail.com>
>> Date: Wed, 16 Aug 2017 12:06:36 -0700
>>
>>> On 08/16/2017 11:35 AM, David Miller wrote:
>>>> From: David Miller <davem@davemloft.net>
>>>> Date: Wed, 16 Aug 2017 11:28:19 -0700 (PDT)
>>>>
>>>>> From: John Fastabend <john.fastabend@gmail.com>
>>>>> Date: Tue, 15 Aug 2017 22:30:15 -0700
>>>>>
>>>>>> This series implements a sockmap and socket redirect helper for BPF
>>>>>> using a model similar to XDP netdev redirect.
>>>>>
>>>>> Series applied, thanks John.
>>>>>
>>>>
>>>> We get a legit warning from gcc due to these changes:
>>>>
>>>> kernel/bpf/sockmap.c: In function ‘smap_state_change’:
>>>> kernel/bpf/sockmap.c:156:21: warning: ‘psock’ may be used uninitialized in this function [-Wmaybe-uninitialized]
>>>>   struct smap_psock *psock;
>>>>
>>>> It's the default switch case in this function, psock is not initialized
>>>> for sure at this point.
>>>>
>>>
>>> I missed this with older gcc4 it seems. Fixed now and compiling without errors
>>> now with gcc4/5. Below is the diff and all verifier/sockmap tests pass. Want a
>>> v2 I presume?
>>
>> I already pushed out v1, so you'll need to send me a fixup patch.
> 
> I also have a build error.
> 
> $ git grep -n __sock_map_lookup_elem
> include/linux/bpf.h:316:struct sock  *__sock_map_lookup_elem(struct bpf_map *map, u32 key);
> kernel/bpf/sockmap.c:558:struct sock  *__sock_map_lookup_elem(struct bpf_map *map, u32 key)
> net/core/filter.c:1881:         sk = __sock_map_lookup_elem(ri->map, ri->ifindex);
> 
> 
> 
> $ make ...
> ...
> net/core/filter.c: In function ‘do_sk_redirect_map’:
> net/core/filter.c:1881:3: error: implicit declaration of function ‘__sock_map_lookup_elem’ [-Werror=implicit-function-declaration]
>    sk = __sock_map_lookup_elem(ri->map, ri->ifindex);
>    ^
> net/core/filter.c:1881:6: warning: assignment makes pointer from integer without a cast [enabled by default]
>    sk = __sock_map_lookup_elem(ri->map, ri->ifindex);
>       ^
> cc1: some warnings being treated as errors
> make[2]: *** [net/core/filter.o] Error 1
> make[2]: *** Waiting for unfinished jobs....
> 
> 

Thanks Eric, I'll have a fix shortly.
