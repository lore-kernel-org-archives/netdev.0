From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] can: fix warning in bcm_connect/proc_register
Date: Mon, 24 Oct 2016 13:10:39 -0700
Message-ID: <CAM_iQpXj3ktALCmjwaPKJuf0SDEc6Txk-yYkRzZ79LFEsxOx3w@mail.gmail.com>
References: <20161024191126.30256-1-socketcan@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrey Konovalov <andreyknvl@google.com>,
        David Miller <davem@davemloft.net>, linux-can@vger.kernel.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20161024191126.30256-1-socketcan@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 24, 2016 at 12:11 PM, Oliver Hartkopp
<socketcan@hartkopp.net> wrote:
>         if (proc_dir) {
>                 /* unique socket address as filename */
>                 sprintf(bo->procname, "%lu", sock_i_ino(sk));
>                 bo->bcm_proc_read = proc_create_data(bo->procname, 0644,
>                                                      proc_dir,
>                                                      &bcm_proc_fops, sk);
> +               if (!bo->bcm_proc_read) {
> +                       ret = -ENOMEM;
> +                       goto fail;
> +               }

Well, I meant we need to call proc_create_data() once per socket,
so we need a check before proc_create_data() too.

Thanks.
