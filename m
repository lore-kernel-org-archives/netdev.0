From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: net/key: slab-out-of-bounds in pfkey_compile_policy
Date: Mon, 8 May 2017 13:49:19 +0200
Message-ID: <20170508114918.GB9813@secunet.com>
References: <CAAeHK+xqxvEWMXS9sDNi2seUqFzJkijKJhivB8JDehpCJvBAaw@mail.gmail.com>
 <20170505091105.GA9813@secunet.com>
 <CAAeHK+xjbBPqHgBwBEK8=p7zUNCA144GqDSJMwUvz-1NFNQWxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        "Kostya Serebryany" <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAAeHK+xjbBPqHgBwBEK8=p7zUNCA144GqDSJMwUvz-1NFNQWxw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 05, 2017 at 02:18:01PM +0200, Andrey Konovalov wrote:
> On Fri, May 5, 2017 at 11:11 AM, Steffen Klassert
> <steffen.klassert@secunet.com> wrote:
> > On Tue, May 02, 2017 at 06:45:03PM +0200, Andrey Konovalov wrote:
> >> Hi,
> >>
> >> I've got the following error report while fuzzing the kernel with syzkaller.
> >>
> >> On commit d3b5d35290d729a2518af00feca867385a1b08fa (4.11).
> >>
> >> A reproducer and .config are attached.
> >>
> >> ==================================================================
> >> BUG: KASAN: slab-out-of-bounds in pfkey_compile_policy+0x8e6/0xd40 at
> >> addr ffff88006701f798
> >> Read of size 1280 by task a.out/4181
> >
> >
> > This bug was introduced twelve years ago...
> >
> > This patch is based just on code review, I don't have an option to
> > function test this. But I see that we now exit with -EINVAL before the
> > memcpy that causes the slab-out-of-bounds when using your reproducer,
> > so it should at least fix the bug.
> 
> Hi Steffen,
> 
> This patch fixes the issue for me.
> 
> Thanks!
> 
> Tested-by: Andrey Konovalov <andreyknvl@google.com>

Patch is now applied to the ipsec tree.
Thanks for reporting and testing!
