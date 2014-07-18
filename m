From: Tom Gundersen <teg@jklm.no>
Subject: Re: [PATCH v3 net-next 1/2] net: use dev->name in netdev_pr* when
 it's available
Date: Fri, 18 Jul 2014 11:01:06 +0200
Message-ID: <CAG-2HqXKXNTtyFvzST40++7QZHY-rBWAu4cx7OJZtRabUh+wqQ@mail.gmail.com>
References: <1405619171-18172-1-git-send-email-vfalico@gmail.com> <1405619171-18172-2-git-send-email-vfalico@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Veaceslav Falico <vfalico@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f48.google.com ([209.85.213.48]:41042 "EHLO
	mail-yh0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755180AbaGRJB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2014 05:01:27 -0400
Received: by mail-yh0-f48.google.com with SMTP id i57so2047667yha.7
        for <netdev@vger.kernel.org>; Fri, 18 Jul 2014 02:01:27 -0700 (PDT)
In-Reply-To: <1405619171-18172-2-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 17, 2014 at 7:46 PM, Veaceslav Falico <vfalico@gmail.com> wrote:
> netdev_name() returns dev->name only when the net_device is in
> NETREG_REGISTERED state.
>
> However, dev->name is always populated on creation, so we can easily use
> it.
>
> There are two cases when there's no real name - when it's an empty string
> or when the name is in form of "eth%d", then netdev_name() returns "unnamed
> net_device".
>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Tom Gundersen <teg@jklm.no>

Acked-by: Tom Gundersen <teg@jklm.no>

> Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
> ---
>
> Notes:
>     v1->v2:
>     Also account for an empty string, as Tom Gundersen suggested.
>
>  include/linux/netdevice.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 15ed750..70256aa 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -3383,8 +3383,8 @@ extern struct pernet_operations __net_initdata loopback_net_ops;
>
>  static inline const char *netdev_name(const struct net_device *dev)
>  {
> -       if (dev->reg_state != NETREG_REGISTERED)
> -               return "(unregistered net_device)";
> +       if (!dev->name[0] || strchr(dev->name, '%'))
> +               return "(unnamed net_device)";
>         return dev->name;
>  }
>
> --
> 1.8.4
>
