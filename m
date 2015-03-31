From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] bonding: deprecate BOND_MONITOR_CHURNED in
 favor of existing definitions
Date: Tue, 31 Mar 2015 09:45:20 -0400
Message-ID: <20150331134519.GO1051@gospo>
References: <1427751040-4445-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:36503 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754871AbbCaNpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 09:45:24 -0400
Received: by qgf60 with SMTP id 60so14373051qgf.3
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2015 06:45:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1427751040-4445-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 30, 2015 at 02:30:40PM -0700, Mahesh Bandewar wrote:
> AD_PORT_ACTOR_CHURN and AD_PORT_PARTNER_CHURN are already present and
> essentially BOND_MONITOR_CHURNED is a combination of these two definitions.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>

> ---
>  drivers/net/bonding/bond_3ad.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> index 5712cf6d0342..4309b5a76708 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c
> @@ -38,7 +38,6 @@
>  #define AD_STANDBY                 0x2
>  #define AD_MAX_TX_IN_SECOND        3
>  #define AD_COLLECTOR_MAX_DELAY     0
> -#define AD_MONITOR_CHURNED         0x1000
>  
>  /* Timer definitions (43.4.4 in the 802.3ad standard) */
>  #define AD_FAST_PERIODIC_TIME      1
> @@ -71,6 +70,7 @@
>  #define AD_PORT_STANDBY         0x80
>  #define AD_PORT_SELECTED        0x100
>  #define AD_PORT_MOVED           0x200
> +#define AD_PORT_CHURNED         (AD_PORT_ACTOR_CHURN | AD_PORT_PARTNER_CHURN)
>  
>  /* Port Key definitions
>   * key is determined according to the link speed, duplex and
> @@ -1016,7 +1016,7 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
>  	/* first, check if port was reinitialized */
>  	if (port->sm_vars & AD_PORT_BEGIN) {
>  		port->sm_rx_state = AD_RX_INITIALIZE;
> -		port->sm_vars |= AD_MONITOR_CHURNED;
> +		port->sm_vars |= AD_PORT_CHURNED;
>  	/* check if port is not enabled */
>  	} else if (!(port->sm_vars & AD_PORT_BEGIN)
>  		 && !port->is_enabled && !(port->sm_vars & AD_PORT_MOVED))
> @@ -1026,7 +1026,7 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
>  		 (port->sm_rx_state == AD_RX_DEFAULTED) ||
>  		 (port->sm_rx_state == AD_RX_CURRENT))) {
>  		if (port->sm_rx_state != AD_RX_CURRENT)
> -			port->sm_vars |= AD_MONITOR_CHURNED;
> +			port->sm_vars |= AD_PORT_CHURNED;
>  		port->sm_rx_timer_counter = 0;
>  		port->sm_rx_state = AD_RX_CURRENT;
>  	} else {
> @@ -1108,7 +1108,7 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
>  			port->partner_oper.port_state |= AD_STATE_LACP_ACTIVITY;
>  			port->sm_rx_timer_counter = __ad_timer_to_ticks(AD_CURRENT_WHILE_TIMER, (u16)(AD_SHORT_TIMEOUT));
>  			port->actor_oper_port_state |= AD_STATE_EXPIRED;
> -			port->sm_vars |= AD_MONITOR_CHURNED;
> +			port->sm_vars |= AD_PORT_CHURNED;
>  			break;
>  		case AD_RX_DEFAULTED:
>  			__update_default_selected(port);
> @@ -1144,8 +1144,8 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
>   */
>  static void ad_churn_machine(struct port *port)
>  {
> -	if (port->sm_vars & AD_MONITOR_CHURNED) {
> -		port->sm_vars &= ~AD_MONITOR_CHURNED;
> +	if (port->sm_vars & AD_PORT_CHURNED) {
> +		port->sm_vars &= ~AD_PORT_CHURNED;
>  		port->sm_churn_actor_state = AD_CHURN_MONITOR;
>  		port->sm_churn_partner_state = AD_CHURN_MONITOR;
>  		port->sm_churn_actor_timer_counter =
> -- 
> 2.2.0.rc0.207.ga3a616c
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
