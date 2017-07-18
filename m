From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: Re: [PATCH] liquidio: lio_vf_main: remove unnecessary static in
 setup_io_queues()
Date: Tue, 18 Jul 2017 14:05:01 -0700
Message-ID: <20170718210501.GA1176@felix-thinkpad.cavium.com>
References: <20170718205015.GA1420@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170718205015.GA1420@embeddedgus>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 18, 2017 at 03:50:15PM -0500, Gustavo A. R. Silva wrote:
> Remove unnecessary static on local variables cpu_id_modulus and cpu_id.
> Such variables are initialized before being used, on every execution
> path throughout the function. The static has no benefit and, removing
> it reduces the object file size.
> 
> This issue was detected using Coccinelle and the following semantic patch:
> 
> @bad exists@
> position p;
> identifier x;
> type T;
> @@
> 
> static T x@p;
> ...
> x = <+...x...+>
> 
> @@
> identifier x;
> expression e;
> type T;
> position p != bad.p;
> @@
> 
> -static
>  T x@p;
>  ... when != x
>      when strict
> ?x = e;
> 
> In the following log you can see a significant difference in the object
> file size. Also, there is a significant difference in the bss segment.
> This log is the output of the size command, before and after the code
> change:
> 
> before:
>    text    data     bss     dec     hex filename
>   55656   10680     576   66912   10560 drivers/net/ethernet/cavium/liquidio/lio_vf_main.o
> 
> after:
>    text    data     bss     dec     hex filename
>   55796   10536     448   66780   104dc drivers/net/ethernet/cavium/liquidio/lio_vf_main.o
> 
> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
> ---
>  drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
> index 9b24710..935ff29 100644
> --- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
> +++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
> @@ -1663,10 +1663,10 @@ static int setup_io_queues(struct octeon_device *octeon_dev, int ifidx)
>  {
>  	struct octeon_droq_ops droq_ops;
>  	struct net_device *netdev;
> -	static int cpu_id_modulus;
> +	int cpu_id_modulus;
>  	struct octeon_droq *droq;
>  	struct napi_struct *napi;
> -	static int cpu_id;
> +	int cpu_id;
>  	int num_tx_descs;
>  	struct lio *lio;
>  	int retval = 0;
> -- 
> 2.5.0
> 

Thanks.

Acked-by: Felix Manlunas <felix.manlunas@cavium.com>
