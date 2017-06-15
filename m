From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] Convert multiple netdev_info messages to netdev_dbg
Date: Thu, 15 Jun 2017 14:54:36 -0700
Message-ID: <1497563676.14396.19.camel@perches.com>
References: <1497550452-3067-1-git-send-email-michael.j.dilmore@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Michael J Dilmore <michael.j.dilmore@gmail.com>,
        Jay Vosburgh <j.vosburgh@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1497550452-3067-1-git-send-email-michael.j.dilmore@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-06-15 at 19:14 +0100, Michael J Dilmore wrote:
> Multiple netdev_info messages clutter kernel output. Also add netdev_dbg for packets per slave.
[]
> diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
[]
> @@ -9,6 +9,8 @@
>   * (at your option) any later version.
>   */
>   
> +#define DEBUG 1

Is defining DEBUG really worthwhile.

As well, it's almost always just
#define DEBUG
without any level value unless the
level value is used in the code.

> +
>  #include <linux/errno.h>
>  #include <linux/if.h>
>  #include <linux/netdevice.h>
> @@ -719,13 +721,13 @@ static int bond_option_mode_set(struct bonding *bond,
>  				const struct bond_opt_value *newval)
>  {
>  	if (!bond_mode_uses_arp(newval->value) && bond->params.arp_interval) {
> -		netdev_info(bond->dev, "%s mode is incompatible with arp monitoring, start mii monitoring\n",
> +		netdev_dbg(bond->dev, "%s mode is incompatible with arp monitoring, start mii monitoring\n",
>  			    newval->string);

Please realign any multiple line arguments to the
open parenthesis at the same time.

>  		/* disable arp monitoring */
>  		bond->params.arp_interval = 0;
>  		/* set miimon to default value */
>  		bond->params.miimon = BOND_DEFAULT_MIIMON;
> -		netdev_info(bond->dev, "Setting MII monitoring interval to %d\n",
> +		netdev_dbg(bond->dev, "Setting MII monitoring interval to %d\n",
>  			    bond->params.miimon);

etc...
