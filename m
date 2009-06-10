From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: Re: [ofa-general][PATCH] mlx4: FIX error flow when initializing EQ
	table
Date: Wed, 10 Jun 2009 09:52:26 +0300
Message-ID: <4A2F582A.7050106@mellanox.co.il>
References: <4A2BD9B9.6000802@mellanox.co.il> <adavdn53zkw.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>,
	general@lists.openfabrics.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adavdn53zkw.fsf@cisco.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
>  > If mlx4_create_eq() would fail for one of EQ's assigned for
>  > completion handling, the code would try to free the same EQ
>  > we failed to create.
>  > The crash was found by Christoph Lameter
> 
> Thanks, good catch.  However looking at the code it seems that a simpler
> way to fix this would be as below.  Can you confirm that this works too?
> ---
>  drivers/net/mlx4/eq.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/mlx4/eq.c b/drivers/net/mlx4/eq.c
> index 8830dcb..033817e 100644
> --- a/drivers/net/mlx4/eq.c
> +++ b/drivers/net/mlx4/eq.c
> @@ -677,12 +677,12 @@ err_out_async:
>  	mlx4_free_eq(dev, &priv->eq_table.eq[dev->caps.num_comp_vectors]);
>  
>  err_out_comp:
> -	i = dev->caps.num_comp_vectors - 1;
> +	i = dev->caps.num_comp_vectors;
>  
>  err_out_unmap:
> -	while (i >= 0) {
> -		mlx4_free_eq(dev, &priv->eq_table.eq[i]);
> +	while (i > 0) {
>  		--i;
> +		mlx4_free_eq(dev, &priv->eq_table.eq[i]);
>  	}
>  	mlx4_unmap_clr_int(dev);
>  	mlx4_free_irqs(dev);
> 
Yes, it also works
Yevgeny
