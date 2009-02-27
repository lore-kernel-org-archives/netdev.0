From: Ben Greear <greearb@candelatech.com>
Subject: Re: IPv4/IPv6 sysctl unregistration deadlock
Date: Fri, 27 Feb 2009 10:26:43 -0800
Message-ID: <49A83063.2060600@candelatech.com>
References: <49A4D5D5.5090602@trash.net>	<20090225061902.GA32430@gondor.apana.org.au>	<49A4E3F8.4050406@trash.net>	<49A4F0D7.20304@trash.net>	<20090225084321.GA1101@gondor.apana.org.au>	<m163ixk9t2.fsf@fess.ebiederm.org>	<20090226062257.GA11511@gondor.apana.org.au>	<m14oyhis31.fsf@fess.ebiederm.org> <20090226084924.16cb3e08@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34238 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754200AbZB0S1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 13:27:01 -0500
In-Reply-To: <20090226084924.16cb3e08@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:

> Subject: [PATCH] Avoid race between network down and sysfs
> 
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/net/core/net-sysfs.c	2009-02-26 08:36:18.000000000 -0800
> +++ b/net/core/net-sysfs.c	2009-02-26 08:37:51.000000000 -0800
> @@ -77,7 +77,9 @@ static ssize_t netdev_store(struct devic
>  	if (endp == buf)
>  		goto err;
>  
> -	rtnl_lock();
> +	if (!rtnl_trylock())
> +		return -ERESTARTSYS;
> +
>  	if (dev_isalive(net)) {
>  		if ((ret = (*set)(net, new)) == 0)
>  			ret = len;

I can test this to see if it fixes my problem.  Are the above lines the
entirety of the patch?

I think I'll add a printk if we do the ERESTARTSYS to make sure that I
hit the race (but still recover).

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

