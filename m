From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] bond_main.c: fix device deregistration in init exception
 path
Date: Wed, 21 Sep 2005 22:38:26 -0400
Message-ID: <43321922.70707@pobox.com>
References: <432D0612.7070408@gmail.com> <20050917233224.2d4b3652.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, ctindel@users.sourceforge.net,
	fubar@us.ibm.com, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965214AbVIVCid@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, Florin Malita <fmalita@gmail.com>
In-Reply-To: <20050917233224.2d4b3652.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> diff -puN drivers/net/bonding/bond_main.c~bond_mainc-fix-device-deregistration-in-init-exception drivers/net/bonding/bond_main.c
> --- devel/drivers/net/bonding/bond_main.c~bond_mainc-fix-device-deregistration-in-init-exception	2005-09-17 23:18:38.000000000 -0700
> +++ devel-akpm/drivers/net/bonding/bond_main.c	2005-09-17 23:31:02.000000000 -0700
> @@ -5039,6 +5039,14 @@ static int __init bonding_init(void)
>  	return 0;
>  
>  out_err:
> +	/*
> +	 * rtnl_unlock() will run netdev_run_todo(), putting the
> +	 * thus-far-registered bonding devices into a state which
> +	 * unregigister_netdevice() will accept
> +	 */
> +	rtnl_unlock();
> +	rtnl_lock();
> +


Don't we want a schedule() or schedule_timeout(1) in between?

	Jeff
