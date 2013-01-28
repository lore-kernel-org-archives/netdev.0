From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 4/7] net/mlx4_en: Set carrier to off when a
 port is stopped
Date: Mon, 28 Jan 2013 12:53:12 +0000
Message-ID: <1359377592.3367.15.camel@deadeye.wl.decadent.org.uk>
References: <1358350935-3281-1-git-send-email-amirv@mellanox.com>
	  <1358350935-3281-5-git-send-email-amirv@mellanox.com>
	 <1358352016.2923.15.camel@bwh-desktop.uk.solarflarecom.com>
	 <510669F7.2090705@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:61039 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754091Ab3A1MxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 07:53:16 -0500
In-Reply-To: <510669F7.2090705@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-28 at 14:07 +0200, Amir Vadai wrote:
> On 16/01/2013 18:00, Ben Hutchings wrote:
> > On Wed, 2013-01-16 at 17:42 +0200, Amir Vadai wrote:
> >> From: Eugenia Emantayev <eugenia@mellanox.com>
> >>
> >> Under heavy CPU load changing ring size/mtu/etc. could result in transmit
> >> timeout, since stop-start port might take more than 10 sec. Set
> >> netif_carrier_off to prevent tx queue transmit timeout.
> >
> > A spurious link change can restart L3 auto-configuration (DHCP, SLAAC,
> > etc.)  netif_device_detach() also inhibits the watchdog and doesn't have
> > that problem.
> >
> > Ben.
> >
> 
> But after calling netif_device_detach(), device present bit is cleared 
> and therefore won't be able to access the device. This means, that after 
> 'ifconfig down', won't be able to do 'ifconfig up'.

Indeed, so don't do it in ndo_stop!  Your commit message referred to
changing ring size and MTU.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
