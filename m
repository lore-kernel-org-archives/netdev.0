From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/ipv6: GPF in rt6_device_match
Date: Wed, 3 May 2017 15:02:46 -0700
Message-ID: <CAM_iQpVwBp=11c_SQgNxdONefHfZQiyzRwb2pOGgJVECytOzgg@mail.gmail.com>
References: <CAAeHK+yfX9ZtpFMTFXKAtjYE17MDBXMQJS_mH0b3=xTuv3jk9g@mail.gmail.com>
 <CAM_iQpUtVZiKTxnUBYEPLQzJSK+G_=Be-uzwuqph6g2VPsZijw@mail.gmail.com> <4ef76406-8e05-ccdf-fefb-dc47d56c71c9@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4ef76406-8e05-ccdf-fefb-dc47d56c71c9@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 3, 2017 at 11:22 AM, David Ahern <dsahern@gmail.com> wrote:
> On 5/3/17 11:02 AM, Cong Wang wrote:
>> A quick glance shows we need to simply check local->rt6i_idev
>> since we do the same check for sprt right above.
>
> As I recall, rt6i_idev is set for all routes except null_entry and it is
> not set on null_entry only because of initialization order.

Are you sure?

        if (event == NETDEV_REGISTER && (dev->flags & IFF_LOOPBACK)) {
                net->ipv6.ip6_null_entry->dst.dev = dev;
                net->ipv6.ip6_null_entry->rt6i_idev = in6_dev_get(dev);
#ifdef CONFIG_IPV6_MULTIPLE_TABLES
                net->ipv6.ip6_prohibit_entry->dst.dev = dev;
                net->ipv6.ip6_prohibit_entry->rt6i_idev = in6_dev_get(dev);
                net->ipv6.ip6_blk_hole_entry->dst.dev = dev;
                net->ipv6.ip6_blk_hole_entry->rt6i_idev = in6_dev_get(dev);
#endif
        }

Loopback is the first one to register, so null entry is set to
loopback dev initially. Similar for init_net.
