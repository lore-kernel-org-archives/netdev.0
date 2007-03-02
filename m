From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [Bugme-new] [Bug 8107] New: dev->header_cache_update has a random value
Date: Fri, 02 Mar 2007 16:29:06 +0100
Message-ID: <m3zm6vk6kd.fsf@maximus.localdomain>
References: <200703011933.l21JX5hw018666@fire-2.osdl.org>
	<20070301143417.00b49e81.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, loveminix@yahoo.com.cn
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:35729 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992513AbXCBP3K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 10:29:10 -0500
In-Reply-To: <20070301143417.00b49e81.akpm@linux-foundation.org> (Andrew Morton's message of "Thu, 1 Mar 2007 14:34:17 -0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> writes:

>> However, in 
>> drivers/net/wan/hdlc_cisco.c, in function static int cisco_ioctl(struct 
>> net_device *dev, struct ifreq *ifr), where dev->hard_header is assigned a valid 
>> function, and dev->hard_header_cache is assigned a known value (NULL), dev-
>> >header_cache_update is not set to a known value:

Right, it seems I was never aware of dev->header_cache_update existence.
I wonder where does the non-NULL value come from? Nevermind.

> diff -puN drivers/net/wan/hdlc_cisco.c~cisco_ioctl-initialise-header_cache_update drivers/net/wan/hdlc_cisco.c
> --- a/drivers/net/wan/hdlc_cisco.c~cisco_ioctl-initialise-header_cache_update
> +++ a/drivers/net/wan/hdlc_cisco.c
> @@ -366,6 +366,7 @@ static int cisco_ioctl(struct net_device
>  		dev->hard_start_xmit = hdlc->xmit;
>  		dev->hard_header = cisco_hard_header;
>  		dev->hard_header_cache = NULL;
> +		dev->header_cache_update = NULL;
>  		dev->type = ARPHRD_CISCO;
>  		dev->flags = IFF_POINTOPOINT | IFF_NOARP;
>  		dev->addr_len = 0;
> _

ACK, I think it's the best place.

Is it OK to leave this (and hard_header_cache) set to random value
if dev->hard_header = NULL (as with other protocols)?
-- 
Krzysztof Halasa
