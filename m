From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net/tcp: warning in tcp_try_coalesce/skb_try_coalesce
Date: Thu, 2 Feb 2017 13:59:29 +0100
Message-ID: <CACT4Y+Z8uSWJaW+QXSOr7dCo5fSNrMu6fHxPcDBxL08qQUvRMw@mail.gmail.com>
References: <CAAeHK+xaFar2pj1xkbkhfjN+3ucLsfMpoHWFAKcHq3-F_Zm+mw@mail.gmail.com>
 <CANn89iKSSmaSHJGfgR4AkRgMRfYx+52XXjWsxZovUzorpneL=g@mail.gmail.com>
 <CACT4Y+Yw8_ZkjajkGdZ=71Mo83O+K=NJTZO+cM-+8UzTzHC-=A@mail.gmail.com> <1486038029.13103.17.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486038029.13103.17.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 2, 2017 at 1:20 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2017-02-02 at 10:05 +0100, Dmitry Vyukov wrote:
>> On Tue, Jan 31, 2017 at 3:27 PM, 'Eric Dumazet' via syzkaller
>> <syzkaller@googlegroups.com> wrote:
>> > On Tue, Jan 31, 2017 at 5:17 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
>> >> Hi,
>> >>
>> >> I've got the following error report while running the syzkaller fuzzer.
>> >>
>> >> On commit 566cf877a1fcb6d6dc0126b076aad062054c2637 (4.10-rc6).
>> >>
>> >> The fuzzer hits this issue quite often, but I don't have a working reproducer.
>> >>
>> >> WARNING: CPU: 3 PID: 7091 at net/core/skbuff.c:4331
>> >> skb_try_coalesce+0x14b1/0x1f80 net/core/skbuff.c:4331
>> >> Kernel panic - not syncing: panic_on_warn set ...
>> ...
>> > Have you tried the patch we added recently into net-next ?
>> >
>> > https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=158f323b9868b59967ad96957c4ca388161be321
>>
>>
>> I've tried this patch, and it does _not_ help.
>> I am currently on a2ca3d617944417e9dd5f09fc8a4549cda115f4f, and I
>> applied the patch on top (had to do a little merging in af_netlink.c):
>> https://gist.githubusercontent.com/dvyukov/b4fd206f7dde763b3113a4543c57e7bb/raw/784c5b1bcb06f2a22c55eb4c4f8f83d627cd1ab9/gistfile1.txt
>> Still getting the same warning.
>>
>> But now I have a repro:
>> https://gist.githubusercontent.com/dvyukov/88fdb6d93507b36f81377191b0694f9b/raw/81cc11e8b78b6bbc5cffc79b442ce998c49af226/gistfile1.txt
>>
>
> Interesting. This repro does not trigger the bug on net-next.


Right, I can confirm that this is not happening on net-next tip
(62e13097c46c69dbd7544ab2cd585ccf48f360a4).
I reproduced it on a random month old commit on net-next, though
(23a8ed4a624324dc696c328f09bd502c4a3816f0). Let's consider that this
is accidentally fixed by something in that range.
