From: "Kay Sievers" <kay.sievers@vrfy.org>
Subject: Re: [PATCH] netdev: generate kobject uevent on network events.
Date: Mon, 24 Nov 2008 20:55:02 +0100
Message-ID: <ac3eb2510811241155h4f51784cgf44d2e3d7ae807b8@mail.gmail.com>
References: <20081121234110.22b47154@extreme>
	 <ac3eb2510811220608y33662b0bkb66026c2a21b061e@mail.gmail.com>
	 <F6B63A37-A69F-4197-B7E5-C9FD9BFA76F6@holtmann.org>
	 <20081122223249.4be03e4e@extreme>
	 <ac3eb2510811230813s3cb5c248k1e15d9ece581c8ad@mail.gmail.com>
	 <20081124114522.1e8de3fe@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"Marcel Holtmann" <marcel@holtmann.org>,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20081124114522.1e8de3fe@extreme>
Content-Disposition: inline
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 24, 2008 at 20:45, Stephen Hemminger <shemminger@vyatta.com> wrote:
> It is easier for some applications to deal with text based interfaces
> like uevent, rather than using netlink to listen for events.
>
> Note, this does not deal with network namespaces but that is a generic
> problem that already exists with kobjects (see rename events).
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
> ---
>  net/core/Makefile |    1
>  net/core/uevent.c |   61 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 62 insertions(+)
>
> --- a/net/core/Makefile 2008-11-24 08:40:10.000000000 -0800
> +++ b/net/core/Makefile 2008-11-24 08:51:01.000000000 -0800
> @@ -17,3 +17,4 @@ obj-$(CONFIG_NET_PKTGEN) += pktgen.o
>  obj-$(CONFIG_NETPOLL) += netpoll.o
>  obj-$(CONFIG_NET_DMA) += user_dma.o
>  obj-$(CONFIG_FIB_RULES) += fib_rules.o
> +obj-$(CONFIG_HOTPLUG) += uevent.o
> --- /dev/null   1970-01-01 00:00:00.000000000 +0000
> +++ b/net/core/uevent.c 2008-11-24 09:06:50.000000000 -0800
> @@ -0,0 +1,60 @@
> +/*
> + * Linux network device event notification
> + *
> + * Author:
> + *     Stephen Hemminger <shemminger@vyatta.com>
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/netdevice.h>
> +#include <linux/kobject.h>
> +#include <linux/notifier.h>
> +
> +/*
> + * Generate uevent in response to nework device changes.
> + * NB: KOBJ_MOVE is already genereated by kobject_rename
> + */
> +static int netdev_event(struct notifier_block *this, unsigned long event, void *ptr)
> +{
> +       struct net_device *netdev = ptr;
> +
> +       switch (event) {
> +       case NETDEV_UNREGISTER:
> +               kobject_uevent(&netdev->dev.kobj, KOBJ_REMOVE);
> +               break;
> +       case NETDEV_REGISTER:
> +               kobject_uevent(&netdev->dev.kobj, KOBJ_ADD);
> +               break;

Did you do anything else to prevent the duplicated add/remove events?
The core does send these already. I replied with a "udevadm monitor"
output to your earlier mail. Don't you see the duplicates on your box?

Thanks,
Kay
