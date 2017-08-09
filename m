From: =?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH RFC net-next] net: Allow name change of IFF_UP interfaces
Date: Wed, 9 Aug 2017 21:29:38 +0900
Message-ID: <CAPA1RqA0q3W-3PsqDpY8_xiBB18SCWTV1gT+BKOTqQfAA5D8Fg@mail.gmail.com>
References: <20170809104202.30959-1-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170809104202.30959-1-vkuznets@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2017-08-09 19:42 GMT+09:00 Vitaly Kuznetsov <vkuznets@redhat.com>:
> What happens is: __netvsc_vf_setup() does dev_open() for the VF device and
> the consecutive dev_change_name() fails with -EBUSY because of the
> (dev->flags & IFF_UP) check. The history of this code predates git so I
> wasn't able to figure out when and why the check was added, everything
> seems to work fine without it. dev_change_name() has only two call sites,
> both hold rtnl_lock.
>
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
> ---
>  RFC: I'm probably miossing something obvious and the check can't be just
>  dropped. Stephen suggested a different solution to the isuue:
>  https://www.spinics.net/lists/netdev/msg448243.html but it has its own
>  drawbacks.
> ---
>  net/core/dev.c | 2 --
>  1 file changed, 2 deletions(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 1d75499add72..c608e233a78a 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1186,8 +1186,6 @@ int dev_change_name(struct net_device *dev, const char *newname)
>         BUG_ON(!dev_net(dev));
>
>         net = dev_net(dev);
> -       if (dev->flags & IFF_UP)
> -               return -EBUSY;
>
>         write_seqcount_begin(&devnet_rename_seq);

I think people expect the name won't change while up
and I don't think it is a good idea to allow changing the
name while the interface is up.

--yoshfuji


>
> --
> 2.13.4
>
