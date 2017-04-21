From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/core: BUG in unregister_netdevice_many
Date: Fri, 21 Apr 2017 11:55:04 -0700
Message-ID: <CAM_iQpUoWzeZPSKTCm13tumvOa7fLMJnz_0F_LSq4odYvWtRaQ@mail.gmail.com>
References: <CAAeHK+zUZMGQuW=7Qhz3EWYjh6Zwv9eMBCiMCU79QrYNWox0-Q@mail.gmail.com>
 <CA+55aFwg=OtMWmU153uM27Fwk5eVv5ZBGBA9phQqVqn3nNAy6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        tcharding <me@tobin.cc>, Jiri Pirko <jiri@mellanox.com>,
        stephen hemminger <stephen@networkplumber.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFwg=OtMWmU153uM27Fwk5eVv5ZBGBA9phQqVqn3nNAy6Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 21, 2017 at 10:25 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Fri, Apr 21, 2017 at 5:48 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
>>
>> I've got the following error report while fuzzing the kernel with syzkaller.
>>
>> ------------[ cut here ]------------
>> kernel BUG at net/core/dev.c:6813!
>
> Another useless BUG_ON() that

I think we are double-unregister'ing the pim6reg device,
we probably need something like:

commit 7dc00c82cbb0119cf4663f65bbaa2cc55f961db2
Author: Wang Chen <wangchen@cn.fujitsu.com>
Date:   Mon Jul 14 20:56:34 2008 -0700

    ipv4: Fix ipmr unregister device oops

    An oops happens during device unregister.
