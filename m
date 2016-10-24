From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/can: warning in bcm_connect/proc_register
Date: Mon, 24 Oct 2016 09:58:54 -0700
Message-ID: <CAM_iQpUAw6R1P-CQ-YJAYzb-HJXqUKAhJ5rLwp1L-ie3VkprSQ@mail.gmail.com>
References: <CAAeHK+x6w+Lg1GoCZXdjPtM6n72dpUbF_Bvtg80YNK-Wh8YJ4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        "David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+x6w+Lg1GoCZXdjPtM6n72dpUbF_Bvtg80YNK-Wh8YJ4w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 24, 2016 at 9:21 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi,
>
> I've got the following error report while running the syzkaller fuzzer:
>
> WARNING: CPU: 0 PID: 32451 at fs/proc/generic.c:345 proc_register+0x25e/0x300
> proc_dir_entry 'can-bcm/249757' already registered
> Kernel panic - not syncing: panic_on_warn set ...

Looks like we have two problems here:

1) A check for bo->bcm_proc_read != NULL seems missing
2) We need to lock the sock in bcm_connect().

I will work on a patch. Meanwhile, it would help a lot if you could provide
a reproducer.

Thanks!
