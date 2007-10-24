From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 2/2] NFS: handle IPv6 addresses in nfs ctl
Date: Wed, 24 Oct 2007 15:22:27 -0400
Message-ID: <471F9B73.4010908@hp.com>
References: <471C893F.6000306@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mailing list NFSv4 <nfsv4@linux-nfs.org>,
	netdev ML <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:36991 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753233AbXJXTXH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2007 15:23:07 -0400
In-Reply-To: <471C893F.6000306@ext.bull.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Aurelien,

Again, a few more comments.

I might just modify these in my own tree and send out a patch that 
combines both into one, it might be less work.

> @@ -229,9 +229,20 @@ static ssize_t write_getfs(struct file *
>  		return -EINVAL;
>  	data = (struct nfsctl_fsparm*)buf;
>  	err = -EPROTONOSUPPORT;
> -	if (data->gd_addr.sa_family != AF_INET)
> +	switch (data->gd_addr.sa_family) {
> +	case AF_INET6:
> +		sin6 = &sin6_storage;

This should be:

	in6 = &sin6_storage;

> +		sin6 = (struct sockaddr_in6 *)&data->gd_addr;
> +		ipv6_addr_copy(&in6, &(sin6->sin6_addr)); 

Extra () here.

> -    	if (!(clp = auth_unix_lookup(in6))) 
> +	switch (data->gd_addr.sa_family) {
> +	case AF_INET:
> +		/* IPv6 address mapping */
> +		ipv6_addr_set(&in6, 0, 0, htonl(0x0000FFFF), ((struct sockaddr_in *)&data->gd_addr)->sin_addr.s_addr);
> +		break;
> +	case AF_INET6:
> +		sin6 = &sin6_storage;

This should be:

	in6 = &sin6_storage;

> +		sin6 = (struct sockaddr_in6 *)&data->gd_addr;
> +		ipv6_addr_copy(&in6, &(sin6->sin6_addr));

Extra () here.

-Brian
