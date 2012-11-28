From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: make arp_ip_target parameter checks
 consistent with sysfs
Date: Wed, 28 Nov 2012 11:23:16 -0500 (EST)
Message-ID: <20121128.112316.33060261620694469.davem@davemloft.net>
References: <1353759675-30511-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50104 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681Ab2K1QXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 11:23:18 -0500
In-Reply-To: <1353759675-30511-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Sat, 24 Nov 2012 13:21:15 +0100

> @@ -4706,12 +4706,14 @@ static int bond_check_params(struct bond_params *params)
>  	     arp_ip_count++) {
>  		/* not complete check, but should be good enough to
>  		   catch mistakes */
> -		if (!isdigit(arp_ip_target[arp_ip_count][0])) {
> +		__be32 ip = in_aton(arp_ip_target[arp_ip_count]);
> +		if (!isdigit(arp_ip_target[arp_ip_count][0])
> +		    || ip == 0
> +		    || ip == htonl(INADDR_BROADCAST)) {

Please format this properly, put the connecting operators at the end,
not the beginning, of the lines of the if statement, like so:

		if (!isdigit(arp_ip_target[arp_ip_count][0]) ||
		    ip == 0 ||
		    ip == htonl(INADDR_BROADCAST)) {

Where else did you see the layout you used?  It's not a prevalent
construct, so as far as I can tell you came up with it on your own.

Please don't do this, and instead use existing practice as your guide.

Thanks.
