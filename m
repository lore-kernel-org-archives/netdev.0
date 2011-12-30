From: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Subject: Re: [PATCH 1/1] via-rhine: Fix hanging with high CPU load on low-end broads.
Date: Fri, 30 Dec 2011 23:08:24 +0100
Message-ID: <CACPM=kUGEqNnVz+-Re0smWgVmZPJfTDWFbbAQp04JAK5E5=PNw@mail.gmail.com>
References: <20111229183902.GC21946@electric-eye.fr.zoreil.com>
	<20111229.170514.1766899380937848638.davem@davemloft.net>
	<CACPM=kV8NwYLAdODQHxYmJ21X0RmZ8KJT9szKdY2xa-DsesvQg@mail.gmail.com>
	<CACPM=kVfsXgFhKheevTS1pm7kCoezKO3M+102O=PRbXzxebxxg@mail.gmail.com>
	<20111229235312.GA27092@electric-eye.fr.zoreil.com>
	<CACPM=kXTqY1kVWrEMB-Z0Lqy6t+rXvMzixcSUy7fAz6g_ajV9g@mail.gmail.com>
	<20111230125655.GA32031@electric-eye.fr.zoreil.com>
	<CACPM=kVBxcL1_Z9zVvnEEdEgAc0rbAAbzkcocz4OYWQ2xn6VmQ@mail.gmail.com>
	<20111230180347.GA3647@electric-eye.fr.zoreil.com>
	<CACPM=kXWXUE+JcVhkz-6tGZ2YyteN9sGA80+Pnw6+LaJ-eNWBA@mail.gmail.com>
	<20111230215024.GA5513@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	bhutchings@solarflare.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, rl@hellgate.ch
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111230215024.GA5513@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/12/30 Francois Romieu <romieu@fr.zoreil.com>:
> Bjarke Istrup Pedersen <gurligebis@gentoo.org> :
> [...]
>> Just applied it to HEAD of net-next, and got the following compiler =
warning:
>> drivers/net/ethernet/via/via-rhine.c:2182:13: warning:
>> 'rhine_task_enable' defined but not used
>
> You are running with CONFIG_PM disabled and a down / up loop will not
> work. The patch below should hide the latter, at least as long as the
> relevant workqueue does not stall for too long... Extra cancel_work i=
n
> task_enable could work too but it will look strange.

Applied the patch, testing later :)
You are saying that with CONFIG_PM disabled, I wont be able to bring
the interface down and up again?

>> Just so you know that too :)
>
> Thanks for testing.
>
> diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ether=
net/via/via-rhine.c
> index c57e1da..89ced1b 100644
> --- a/drivers/net/ethernet/via/via-rhine.c
> +++ b/drivers/net/ethernet/via/via-rhine.c
> @@ -1536,6 +1536,7 @@ static int rhine_open(struct net_device *dev)
> =A0 =A0 =A0 =A0alloc_rbufs(dev);
> =A0 =A0 =A0 =A0alloc_tbufs(dev);
> =A0 =A0 =A0 =A0rhine_chip_reset(dev);
> + =A0 =A0 =A0 rhine_task_enable(rp);
> =A0 =A0 =A0 =A0init_registers(dev);
> =A0 =A0 =A0 =A0if (debug > 2)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netdev_dbg(dev, "%s() Done - status %0=
4x MII status: %04x\n",
> --
> Ueimor
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
