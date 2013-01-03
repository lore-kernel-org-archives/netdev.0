From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 3/4] DSA: Convert printk calls to netdev_info calls
Date: Thu, 03 Jan 2013 11:06:12 -0800
Message-ID: <1357239972.5452.5.camel@joe-AO722>
References: <1357178098-4057-1-git-send-email-barry@grussling.com>
	 <1357178098-4057-4-git-send-email-barry@grussling.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Barry Grussling <barry@grussling.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:35860 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753707Ab3ACTGM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jan 2013 14:06:12 -0500
In-Reply-To: <1357178098-4057-4-git-send-email-barry@grussling.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-02 at 17:54 -0800, Barry Grussling wrote:
> Convert DSA printk calls to netdev_info calls as recommended by
> checkpatch.pl.

Some defects here.

> diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
[]
> @@ -237,7 +237,7 @@ static void mv88e6060_poll_link(struct dsa_switch *ds)
>  
>  		if (!link) {
>  			if (netif_carrier_ok(dev)) {
> -				printk(KERN_INFO "%s: link down\n", dev->name);
> +				netdev_info(dev, "%s: link down\n", dev->name);

Take out the "%s: ...", dev->name uses in these
conversions because netdev_printk adds them.

				netdev_info(dev, "link down\n");

> @@ -248,7 +248,7 @@ static void mv88e6060_poll_link(struct dsa_switch *ds)
>  		fc = ((port_status & 0xc000) == 0xc000) ? 1 : 0;
>  
>  		if (!netif_carrier_ok(dev)) {
> -			printk(KERN_INFO "%s: link up, %d Mb/s, %s duplex, "
> +			netdev_info(dev, "%s: link up, %d Mb/s, %s duplex, "
>  					 "flow control %sabled\n", dev->name,
>  					 speed, duplex ? "full" : "half",
>  					 fc ? "en" : "dis");

coalesce formats too

			netdev_info(dev, "link up, %d Mb/s, %s duplex, flow control %sabled\n"
				    speed, duplex ? "full" : "half",
				    fc ? "en" : "dis");
etc.
