From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] bonding: send arp requests even if there's no
 route to them
Date: Fri, 28 Feb 2014 03:12:51 -0800
Message-ID: <1393585971.10280.5.camel@joe-AO722>
References: <1393585076-22786-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	=?ISO-8859-1?Q?Fran=E7ois?= CACHEREUL <f.cachereul@alphalink.fr>,
	Zhenjie Chen <zhchen@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0098.hostedemail.com ([216.40.44.98]:38141 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751971AbaB1LMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 06:12:55 -0500
In-Reply-To: <1393585076-22786-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-02-28 at 11:57 +0100, Veaceslav Falico wrote:
> Currently we're only sending arp requests if we have a route to the target
> (and, thus, can find out the source ip address).
> 
> There are some use cases, however, where we don't want/need to set an ip
> address (or set up a specific route) for bonding to use arp monitoring *for
> traffic generation*. We can easily send arp probes (arp requests with src
> ip == 0) to generate arp broadcast responses from the target ip and use
> them for determining if the target is up.
> 
> This, obviously, won't work with arp validation - because we don't have the
> ip address set and, thus, will filter out the responses. So in that case -
> print a warning.
[]
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
[]
> @@ -2155,8 +2155,13 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
[]
> +			if (bond->params.arp_validate)
> +				pr_warn("%s: no route to arp_ip_target %pI4 and arp_validate is set\n",
> +					bond->dev->name, &targets[i]);

Maybe

			if (bond->params.arp_validate && net_ratelimit())
