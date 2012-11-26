From: Jan Synacek <jsynacek@redhat.com>
Subject: Re: [PATCH] arping: Fix find_device_by_ifaddrs()
Date: Mon, 26 Nov 2012 10:26:17 +0100
Message-ID: <50B335B9.1080209@redhat.com>
References: <1353574275-21742-1-git-send-email-jsynacek@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19584 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753316Ab2KZJ0V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Nov 2012 04:26:21 -0500
In-Reply-To: <1353574275-21742-1-git-send-email-jsynacek@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/22/2012 09:51 AM, Jan Synacek wrote:
> Look for another device if the device name and the currently found one are the
> same, not different.
> 
> Also, make checking for the device's flags nonfatal.
> 
> Signed-off-by: Jan Synacek <jsynacek@redhat.com>
> ---
>  arping.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/arping.c b/arping.c
> index ff77bec..d0edccf 100644
> --- a/arping.c
> +++ b/arping.c
> @@ -550,10 +550,10 @@ static int find_device_by_ifaddrs(void)
>  			continue;
>  		if (ifa->ifa_addr->sa_family != AF_PACKET)
>  			continue;
> -		if (device.name && ifa->ifa_name && strcmp(ifa->ifa_name, device.name))
> +		if (device.name && ifa->ifa_name && !strcmp(ifa->ifa_name, device.name))
>  			continue;
>  
> -		if (check_ifflags(ifa->ifa_flags, device.name != NULL) < 0)
> +		if (check_ifflags(ifa->ifa_flags, 0) < 0)
>  			continue;
>  
>  		if (!((struct sockaddr_ll *)ifa->ifa_addr)->sll_halen)
> 

Please, disregard this patch. I found a problem with it and will send a proper
patch soon.

Cheers,

-- 
Jan Synacek
Software Engineer, BaseOS team Brno, Red Hat
