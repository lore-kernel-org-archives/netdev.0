From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] Revert "rtnetlink: check DO_SETLINK_NOTIFY correctly
 in do_setlink"
Date: Thu, 26 Oct 2017 17:10:09 +0800
Message-ID: <CADvbK_cbQ5LWYYV189xfo6R=SXpf76u=4CsVCssZeifhNYkCzA@mail.gmail.com>
References: <47e8fd3f-fa47-0e3b-1041-b931c64aa45b@6wind.com> <20171026082153.8042-1-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: davem <davem@davemloft.net>, network dev <netdev@vger.kernel.org>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Vlad Yasevich <vyasevic@redhat.com>,
        David Ahern <dsahern@gmail.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:47834 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932290AbdJZJKK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 05:10:10 -0400
Received: by mail-qk0-f193.google.com with SMTP id m189so3372401qke.4
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 02:10:10 -0700 (PDT)
In-Reply-To: <20171026082153.8042-1-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 26, 2017 at 4:21 PM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> This reverts commit 64ff90cc2e6f42596d7a0c37e41dc95292bb63b1.
>
> The initial test was right. The goal is to advertised any modifications of
> any setting of a link. The test ensures that the user won't lose an update.
>
> CC: David Ahern <dsahern@gmail.com>
> CC: Xin Long <lucien.xin@gmail.com>
> Reported-by: Vlad Yasevich <vyasevic@redhat.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  net/core/rtnetlink.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 5ace48926b19..52689c399b6c 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -2251,7 +2251,7 @@ static int do_setlink(const struct sk_buff *skb,
>
>  errout:
>         if (status & DO_SETLINK_MODIFIED) {
> -               if ((status & DO_SETLINK_NOTIFY) == DO_SETLINK_NOTIFY)
> +               if (status & DO_SETLINK_NOTIFY)
Just few questions about this ?

1. the check is meaningless here. As it would also return true.

2. why do you think it should be done only for the changes via netlink,
    what about the changes via net-sysfs, dev_ioctl ?

3. how about the duplicated notifications issue ?

>                         netdev_state_change(dev);
>
>                 if (err < 0)
> --
> 2.13.2
>
