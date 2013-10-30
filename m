From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] net: extend net_device allocation to vmalloc()
Date: Wed, 30 Oct 2013 19:16:37 +0000
Message-ID: <1383160597.1601.14.camel@bwh-desktop.uk.level5networks.com>
References: <20131029152628.GA3065@citrix.com>
	 <1383061430.5464.41.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029184647.GA3261@citrix.com>
	 <1383089055.4176.1.camel@edumazet-glaptop.roam.corp.google.com>
	 <1383089532.4857.1.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131030103958.GB3261@citrix.com>
	 <1383141242.4857.36.camel@edumazet-glaptop.roam.corp.google.com>
	 <1383145278.4857.46.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joby Poriyath <joby.poriyath@citrix.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<xen-devel@lists.xen.org>, <andrew.bennieston@citrix.com>,
	<david.vrabel@citrix.com>, <malcolm.crossley@citrix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:31348 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752530Ab3J3TQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 15:16:43 -0400
In-Reply-To: <1383145278.4857.46.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-30 at 08:01 -0700, Eric Dumazet wrote:
[...]
> --- a/Documentation/networking/netdevices.txt
> +++ b/Documentation/networking/netdevices.txt
> @@ -10,9 +10,10 @@ network devices.
>  struct net_device allocation rules
>  ==================================
>  Network device structures need to persist even after module is unloaded and
> -must be allocated with kmalloc.  If device has registered successfully,
> -it will be freed on last use by free_netdev.  This is required to handle the
> -pathologic case cleanly (example: rmmod mydriver </sys/class/net/myeth/mtu )
> +must be allocated with kmalloc() or vmalloc(). If device has registered
[...]

Well, drivers must never try to allocate and initialise struct
net_device from scratch.  They always call alloc_netdev_mqs() or one of
its many wrappers.  So 'must be allocated with kmalloc' was already
wrong and this sentence should be removed completely.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
