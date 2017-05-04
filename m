From: David Ahern <dsahern@gmail.com>
Subject: Re: net/ipv6: GPF in rt6_device_match
Date: Wed, 3 May 2017 20:43:44 -0600
Message-ID: <79157b41-2a13-6fda-ef31-c96f16850254@gmail.com>
References: <CAAeHK+yfX9ZtpFMTFXKAtjYE17MDBXMQJS_mH0b3=xTuv3jk9g@mail.gmail.com>
 <CAM_iQpUtVZiKTxnUBYEPLQzJSK+G_=Be-uzwuqph6g2VPsZijw@mail.gmail.com>
 <4ef76406-8e05-ccdf-fefb-dc47d56c71c9@gmail.com>
 <CAM_iQpVwBp=11c_SQgNxdONefHfZQiyzRwb2pOGgJVECytOzgg@mail.gmail.com>
 <dece4ab2-86b0-1649-5e34-1a9fa1240792@gmail.com>
 <CAM_iQpVbcOL3BD6SkVAOFLVCX5q_OpO0vfYnwG6XE4vdJkiw5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
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
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpVbcOL3BD6SkVAOFLVCX5q_OpO0vfYnwG6XE4vdJkiw5Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/3/17 5:35 PM, Cong Wang wrote:
> Ah, we need:
> 
> @@ -4024,7 +4027,7 @@ static struct pernet_operations ip6_route_net_late_ops = {
> 
>  static struct notifier_block ip6_route_dev_notifier = {
>         .notifier_call = ip6_route_dev_notify,
> -       .priority = 0,
> +       .priority = -10, /* Must be called after addrconf_notify!! */
>  };
> 


It's not a notifier problem; the null_entry is created in ip6_route_init
which is an init function.

For network namespaces other than init_net, it is never initialized. See
ip6_route_net_init.
