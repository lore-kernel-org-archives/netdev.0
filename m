From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: convert (struct ubuf_info)->refcnt to refcount_t
Date: Sat, 2 Sep 2017 23:39:02 -0400
Message-ID: <CAF=yD-J1tr=cikiFvf=y6=jHnZAZ_VhL+P04xfn7u4fZ0ki6Ow@mail.gmail.com>
References: <20170831203013.9219-3-edumazet@google.com> <201709030525.Cws08kPn%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <edumazet@google.com>, kbuild-all@01.org,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:37067 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752828AbdICDjn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 23:39:43 -0400
Received: by mail-oi0-f68.google.com with SMTP id b184so2877674oih.4
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 20:39:43 -0700 (PDT)
In-Reply-To: <201709030525.Cws08kPn%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 2, 2017 at 5:58 PM, kbuild test robot <lkp@intel.com> wrote:
> Hi Eric,
>
> [auto build test WARNING on net-next/master]
>
> url:    https://github.com/0day-ci/linux/commits/Eric-Dumazet/net-ubuf_info-refcnt-conversion/20170903-043506
> config: i386-randconfig-i1-201736 (attached as .config)
> compiler: gcc-4.8 (Debian 4.8.4-1) 4.8.4
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386
>
> All warnings (new ones prefixed by >>):
>
>    drivers//vhost/net.c: In function 'handle_tx':
>>> drivers//vhost/net.c:536:4: warning: passing argument 1 of 'atomic_set' from incompatible pointer type [enabled by default]
>        atomic_set(&ubuf->refcnt, 1);
>        ^
>    In file included from include/linux/atomic.h:4:0,
>                     from arch/x86/include/asm/thread_info.h:53,
>                     from include/linux/thread_info.h:37,
>                     from arch/x86/include/asm/preempt.h:6,
>                     from include/linux/preempt.h:80,
>                     from include/linux/spinlock.h:50,
>                     from include/linux/wait.h:8,
>                     from include/linux/eventfd.h:12,
>                     from drivers//vhost/net.c:10:
>    arch/x86/include/asm/atomic.h:36:29: note: expected 'struct atomic_t *' but argument is of type 'struct refcount_t *'
>     static __always_inline void atomic_set(atomic_t *v, int i)
>                                 ^

This is a false positive. This patch

  [net-next,2/2] net: convert (struct ubuf_info)->refcnt to refcount_t
  http://patchwork.ozlabs.org/patch/808402/

was superseded by

  [v2,net-next,2/2] net: convert (struct ubuf_info)->refcnt to refcount_t
  http://patchwork.ozlabs.org/patch/808477/

which has been merged into net-next as commit c1d1b437816f

That patch has the necessary change:

-                      atomic_set(&ubuf->refcnt, 1);
+                       refcount_set(&ubuf->refcnt, 1);
