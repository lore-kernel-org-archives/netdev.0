From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/6] ibmveth: Add ethtool TSO handlers
Date: Tue, 07 Aug 2007 17:50:00 -0400
Message-ID: <46B8E908.8010701@garzik.org>
References: <11864293333377-patch-mail.ibm.com>
	<200708061942.l76JgSnp016148@d03av04.boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, rcjenn@linux.vnet.ibm.com,
	santil@linux.vnet.ibm.com, netdev@vger.kernel.org
To: Brian King <brking@linux.vnet.ibm.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <200708061942.l76JgSnp016148@d03av04.boulder.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Brian King wrote:
> Add handlers for get_tso and get_ufo to prevent errors being printed
> by ethtool.
> 
> Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
> ---
> 
>  drivers/net/ibmveth.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff -puN drivers/net/ibmveth.c~ibmveth_ethtool_get_tso drivers/net/ibmveth.c
> --- linux-2.6/drivers/net/ibmveth.c~ibmveth_ethtool_get_tso	2007-07-19 11:18:38.000000000 -0500
> +++ linux-2.6-bjking1/drivers/net/ibmveth.c	2007-07-19 11:18:38.000000000 -0500
> @@ -759,7 +759,9 @@ static const struct ethtool_ops netdev_e
>  	.get_tx_csum		= ethtool_op_get_tx_csum,
>  	.set_tx_csum		= ibmveth_set_tx_csum,
>  	.get_rx_csum		= ibmveth_get_rx_csum,
> -	.set_rx_csum		= ibmveth_set_rx_csum
> +	.set_rx_csum		= ibmveth_set_rx_csum,
> +	.get_tso			= ethtool_op_get_tso,
> +	.get_ufo			= ethtool_op_get_ufo

ACK, once you add a comma to the end of the final initializer

As you see from this patch, the practice of -not- having commas at the 
end of a list of struct initializers is not patch-friendly, since you 
must touch an unrelated line each time you patch the end of the struct. 
  For named initializers particularly, the lack of a comma is even more 
useless.

So, it might tweak some C perfectionists, but adding that 
seemingly-useless comma at the end of the last entry reduces maintenance 
headache and makes patch reviews slightly more clear.

	Jeff
