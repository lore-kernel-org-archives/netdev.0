From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: net: heap out-of-bounds in
 fib6_clean_node/rt6_fill_node/fib6_age/fib6_prune_clone
Date: Tue, 25 Apr 2017 09:51:59 -0600
Message-ID: <d789b43c-3267-9729-7162-e71c840c9b6d@cumulusnetworks.com>
References: <CACT4Y+YrA45diWz_8f4St8oX6aTC1kuGXMUvniGRbqXSGwawZQ@mail.gmail.com>
 <CACT4Y+aomj0W8M9JNr1GLsT8EFFHV9YsOTYzWkvwKZANE9hiBQ@mail.gmail.com>
 <CACT4Y+aDzAYs9mbNGeFEkYSB2wTwomZTGEKn4hDH0PAb4uiLqw@mail.gmail.com>
 <2b60b1b8-4766-0e36-f6fb-79914bf1925d@cumulusnetworks.com>
 <CACT4Y+YpUZ+7f5bzPh1hATwUXaZaPTu4rYYdz0RY1MHA1WG3SA@mail.gmail.com>
 <328b1fa7-2d97-6ae3-3b87-e33a0d564ad9@cumulusnetworks.com>
 <CACT4Y+aQFe+M=ESuShQ4FYNWAd8CNEQ=0rW+aAB0P-tp=PpFyQ@mail.gmail.com>
 <CACT4Y+aQgM=9QMkyfcXF2B5gGidvL07JP_m_inNXTPXU22i=aA@mail.gmail.com>
 <CACT4Y+Yx1cgWCkC2c7bze1V1VaecgBfioMvKS2-FUeaRr4DGXg@mail.gmail.com>
 <CACT4Y+bcMz13ad2kLaZGvct5sQ+RDki0StnOEbz3exAa8=zxqQ@mail.gmail.com>
 <CACT4Y+Z6f4aOxMZW44WXdYEyDJbGBYLnjKsHBXfK800h+EkrxA@mail.gmail.com>
 <2270c1ca-9481-60c1-9c29-87669223bded@cumulusnetworks.com>
 <CACT4Y+aUROZgAczRfntp5Rgvzcypviz5ZWBPdE6MWSiO0-3jEg@mail.gmail.com>
 <CAAeHK+zx6W_yxnoEQ2Pc1AT4uLXqYZaoi5oQBeuCntdGS38TQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>,
        Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+zx6W_yxnoEQ2Pc1AT4uLXqYZaoi5oQBeuCntdGS38TQg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/18/17 2:43 PM, Andrey Konovalov wrote:
> kasan: CONFIG_KASAN_INLINE enabled
> kasan: GPF could be caused by NULL-ptr deref or user memory access
> general protection fault: 0000 [#1] SMP KASAN
> Modules linked in:
> CPU: 1 PID: 4035 Comm: a.out Not tainted 4.11.0-rc7+ #250
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> task: ffff880069809600 task.stack: ffff880062dc8000
> RIP: 0010:ip6_rt_cache_alloc+0xa6/0x560 net/ipv6/route.c:975
> RSP: 0018:ffff880062dced30 EFLAGS: 00010206
> RAX: dffffc0000000000 RBX: ffff8800670561c0 RCX: 0000000000000006
> RDX: 0000000000000003 RSI: ffff880062dcfb28 RDI: 0000000000000018
> RBP: ffff880062dced68 R08: 0000000000000001 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
> R13: ffff880062dcfb28 R14: dffffc0000000000 R15: 0000000000000000
> FS:  00007feebe37e7c0(0000) GS:ffff88006cb00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00000000205a0fe4 CR3: 000000006b5c9000 CR4: 00000000000006e0
> Call Trace:
>  ip6_pol_route+0x1512/0x1f20 net/ipv6/route.c:1128

This one is fixed by:

commit 557c44be917c322860665be3d28376afa84aa936
Author: David Ahern <dsa@cumulusnetworks.com>
Date:   Wed Apr 19 14:19:43 2017 -0700

    net: ipv6: RTF_PCPU should not be settable from userspace
