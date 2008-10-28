From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] infiniband: use %p6 for printing message ids
Date: Tue, 28 Oct 2008 16:02:43 -0700
Message-ID: <1225234963.5269.228.camel@localhost>
References: <1225229901.11483.58.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: Harvey Harrison <harvey.harrison@gmail.com>,
	Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:3236 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753083AbYJ1XDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 19:03:13 -0400
In-Reply-To: <1225229901.11483.58.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-10-28 at 14:38 -0700, Harvey Harrison wrote:
> diff --git a/drivers/infiniband/core/sysfs.c b/drivers/infiniband/core/sysfs.c
> index 4d10421..e985193 100644
> --- a/drivers/infiniband/core/sysfs.c
> +++ b/drivers/infiniband/core/sysfs.c
> @@ -262,15 +262,7 @@ static ssize_t show_port_gid(struct ib_port *p, struct port_attribute *attr,
>  	if (ret)
>  		return ret;
>  
> -	return sprintf(buf, "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x\n",
> -		       be16_to_cpu(((__be16 *) gid.raw)[0]),
> -		       be16_to_cpu(((__be16 *) gid.raw)[1]),
> -		       be16_to_cpu(((__be16 *) gid.raw)[2]),
> -		       be16_to_cpu(((__be16 *) gid.raw)[3]),
> -		       be16_to_cpu(((__be16 *) gid.raw)[4]),
> -		       be16_to_cpu(((__be16 *) gid.raw)[5]),
> -		       be16_to_cpu(((__be16 *) gid.raw)[6]),
> -		       be16_to_cpu(((__be16 *) gid.raw)[7]));
> +	return sprintf(buf, "%p6\n", gid.raw);


I'm not sure any of these should be converted like this.
Infiniband gids are not IPv6 addresses.

I think a new %p<foo> type (maybe: IB) type should be defined for these.

