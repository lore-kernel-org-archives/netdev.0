From: David Ahern <dsahern@gmail.com>
Subject: Re: [net-next PATCH 00/10] BPF: sockmap and sk redirect support
Date: Wed, 16 Aug 2017 15:35:43 -0600
Message-ID: <8878cb28-a12e-cbe3-92c8-274d6c12d176@gmail.com>
References: <20170816.112819.1162151697604053267.davem@davemloft.net>
 <20170816.113501.1961184995639656444.davem@davemloft.net>
 <599497BC.6010205@gmail.com>
 <20170816.121305.1824274693019781357.davem@davemloft.net>
 <1502911033.4936.144.camel@edumazet-glaptop3.roam.corp.google.com>
 <59949E54.8050202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: daniel@iogearbox.net, ast@fb.com, tgraf@suug.ch,
        netdev@vger.kernel.org, tom@herbertland.com
To: John Fastabend <john.fastabend@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:34305 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752168AbdHPVfv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 17:35:51 -0400
Received: by mail-pg0-f53.google.com with SMTP id u185so29075080pgb.1
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 14:35:51 -0700 (PDT)
In-Reply-To: <59949E54.8050202@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/16/17 1:34 PM, John Fastabend wrote:
>> I also have a build error.
>>
>> $ git grep -n __sock_map_lookup_elem
>> include/linux/bpf.h:316:struct sock  *__sock_map_lookup_elem(struct bpf_map *map, u32 key);
>> kernel/bpf/sockmap.c:558:struct sock  *__sock_map_lookup_elem(struct bpf_map *map, u32 key)
>> net/core/filter.c:1881:         sk = __sock_map_lookup_elem(ri->map, ri->ifindex);
>>
>>
>>
>> $ make ...
>> ...
>> net/core/filter.c: In function ‘do_sk_redirect_map’:
>> net/core/filter.c:1881:3: error: implicit declaration of function ‘__sock_map_lookup_elem’ [-Werror=implicit-function-declaration]
>>    sk = __sock_map_lookup_elem(ri->map, ri->ifindex);
>>    ^
>> net/core/filter.c:1881:6: warning: assignment makes pointer from integer without a cast [enabled by default]
>>    sk = __sock_map_lookup_elem(ri->map, ri->ifindex);
>>       ^
>> cc1: some warnings being treated as errors
>> make[2]: *** [net/core/filter.o] Error 1
>> make[2]: *** Waiting for unfinished jobs....
>>
>>
> 
> Thanks Eric, I'll have a fix shortly.
> 

And I have a different build error:

$ make O=kbuild/rcu-lock-debug/ -j24 -s
scripts/Makefile.kasan:25: CONFIG_KASAN: compiler does not support all
options. Trying minimal configuration
scripts/Makefile.kasan:25: CONFIG_KASAN: compiler does not support all
options. Trying minimal configuration
kernel/bpf/sockmap.o: In function `smap_stop_sock':
/home/dsa/kernel-2.git/kernel/bpf/sockmap.c:297: undefined reference to
`strp_stop'
kernel/bpf/sockmap.o: In function `smap_gc_work':
/home/dsa/kernel-2.git/kernel/bpf/sockmap.c:419: undefined reference to
`strp_done'
kernel/bpf/sockmap.o: In function `smap_data_ready':
/home/dsa/kernel-2.git/kernel/bpf/sockmap.c:216: undefined reference to
`strp_data_ready'
kernel/bpf/sockmap.o: In function `smap_init_sock':
/home/dsa/kernel-2.git/kernel/bpf/sockmap.c:373: undefined reference to
`strp_init'
/home/dsa/kernel-2.git/Makefile:1000: recipe for target 'vmlinux' failed
make[1]: *** [vmlinux] Error 1
Makefile:145: recipe for target 'sub-make' failed
make: *** [sub-make] Error 2

I'm guessing a missing CONFIG tie in.
