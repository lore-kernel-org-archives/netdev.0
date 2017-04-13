From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/ipv4: use-after-free in ip_queue_xmit
Date: Thu, 13 Apr 2017 12:59:29 -0700
Message-ID: <CAM_iQpU_frn6bB6HHrRrF6omKDoXjxZmSoJZSu=PjZ35pUVOuA@mail.gmail.com>
References: <CAAeHK+z5=b4PdSrq8ff-btYbd-aKFR+uzQnoC5Pq4du4uVQjzQ@mail.gmail.com>
 <CAM_iQpWsEpJYHG1WvC9kQPt8iezBuLC8PeSqM20=W9cpkRE6=Q@mail.gmail.com>
 <CAAeHK+xZG+V8W85=bzpj0EgbmZo0c2Sq6e0LxtHMZM8wje-yPA@mail.gmail.com> <CAAeHK+wV1aKoP_2cog-dp0-17g4QimfK5j8P3oxypE3mCxMGUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+wV1aKoP_2cog-dp0-17g4QimfK5j8P3oxypE3mCxMGUw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 13, 2017 at 11:49 AM, Andrey Konovalov
<andreyknvl@google.com> wrote:
> On Mon, Apr 10, 2017 at 7:46 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
>> On Mon, Apr 10, 2017 at 7:42 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>> On Mon, Apr 10, 2017 at 7:40 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
>>>> Hi,
>>>>
>>>> I've got the following error report while fuzzing the kernel with syzkaller.
>>>>
>>>> On commit 39da7c509acff13fc8cb12ec1bb20337c988ed36 (4.11-rc6).
>>>>
>>>> Unfortunately it's not reproducible.
>>>>
>>>> BUG: KASAN: use-after-free in ip_select_ttl include/net/dst.h:176
>>>> [inline] at addr ffff88006ab3602c
>>>> BUG: KASAN: use-after-free in ip_queue_xmit+0x1817/0x1a30
>>>> net/ipv4/ip_output.c:485 at addr ffff88006ab3602c
>>>> Read of size 4 by task syz-executor1/12627
>>>> CPU: 3 PID: 12627 Comm: syz-executor1 Not tainted 4.11.0-rc6+ #206
>>>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>>>> Call Trace:
>>>>  __dump_stack lib/dump_stack.c:16 [inline]
>>>>  dump_stack+0x292/0x398 lib/dump_stack.c:52
>>>>  kasan_object_err+0x1c/0x70 mm/kasan/report.c:164
>>>>  print_address_description mm/kasan/report.c:202 [inline]
>>>>  kasan_report_error mm/kasan/report.c:291 [inline]
>>>>  kasan_report+0x252/0x510 mm/kasan/report.c:347
>>>>  __asan_report_load4_noabort+0x14/0x20 mm/kasan/report.c:367
>>>>  ip_select_ttl include/net/dst.h:176 [inline]
>>>
>>> Probably same as the one you reported on ipv4_mtu(), it would
>>> be nice if you could test the patch I proposed:
>>>
>>> https://patchwork.ozlabs.org/patch/747556/
>>
>> Applied your patch.
>
> Oops, apparently your patch doesn't compile:
>

Weird, it compiles fine here. Either you have a different config
or the following piece is missing for some reason?

@@ -69,6 +69,7 @@  struct rtable {

  struct list_head rt_uncached;
  struct uncached_list *rt_uncached_list;
+ struct fib_info *fi; /* for refcnt to shared metrics */
 };
