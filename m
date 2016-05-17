From: Thadeu Lima de Souza Cascardo <cascardo@minaslivre.org>
Subject: Re: [PATCH 1/1] net: ehea: avoid null pointer dereference
Date: Tue, 17 May 2016 18:33:34 -0300
Message-ID: <20160517213333.GN25580@siri.cascardo.eti.br>
References: <1463516934-10115-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Heinrich Schuchardt <xypron.glpk@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1463516934-10115-1-git-send-email-xypron.glpk@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 17, 2016 at 10:28:54PM +0200, Heinrich Schuchardt wrote:
> ehea_get_port may return NULL. Do not dereference NULL value.
> 
> Fixes: 8c4877a4128e ("ehea: Use the standard logging functions")
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>

Acked-by: Thadeu Lima de Souza Cascardo <cascardo@debian.org>

> ---
>  drivers/net/ethernet/ibm/ehea/ehea_main.c | 9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
> index 2a0dc12..54efa9a 100644
> --- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
> +++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
> @@ -1169,16 +1169,15 @@ static void ehea_parse_eqe(struct ehea_adapter *adapter, u64 eqe)
>  	ec = EHEA_BMASK_GET(NEQE_EVENT_CODE, eqe);
>  	portnum = EHEA_BMASK_GET(NEQE_PORTNUM, eqe);
>  	port = ehea_get_port(adapter, portnum);
> +	if (!port) {
> +		netdev_err(NULL, "unknown portnum %x\n", portnum);
> +		return;
> +	}
>  	dev = port->netdev;
>  
>  	switch (ec) {
>  	case EHEA_EC_PORTSTATE_CHG:	/* port state change */
>  
> -		if (!port) {
> -			netdev_err(dev, "unknown portnum %x\n", portnum);
> -			break;
> -		}
> -
>  		if (EHEA_BMASK_GET(NEQE_PORT_UP, eqe)) {
>  			if (!netif_carrier_ok(dev)) {
>  				ret = ehea_sense_port_attr(port);
> -- 
> 2.1.4
> 
