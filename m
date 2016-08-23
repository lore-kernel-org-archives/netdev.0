From: Vegard Nossum <vegard.nossum@gmail.com>
Subject: Re: net: Zeroing the structure ethtool_wolinfo in ethtool_get_wol()
Date: Tue, 23 Aug 2016 19:15:10 +0200
Message-ID: <CAOMGZ=HSQqObOd6Q6hKVgXFy+EVfeNj8FH2JFs+az4i5hxUJiQ@mail.gmail.com>
References: <1471959668-18209-1-git-send-email-luis.henriques@canonical.com>
 <1471959668-18209-2-git-send-email-luis.henriques@canonical.com>
 <1471962096.14381.15.camel@edumazet-glaptop3.roam.corp.google.com> <1471964716.3746.103.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Luis Henriques <luis.henriques@canonical.com>,
        Avijit Kanti Das <avijitnsec@codeaurora.org>,
        "David S . Miller" <davem@davemloft.net>,
        Ben Hutchings <ben@decadent.org.uk>,
        Linux Netdev List <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471964716.3746.103.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23 August 2016 at 17:05, Joe Perches <joe@perches.com> wrote:
> On Tue, 2016-08-23 at 07:21 -0700, Eric Dumazet wrote:
>> On Tue, 2016-08-23 at 14:41 +0100, Luis Henriques wrote:
>> > From: Avijit Kanti Das <avijitnsec@codeaurora.org>
>> >
>> > memset() the structure ethtool_wolinfo that has padded bytes
>> > but the padded bytes have not been zeroed out.
> []
>> > diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> []
>> > @@ -1435,11 +1435,13 @@ static int ethtool_reset(struct net_device *dev, char __user *useraddr)
>> >
>> >  static int ethtool_get_wol(struct net_device *dev, char __user *useraddr)
>> >  {
>> > -   struct ethtool_wolinfo wol = { .cmd = ETHTOOL_GWOL };
>> > +   struct ethtool_wolinfo wol;
>> >
>> >     if (!dev->ethtool_ops->get_wol)
>> >             return -EOPNOTSUPP;
>> >
>> > +   memset(&wol, 0, sizeof(struct ethtool_wolinfo));
>> > +   wol.cmd = ETHTOOL_GWOL;
>> >     dev->ethtool_ops->get_wol(dev, &wol);
>> >
>> >     if (copy_to_user(useraddr, &wol, sizeof(wol)))
>> This would suggest a compiler bug to me.
>
> A compiler does not have a standards based requirement to
> initialize arbitrary padding bytes.
>
> I believe gcc always does zero all padding anyway.
>
>> I checked that my compiler does properly put zeros there, even in the
>> padding area.
>>
>> If we can not rely on such constructs, we have hundreds of similar
>> patches to submit.
>
> True.
>
> From a practical point of view, does any compiler used for
> kernel compilation (gcc/icc/llvm/any others?) not always
> perform zero padding of alignment bytes?
>

gcc often does not do it, depends on a few factors though:

https://lkml.org/lkml/2016/5/20/389


Vegard
