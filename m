From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/8][ATM]: [zatm] eliminate kfree warning (from Tobias Hirning <sskyman@web.de>)
Date: Wed, 20 Jul 2005 00:31:34 +0200
Message-ID: <20050719223134.GA24535@electric-eye.fr.zoreil.com>
References: <200507192044.j6JKirFb027183@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Content-Disposition: inline
In-Reply-To: <200507192044.j6JKirFb027183@ginger.cmf.nrl.navy.mil>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil> :
[...]
> diff --git a/drivers/atm/zatm.c b/drivers/atm/zatm.c
> --- a/drivers/atm/zatm.c
> +++ b/drivers/atm/zatm.c
> @@ -1339,7 +1339,7 @@ static int __init zatm_start(struct atm_
>  	return 0;
>      out:
>  	for (i = 0; i < NR_MBX; i++)
> -		kfree(zatm_dev->mbx_start[i]);
> +		kfree(&zatm_dev->mbx_start[i]);
>  	kfree(zatm_dev->rx_map);
>  	kfree(zatm_dev->tx_map);
>  	free_irq(zatm_dev->irq, dev);

Wow...

static int __init zatm_start(struct atm_dev *dev)
{
[...]
        for (i = 0; i < NR_MBX; i++)
[blah blah]
                        here = (unsigned long) kmalloc(2*MBX_SIZE(i),
                            GFP_KERNEL);
[blah blah]
                        zatm_dev->mbx_start[i] = here;

There is some stuff in my patchbucket for this one, please wait a minute.

--
Ueimor
