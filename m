From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/1] bonding: eliminate RTNL assertion spew
Date: Tue, 09 Jan 2007 18:13:55 -0500
Message-ID: <45A421B3.4020301@garzik.org>
References: <20070109225900.GA11755@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38643 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932509AbXAIXN7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jan 2007 18:13:59 -0500
To: Andy Gospodarek <andy@greyhouse.net>
In-Reply-To: <20070109225900.GA11755@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek wrote:
> -void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave)
> +void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave, int rtnl_locked)
>  {
>  	struct slave *swap_slave;
>  	int i;

Although this is not a direct NAK (haven't read the full patch yet), 
conditional locking behavior like this is /very/ fragile, and in Linux 
is generally discouraged.  Vendor drivers in particular have a history 
of constantly getting this wrong, and it makes locking more difficult to 
review.

	Jeff


