From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] net: ethernet: rocker: Add select to CONFIG_BRIDGE in
 Kconfig
Date: Thu, 4 Dec 2014 19:15:48 +0100
Message-ID: <20141204181548.GH1861@nanopsycho.orion>
References: <CA+r1ZhhJQuwXbs+Et-ihsGP3QXDUWZ1nJ-5_hcjioFt5s8zMrA@mail.gmail.com>
 <54809BA5.7030901@rupran.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jim Davis <jim.epost@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>, sfeldma@gmail.com,
	netdev <netdev@vger.kernel.org>
To: Andreas Ruprecht <mail@rupran.de>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54809BA5.7030901@rupran.de>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thu, Dec 04, 2014 at 06:36:37PM CET, mail@rupran.de wrote:
>On 04.12.2014 17:34, Jim Davis wrote:
>> Building with the attached random configuration file,
>> 
>> drivers/built-in.o: In function `rocker_port_fdb_learn_work':
>> /home/jim/linux/drivers/net/ethernet/rocker/rocker.c:3014: undefined
>> reference to `br_fdb_external_learn_del'
>> /home/jim/linux/drivers/net/ethernet/rocker/rocker.c:3016: undefined
>> reference to `br_fdb_external_learn_add'
>> 
>
>Hi,
>
>the problem here is that CONFIG_BRIDGE is set to 'm' (leading to
>inclusion of the two functions above in the kernel module) while
>CONFIG_ROCKER is set to 'y', requiring the functions at link time.
>
>Is the attached patch sufficient to fix this?
>
>Regards,
>
>Andreas

>From 0529c3cbe381338dc3337e07a71e15b3d22a3255 Mon Sep 17 00:00:00 2001
>From: Andreas Ruprecht <rupran@einserver.de>
>Date: Thu, 4 Dec 2014 18:28:09 +0100
>Subject: [PATCH] net: ethernet: rocker: Add select to CONFIG_BRIDGE in Kconfig
>
>In a configuration with CONFIG_BRIDGE set to 'm' and CONFIG_ROCKER
>set to 'y', undefined references occur at link time:
>
>> drivers/built-in.o: In function `rocker_port_fdb_learn_work':
>> /home/jim/linux/drivers/net/ethernet/rocker/rocker.c:3014: undefined
>> reference to `br_fdb_external_learn_del'
>> /home/jim/linux/drivers/net/ethernet/rocker/rocker.c:3016: undefined
>> reference to `br_fdb_external_learn_add'
>
>This patch fixes these by selecting CONFIG_BRIDGE from CONFIG_ROCKER.
>
>Reported-by: Jim Davis <jim.epost@gmail.com>
>Signed-off-by: Andreas Ruprecht <rupran@einserver.de>
Acked-by: Jiri Pirko <jiri@resnulli.us>

this is ok for now. There is a plan to replace
br_fdb_external_learn_add/del a by notifier which will fix this as well.

Thanks.

>---
> drivers/net/ethernet/rocker/Kconfig | 1 +
> 1 file changed, 1 insertion(+)
>
>diff --git a/drivers/net/ethernet/rocker/Kconfig b/drivers/net/ethernet/rocker/Kconfig
>index 11a850eab628..ade10ec4c78d 100644
>--- a/drivers/net/ethernet/rocker/Kconfig
>+++ b/drivers/net/ethernet/rocker/Kconfig
>@@ -18,6 +18,7 @@ if NET_VENDOR_ROCKER
> config ROCKER
> 	tristate "Rocker switch driver (EXPERIMENTAL)"
> 	depends on PCI && NET_SWITCHDEV
>+	select BRIDGE
> 	---help---
> 	  This driver supports Rocker switch device.
> 
>-- 
>1.9.1
>
