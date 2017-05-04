From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/ipv6: GPF in rt6_device_match
Date: Wed, 3 May 2017 20:55:31 -0700
Message-ID: <CAM_iQpU8rBnJEk7NRdJ9bBan93BpjFPeVV7Yz9QSb0O-O+=BtQ@mail.gmail.com>
References: <CAAeHK+yfX9ZtpFMTFXKAtjYE17MDBXMQJS_mH0b3=xTuv3jk9g@mail.gmail.com>
 <CAM_iQpUtVZiKTxnUBYEPLQzJSK+G_=Be-uzwuqph6g2VPsZijw@mail.gmail.com>
 <4ef76406-8e05-ccdf-fefb-dc47d56c71c9@gmail.com> <CAM_iQpVwBp=11c_SQgNxdONefHfZQiyzRwb2pOGgJVECytOzgg@mail.gmail.com>
 <dece4ab2-86b0-1649-5e34-1a9fa1240792@gmail.com> <CAM_iQpVbcOL3BD6SkVAOFLVCX5q_OpO0vfYnwG6XE4vdJkiw5Q@mail.gmail.com>
 <79157b41-2a13-6fda-ef31-c96f16850254@gmail.com>
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
In-Reply-To: <79157b41-2a13-6fda-ef31-c96f16850254@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 3, 2017 at 7:43 PM, David Ahern <dsahern@gmail.com> wrote:
> On 5/3/17 5:35 PM, Cong Wang wrote:
>> Ah, we need:
>>
>> @@ -4024,7 +4027,7 @@ static struct pernet_operations ip6_route_net_late_ops = {
>>
>>  static struct notifier_block ip6_route_dev_notifier = {
>>         .notifier_call = ip6_route_dev_notify,
>> -       .priority = 0,
>> +       .priority = -10, /* Must be called after addrconf_notify!! */
>>  };
>>
>
>
> It's not a notifier problem; the null_entry is created in ip6_route_init
> which is an init function.

Only init_net's null entry is created here.

>
> For network namespaces other than init_net, it is never initialized. See
> ip6_route_net_init.

I don't understand what you are talking about...

It is obviously initialized in 3 places:

1) The template itself, as we use memdup()
2) Code around dst_init_metrics() in ip6_route_net_init()
3) ip6_route_dev_notify(), which is supposed to initialize it after
loopback registers (the order needs to fix, as shown in my patch)

Why not add a printk and play with my patch to see the difference?
