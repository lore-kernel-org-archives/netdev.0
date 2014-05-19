From: walter harms <wharms@bfs.de>
Subject: Re: [PATCH 4/13] wimax/i2400m: make return of 0 explicit
Date: Mon, 19 May 2014 09:47:16 +0200
Message-ID: <5379B704.80303@bfs.de>
References: <1400473875-22228-1-git-send-email-Julia.Lawall@lip6.fr> <1400473875-22228-5-git-send-email-Julia.Lawall@lip6.fr>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>,
	kernel-janitors@vger.kernel.org, linux-wimax@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400473875-22228-5-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Am 19.05.2014 06:31, schrieb Julia Lawall:
> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Delete unnecessary local variable whose value is always 0 and that hides
> the fact that the result is always 0.
> 
> A simplified version of the semantic patch that fixes this problem is as
> follows: (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @r exists@
> local idexpression ret;
> expression e;
> position p;
> @@
> 
> -ret = 0;
> ... when != ret = e
> return 
> - ret
> + 0
>   ;
> // </smpl>
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> ---
> Alternatively, is an error code wanted under the if?
> 
>  drivers/net/wimax/i2400m/driver.c |    7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
> index 9c34d2f..901a534 100644
> --- a/drivers/net/wimax/i2400m/driver.c
> +++ b/drivers/net/wimax/i2400m/driver.c
> @@ -500,26 +500,23 @@ int i2400m_pm_notifier(struct notifier_block *notifier,
>   */
>  int i2400m_pre_reset(struct i2400m *i2400m)
>  {
> -	int result;
>  	struct device *dev = i2400m_dev(i2400m);
>  
>  	d_fnstart(3, dev, "(i2400m %p)\n", i2400m);
>  	d_printf(1, dev, "pre-reset shut down\n");
>  
> -	result = 0;
>  	mutex_lock(&i2400m->init_mutex);
>  	if (i2400m->updown) {
>  		netif_tx_disable(i2400m->wimax_dev.net_dev);
>  		__i2400m_dev_stop(i2400m);
> -		result = 0;
>  		/* down't set updown to zero -- this way
>  		 * post_reset can restore properly */
>  	}
>  	mutex_unlock(&i2400m->init_mutex);
>  	if (i2400m->bus_release)
>  		i2400m->bus_release(i2400m);
> -	d_fnend(3, dev, "(i2400m %p) = %d\n", i2400m, result);
> -	return result;
> +	d_fnend(3, dev, "(i2400m %p) = %d\n", i2400m, 0);


	d_fnend(3, dev, "i2400m=%p\n", i2400m);

or something like that
re,
 wh

> +	return 0;
>  }
>  EXPORT_SYMBOL_GPL(i2400m_pre_reset);
>  
> 
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
