From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/ipv6: GPF in rt6_ifdown
Date: Wed, 21 Jun 2017 14:01:03 -0700
Message-ID: <CAM_iQpWkUMVNb+MyQCMKFeXFo9TW5-TjzhKyugrVy=GBDNKBgg@mail.gmail.com>
References: <CAAeHK+z0TdpY83FiMtHBMChEQgE+0-+8roNFVzM5Uo-duCgpVA@mail.gmail.com>
 <CAAeHK+wuKeG6HhvuP89DNXYE+Okq7HDdJ+OgYGoK+FN-k=w+fA@mail.gmail.com>
 <CAAeHK+xGdXtfTxNE0g71-Ffkvj+6qy4At15WisvBbXMQ4EUqNQ@mail.gmail.com> <CAM_iQpWeWTqBzjj1iju_Vxr5vgr58wRUn-xuSrLqmsd98HpxcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpWeWTqBzjj1iju_Vxr5vgr58wRUn-xuSrLqmsd98HpxcQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 21, 2017 at 1:08 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Wed, Jun 21, 2017 at 10:53 AM, Andrey Konovalov
> <andreyknvl@google.com> wrote:
>> On Wed, Jun 21, 2017 at 3:09 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
>>> On Wed, Jun 21, 2017 at 2:08 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
>>>> Hi,
>>>>
>>>> I've got the following error report while fuzzing the kernel with syzkaller.
>>>>
>>>> On commit 9705596d08ac87c18aee32cc97f2783b7d14624e (4.12-rc6+).
>>>>
>>>> It might be related to:
>>>> https://groups.google.com/forum/#!topic/syzkaller/ZJaqAiFLe3k
>>>>
>>>> I only have a reproducer in the form of a syzkaller program, attached
>>>> together with my .config.
>>>
>>> I now have a C reproducer as well, attached.
>>
>> And here's a much simpler reproducer.
>
> Thanks a lot for your reproducer!
>
> I added a few printk's, and find that we somehow have rt->rt6i_idev set
> to NULL but still keep it in the uncached list. ip6_dst_destroy() unlinks
> it before NULL'ing, so it should not be that case.

Heck... The loopback_dev->ip6_ptr is set to NULL because of
its mtu is set to smaller than IPV6_MIN_MTU, this is why we
have rt->rt6i_idev NULL after a rt6_uncached_list_flush_dev()...

I am thinking about a right fix.
