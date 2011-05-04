From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net/bonding: bonding: Adjust coding style for bond_3ad
 files.
Date: Wed, 04 May 2011 15:46:24 -0700
Message-ID: <1304549184.1788.128.camel@Joe-Laptop>
References: <20110504221844.GA17955@x61.tchesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors.vger.kernel.org@x61.tchesoft.com,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Rafael Azenha Aquini <aquini@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1257 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755917Ab1EDWq1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 18:46:27 -0400
In-Reply-To: <20110504221844.GA17955@x61.tchesoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-05-04 at 19:18 -0300, Rafael Azenha Aquini wrote:
> I did some mods there, in an attempt to make that code stick as
> closely as possible with the Kernel coding style.
> Signed-off-by: Rafael Aquini <aquini@linux.com>
>  drivers/net/bonding/bond_3ad.c |  918 +++++++++++++++++++++++-----------------
>  drivers/net/bonding/bond_3ad.h |  189 +++++----
> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> index 31912f1..97e7528 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c
[]
> @@ -59,7 +59,10 @@
>  #define AD_STATE_DEFAULTED       0x40
>  #define AD_STATE_EXPIRED         0x80
>  
> -// Port Variables definitions used by the State Machines(43.4.7 in the 802.3ad standard)
> +/*
> + * Port Variables definitions used by the State
> + * Machines (43.4.7 in the 802.3ad standard)
> + */

If you're going to reflow comments, please try to keep
operational phrases on the same line.  Something like

/*
 * Port Variables definitions used by the State Machines
 * (43.4.7 in the 802.3ad standard)
 */

btw: David Miller, the drivers/net maintainer prefers
comments to start on the same opening line as the comment
initiator like this:

/* Port Variables definitions used by the State Machines
 * (43.4.7 in the 802.3ad standard)
 */

[]

> -// compare MAC addresses
>  #define MAC_ADDRESS_COMPARE(A, B) memcmp(A, B, ETH_ALEN)

You could convert all uses of this macro to compare_ether_addr
and delete this macro.

>  static struct mac_addr null_mac_addr = { { 0, 0, 0, 0, 0, 0 } };

const

> @@ -113,14 +115,12 @@ static void ad_initialize_agg(struct aggregator *aggregator);
>  static void ad_initialize_port(struct port *port, int lacp_fast);
>  static void ad_enable_collecting_distributing(struct port *port);
>  static void ad_disable_collecting_distributing(struct port *port);
> -static void ad_marker_info_received(struct bond_marker *marker_info, struct port *port);
> -static void ad_marker_response_received(struct bond_marker *marker, struct port *port);
> -
> -
> -/////////////////////////////////////////////////////////////////////////////////
> -// ================= api to bonding and kernel code ==================
> -/////////////////////////////////////////////////////////////////////////////////
> +static void ad_marker_info_received(struct bond_marker *marker_info,
> +							struct port *port);

Better to use either of these forms.

Args aligned to open parenthesis:

static void ad_marker_info_received(struct bond_marker *marker_info,
				    struct port *port);

Return type on separate line:

static void
ad_marker_info_received(struct bond_marker *marker_info, struct port *port);

In any case, please align all additional args to the open parenthesis.

> @@ -161,7 +161,6 @@ static inline struct port *__get_next_port(struct port *port)
>  	struct bonding *bond = __get_bond_by_port(port);
>  	struct slave *slave = port->slave;
>  
> -	// If there's no bond for this port, or this is the last slave

I think these comments are non-obvious enough to leave.

> @@ -365,22 +365,26 @@ static u8 __get_duplex(struct port *port)
>  
>  	u8 retval;
>  
> -	//  handling a special case: when the configuration starts with
> -	// link down, it sets the duplex to 0.
> +	/*
> +	 * handling a special case: when the configuration starts with
> +	 * link down, it sets the duplex to 0.
> +	 */

	/* handling a special case:
	 * When the configuration starts with link down, it sets the duplex to 0
	 */

>  	if (slave->link != BOND_LINK_UP)
>  		retval = 0x0;
>  	else {
>  		switch (slave->duplex) {
>  		case DUPLEX_FULL:
>  			retval = 0x1;
> -			pr_debug("Port %d Received status full duplex update from adapter\n",
> -				 port->actor_port_number);
> +			pr_debug("Port %d Received status "
> +					"full duplex update from adapter\n",
> +					port->actor_port_number);

Don't reflow format strings.
These aren't errors and are preferred for easier grep.

> @@ -394,12 +398,9 @@ static u8 __get_duplex(struct port *port)
>   */
>  static inline void __initialize_port_locks(struct port *port)
>  {
> -	// make sure it isn't called twice
>  	spin_lock_init(&(SLAVE_AD_INFO(port->slave).state_machine_lock));
>  }

Lost comment?

[]

> @@ -466,17 +463,17 @@ static u16 __ad_timer_to_ticks(u16 timer_type, u16 par)
>   */
>  static void __choose_matched(struct lacpdu *lacpdu, struct port *port)
>  {
> -	// check if all parameters are alike
>  	if (((ntohs(lacpdu->partner_port) == port->actor_port_number) &&
> -	     (ntohs(lacpdu->partner_port_priority) == port->actor_port_priority) &&
> -	     !MAC_ADDRESS_COMPARE(&(lacpdu->partner_system), &(port->actor_system)) &&
> -	     (ntohs(lacpdu->partner_system_priority) == port->actor_system_priority) &&
> -	     (ntohs(lacpdu->partner_key) == port->actor_oper_port_key) &&
> -	     ((lacpdu->partner_state & AD_STATE_AGGREGATION) == (port->actor_oper_port_state & AD_STATE_AGGREGATION))) ||
> -	    // or this is individual link(aggregation == FALSE)
> -	    ((lacpdu->actor_state & AD_STATE_AGGREGATION) == 0)
> -		) {
> -		// update the state machine Matched variable
> +	     (ntohs(lacpdu->partner_port_priority) == port->actor_port_priority)
> +	    && !MAC_ADDRESS_COMPARE(&(lacpdu->partner_system),
> +							&(port->actor_system))
> +	    && (ntohs(lacpdu->partner_system_priority) ==
> +						   port->actor_system_priority)
> +	    && (ntohs(lacpdu->partner_key) == port->actor_oper_port_key)
> +	    && ((lacpdu->partner_state & AD_STATE_AGGREGATION) ==
> +			(port->actor_oper_port_state & AD_STATE_AGGREGATION)))
> +	    || ((lacpdu->actor_state & AD_STATE_AGGREGATION) == 0)) {
> +		/* update the state machine Selected variable */

Not an improvement.

Logical continuations are put at the EOL.
If these are longer than 80 char, I'd ignore them.

> -		// set the partner sync. to on if the partner is sync. and the port is matched
> +		/* switch on partner sync. if partner is synchronized,
> +		 * and the port is matched
> +		 */

I think the original text better.

> @@ -675,7 +673,9 @@ static int __agg_ports_are_ready(struct aggregator *aggregator)
>  	int retval = 1;
>  
>  	if (aggregator) {
> -		// scan all ports in this aggregator to verfy if they are all ready
> +		/* scan all ports in this aggregator to verfy
> +		 * if they are all ready
> +		 */

verify.

For the rest, too long, didn't read...

