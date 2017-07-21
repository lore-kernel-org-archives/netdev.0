From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] net: check mac address length for dev_set_mac_address()
Date: Fri, 21 Jul 2017 11:50:24 -0700
Message-ID: <CAM_iQpUheSWdPoAk2AEUHXueZwJj69XG75AGgHQzOR9X7=chcw@mail.gmail.com>
References: <20170720182758.20204-1-xiyou.wangcong@gmail.com> <20170720182758.20204-2-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Ahern <dsahern@gmail.com>, Jiri Pirko <jiri@resnulli.us>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:38103 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750849AbdGUSuq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 14:50:46 -0400
Received: by mail-wm0-f67.google.com with SMTP id 143so7868185wmu.5
        for <netdev@vger.kernel.org>; Fri, 21 Jul 2017 11:50:45 -0700 (PDT)
In-Reply-To: <20170720182758.20204-2-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 20, 2017 at 11:27 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> diff --git a/net/core/dev_ioctl.c b/net/core/dev_ioctl.c
> index 82fd4c9c4a1b..3f41601d7b7c 100644
> --- a/net/core/dev_ioctl.c
> +++ b/net/core/dev_ioctl.c
> @@ -262,6 +262,8 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
>                 return dev_set_mtu(dev, ifr->ifr_mtu);
>
>         case SIOCSIFHWADDR:
> +               if (dev->addr_len > sizeof(struct sockaddr))
> +                       return -EINVAL;
>                 return dev_set_mac_address(dev, &ifr->ifr_hwaddr);
>

Thinking a bit more, I should keep this patch simpler for -net and -stable,
so only the above piece is necessary, the rest pieces can be put to
-net-next.

I will resend this, and the "team: use a larger struct for mac address".

Thanks.
