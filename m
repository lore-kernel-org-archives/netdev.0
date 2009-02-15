From: walter harms <wharms@bfs.de>
Subject: Re: [PATCH 02/43] drivers/net/e2100.c: fix sparse warning: symbol
 shadows	an earlier one
Date: Sun, 15 Feb 2009 15:04:15 +0100
Message-ID: <499820DF.5070508@bfs.de>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net> <20090214211203.23489.80420.stgit@vmbox.hanneseder.net>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hannes Eder <hannes@hanneseder.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.sz.bfs.de ([194.94.69.70]:60081 "EHLO mx.sz.bfs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751592AbZBOOWW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Feb 2009 09:22:22 -0500
In-Reply-To: <20090214211203.23489.80420.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hannes,
it is ok to replace a fixed boarder with ARRAY_SIZE()
in this special case i would success the following additional cleanup
(untestet !!)


static int set_free_irq(struct net_device *dev)
{
 int irqlist[] = {15,11,10,12,5,9,3,4}, i;

        for (i = 0; i < ARRAY_SIZE(irqlist); i++)
           if (request_irq (irqlist[i], NULL, 0, "bogus", NULL) != -EBUSY) {
                        dev->irq = irqlist[i];
                        return 0;
            }
        return -1;
}

....

if (dev->irq < 2) {
         if ( set_free_irq(dev) < 0) {
                printk(" unable to get IRQ %d.\n", dev->irq);
                retval = -EAGAIN;
                goto out;
        }

for me this looks more readable.

getting a free interrupt from a list mus be a common problem ? I am not in driver programming
perhaps such a code is already in place somewhere  ?

comments ?

re,
 wh


Hannes Eder schrieb:
> Impact: Remove redundant inner scope variable and while being at it
> make use of ARRAY_SIZE instead of a hardcoded number.
> 
> Fix this sparse warning:
>   drivers/net/e2100.c:219:56: warning: symbol 'i' shadows an earlier one
>   drivers/net/e2100.c:181:13: originally declared here
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>
> ---
>  drivers/net/e2100.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/e2100.c b/drivers/net/e2100.c
> index b07ba19..d2f6ee1 100644
> --- a/drivers/net/e2100.c
> +++ b/drivers/net/e2100.c
> @@ -216,13 +216,13 @@ static int __init e21_probe1(struct net_device *dev, int ioaddr)
>  		printk(" %02X", station_addr[i]);
>  
>  	if (dev->irq < 2) {
> -		int irqlist[] = {15,11,10,12,5,9,3,4}, i;
> -		for (i = 0; i < 8; i++)
> +		int irqlist[] = {15, 11, 10, 12, 5, 9, 3, 4};
> +		for (i = 0; i < ARRAY_SIZE(irqlist); i++)
>  			if (request_irq (irqlist[i], NULL, 0, "bogus", NULL) != -EBUSY) {
>  				dev->irq = irqlist[i];
>  				break;
>  			}
> -		if (i >= 8) {
> +		if (i >= ARRAY_SIZE(irqlist)) {
>  			printk(" unable to get IRQ %d.\n", dev->irq);
>  			retval = -EAGAIN;
>  			goto out;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> 
