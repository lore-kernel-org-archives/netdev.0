From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] bonding: net_ratelimit() pr_warn()s in 802.3ad
 mode
Date: Sun, 16 Mar 2014 09:59:23 -0700
Message-ID: <1394989163.5689.42.camel@joe-AO722>
References: <1394987380-15765-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0098.hostedemail.com ([216.40.44.98]:51711 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754257AbaCPQ70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Mar 2014 12:59:26 -0400
In-Reply-To: <1394987380-15765-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-03-16 at 17:29 +0100, Veaceslav Falico wrote:
> Only ratelimit the ones that might spam, omiting the ones from
> enslave/deslave.

No, this patch isn't good and must not be applied.
You've also changed flow here.

> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
[]
> @@ -2080,7 +2081,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
>  
>  		/* select the active aggregator for the bond */
>  		if (port) {
> -			if (!port->slave) {
> +			if (!port->slave && net_ratelimit()) {
>  				pr_warn("%s: Warning: bond's first port is uninitialized\n",
>  					bond->dev->name);
>  				goto re_arm;

Now the goto is ratelimited too.

> @@ -2095,7 +2096,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
>  	/* for each port run the state machines */
>  	bond_for_each_slave_rcu(bond, slave, iter) {
>  		port = &(SLAVE_AD_INFO(slave).port);
> -		if (!port->slave) {
> +		if (!port->slave && net_ratelimit()) {
>  			pr_warn("%s: Warning: Found an uninitialized port\n",
>  				bond->dev->name);
>  			goto re_arm;

here too.

> @@ -2157,7 +2158,7 @@ static int bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave,
>  
>  		port = &(SLAVE_AD_INFO(slave).port);
>  
> -		if (!port->slave) {
> +		if (!port->slave && net_ratelimit()) {
>  			pr_warn("%s: Warning: port of slave %s is uninitialized\n",
>  				slave->dev->name, slave->bond->dev->name);
>  			return ret;

And the return 3.
