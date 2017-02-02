From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net/tcp: warning in tcp_try_coalesce/skb_try_coalesce
Date: Thu, 2 Feb 2017 15:03:54 +0100
Message-ID: <CACT4Y+bmXmn6D7Dd8R3N4nDsRLO8WVTU3E_4hAnh0edmVsdV7A@mail.gmail.com>
References: <CAAeHK+xaFar2pj1xkbkhfjN+3ucLsfMpoHWFAKcHq3-F_Zm+mw@mail.gmail.com>
 <CANn89iKSSmaSHJGfgR4AkRgMRfYx+52XXjWsxZovUzorpneL=g@mail.gmail.com>
 <CACT4Y+Yw8_ZkjajkGdZ=71Mo83O+K=NJTZO+cM-+8UzTzHC-=A@mail.gmail.com>
 <1486038029.13103.17.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACT4Y+Z8uSWJaW+QXSOr7dCo5fSNrMu6fHxPcDBxL08qQUvRMw@mail.gmail.com>
 <1486042812.13103.27.camel@edumazet-glaptop3.roam.corp.google.com> <CACT4Y+ap2GE8QJXVsimqhHXKaPF-8StKU-S-Nq9-krSU7ADG3A@mail.gmail.com>
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
In-Reply-To: <CACT4Y+ap2GE8QJXVsimqhHXKaPF-8StKU-S-Nq9-krSU7ADG3A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 2, 2017 at 2:56 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Thu, Feb 2, 2017 at 2:40 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Thu, 2017-02-02 at 13:59 +0100, Dmitry Vyukov wrote:
>>
>>>
>>> Right, I can confirm that this is not happening on net-next tip
>>> (62e13097c46c69dbd7544ab2cd585ccf48f360a4).
>>> I reproduced it on a random month old commit on net-next, though
>>> (23a8ed4a624324dc696c328f09bd502c4a3816f0). Let's consider that this
>>> is accidentally fixed by something in that range.
>>
>> This also might depend on the .config
>>
>> I tried 23a8ed4a624324dc696c328f09bd502c4a3816f0 and could not trigger
>> the warning .
>
>
> I've attached my config.
> But I've tried with the same config on both revisions.
>
> Well, there is also a chance that the bug is not fixed, but requires
> slightly different reproducer after some changes.

Hummm....

My config includes KASAN+KCOV and I use gcc version 7.0.0 20161208
(experimental) (GCC).
I've now tried to turn off KASAN+KCOV and compiled with my stock
4.8.4, and this did _not_ trigger the warning on
23a8ed4a624324dc696c328f09bd502c4a3816f0.
