From: walter harms <wharms@bfs.de>
Subject: Re: [PATCH] bond_3ad.c: switch MAC_ADDRESS_COMPARE macro for compare_ether_addr()
Date: Tue, 31 May 2011 09:17:12 +0200
Message-ID: <4DE495F8.3030903@bfs.de>
References: <20110531004418.GA22937@optiplex.tchesoft.com>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: aquini@linux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01.sz.bfs.de ([194.94.69.103]:41898 "EHLO mx01.sz.bfs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754064Ab1EaHoR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 May 2011 03:44:17 -0400
In-Reply-To: <20110531004418.GA22937@optiplex.tchesoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The intentions are good, the resultung code next to unreadable.
I do not know the rest of code so i can not suggest an alternative
way. You may like to experiment with local variables or even make
a special function.

re,
 wh



Am 31.05.2011 02:44, schrieb Rafael Aquini:
> Converts all uses of MAC_ADDRESS_COMPARE macro to compare_ether_addr() and delete the macro.
> 
> Signed-off-by: Rafael Aquini <aquini@linux.com>
> ---
>  drivers/net/bonding/bond_3ad.c |   26 ++++++++++++++------------
>  1 files changed, 14 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> index c7537abc..c2e0d66 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c
> @@ -90,9 +90,6 @@
>  #define     AD_LINK_SPEED_BITMASK_10000MBPS   0x10
>  //endalloun
>  
> -// compare MAC addresses
> -#define MAC_ADDRESS_COMPARE(A, B) memcmp(A, B, ETH_ALEN)
> -
>  static struct mac_addr null_mac_addr = { { 0, 0, 0, 0, 0, 0 } };
>  static u16 ad_ticks_per_sec;
>  static const int ad_delta_in_ticks = (AD_TIMER_INTERVAL * HZ) / 1000;
> @@ -469,7 +466,7 @@ static void __choose_matched(struct lacpdu *lacpdu, struct port *port)
>  	// check if all parameters are alike
>  	if (((ntohs(lacpdu->partner_port) == port->actor_port_number) &&
>  	     (ntohs(lacpdu->partner_port_priority) == port->actor_port_priority) &&
> -	     !MAC_ADDRESS_COMPARE(&(lacpdu->partner_system), &(port->actor_system)) &&
> +	     !compare_ether_addr((const u8 *)&(lacpdu->partner_system), (const u8 *)&(port->actor_system)) &&
>  	     (ntohs(lacpdu->partner_system_priority) == port->actor_system_priority) &&
>  	     (ntohs(lacpdu->partner_key) == port->actor_oper_port_key) &&
>  	     ((lacpdu->partner_state & AD_STATE_AGGREGATION) == (port->actor_oper_port_state & AD_STATE_AGGREGATION))) ||
> @@ -559,7 +556,8 @@ static void __update_selected(struct lacpdu *lacpdu, struct port *port)
>  		// check if any parameter is different
>  		if (ntohs(lacpdu->actor_port) != partner->port_number ||
>  		    ntohs(lacpdu->actor_port_priority) != partner->port_priority ||
> -		    MAC_ADDRESS_COMPARE(&lacpdu->actor_system, &partner->system) ||
> +		    compare_ether_addr((const u8 *)&lacpdu->actor_system,
> +					(const u8 *)&partner->system) ||
>  		    ntohs(lacpdu->actor_system_priority) != partner->system_priority ||
>  		    ntohs(lacpdu->actor_key) != partner->key ||
>  		    (lacpdu->actor_state & AD_STATE_AGGREGATION) != (partner->port_state & AD_STATE_AGGREGATION)) {
> @@ -590,7 +588,8 @@ static void __update_default_selected(struct port *port)
>  		// check if any parameter is different
>  		if (admin->port_number != oper->port_number ||
>  		    admin->port_priority != oper->port_priority ||
> -		    MAC_ADDRESS_COMPARE(&admin->system, &oper->system) ||
> +		    compare_ether_addr((const u8 *)&admin->system,
> +					(const u8 *)&oper->system) ||
>  		    admin->system_priority != oper->system_priority ||
>  		    admin->key != oper->key ||
>  		    (admin->port_state & AD_STATE_AGGREGATION)
> @@ -620,7 +619,8 @@ static void __update_ntt(struct lacpdu *lacpdu, struct port *port)
>  		// check if any parameter is different
>  		if ((ntohs(lacpdu->partner_port) != port->actor_port_number) ||
>  		    (ntohs(lacpdu->partner_port_priority) != port->actor_port_priority) ||
> -		    MAC_ADDRESS_COMPARE(&(lacpdu->partner_system), &(port->actor_system)) ||
> +		    compare_ether_addr((const u8 *)&(lacpdu->partner_system),
> +					(const u8 *)&(port->actor_system)) ||
>  		    (ntohs(lacpdu->partner_system_priority) != port->actor_system_priority) ||
>  		    (ntohs(lacpdu->partner_key) != port->actor_oper_port_key) ||
>  		    ((lacpdu->partner_state & AD_STATE_LACP_ACTIVITY) != (port->actor_oper_port_state & AD_STATE_LACP_ACTIVITY)) ||
> @@ -1123,7 +1123,7 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
>  			break;
>  		case AD_RX_CURRENT:
>  			// detect loopback situation
> -			if (!MAC_ADDRESS_COMPARE(&(lacpdu->actor_system), &(port->actor_system))) {
> +			if (!compare_ether_addr((const u8 *)&(lacpdu->actor_system), (const u8 *)&(port->actor_system))) {
>  				// INFO_RECEIVED_LOOPBACK_FRAMES
>  				pr_err("%s: An illegal loopback occurred on adapter (%s).\n"
>  				       "Check the configuration to verify that all adapters are connected to 802.3ad compliant switch ports\n",
> @@ -1331,11 +1331,11 @@ static void ad_port_selection_logic(struct port *port)
>  		}
>  		// check if current aggregator suits us
>  		if (((aggregator->actor_oper_aggregator_key == port->actor_oper_port_key) && // if all parameters match AND
> -		     !MAC_ADDRESS_COMPARE(&(aggregator->partner_system), &(port->partner_oper.system)) &&
> +		     !compare_ether_addr((const u8 *)&(aggregator->partner_system), (const u8 *)&(port->partner_oper.system)) &&
>  		     (aggregator->partner_system_priority == port->partner_oper.system_priority) &&
>  		     (aggregator->partner_oper_aggregator_key == port->partner_oper.key)
>  		    ) &&
> -		    ((MAC_ADDRESS_COMPARE(&(port->partner_oper.system), &(null_mac_addr)) && // partner answers
> +		    ((compare_ether_addr((const u8 *)&(port->partner_oper.system), (const u8 *)&(null_mac_addr)) && // partner answers
>  		      !aggregator->is_individual)  // but is not individual OR
>  		    )
>  		   ) {
> @@ -1751,7 +1751,9 @@ static void ad_enable_collecting_distributing(struct port *port)
>   */
>  static void ad_disable_collecting_distributing(struct port *port)
>  {
> -	if (port->aggregator && MAC_ADDRESS_COMPARE(&(port->aggregator->partner_system), &(null_mac_addr))) {
> +	if (port->aggregator &&
> +	    compare_ether_addr((const u8 *)&(port->aggregator->partner_system),
> +				(const u8 *)&(null_mac_addr))) {
>  		pr_debug("Disabling port %d(LAG %d)\n",
>  			 port->actor_port_number,
>  			 port->aggregator->aggregator_identifier);
> @@ -1875,7 +1877,7 @@ static u16 aggregator_identifier;
>  void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution, int lacp_fast)
>  {
>  	// check that the bond is not initialized yet
> -	if (MAC_ADDRESS_COMPARE(&(BOND_AD_INFO(bond).system.sys_mac_addr),
> +	if (compare_ether_addr((const u8 *)&(BOND_AD_INFO(bond).system.sys_mac_addr),
>  				bond->dev->dev_addr)) {
>  
>  		aggregator_identifier = 0;
