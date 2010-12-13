From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-2.6 2/3] bonding: Change active slave quietly when
 bond is down
Date: Mon, 13 Dec 2010 21:06:15 +0000
Message-ID: <1292274375.9860.19.camel@bwh-desktop>
References: <1292264216.9860.11.camel@bwh-desktop>
	 <1292264396.9860.14.camel@bwh-desktop>  <32030.1292272904@death>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:50064 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678Ab0LMVGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 16:06:18 -0500
In-Reply-To: <32030.1292272904@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-12-13 at 12:41 -0800, Jay Vosburgh wrote:
> Ben Hutchings <bhutchings@solarflare.com> wrote:
> 
> >bond_change_active_slave() may be called when a slave is added, even
> >if the bond has not been brought up yet.  It may then attempt to send
> >packets, and further it may use mcast_work which is uninitialised
> >before the bond is brought up.  Add the necessary checks for
> >netif_running(bond->dev).
> 
> 	I wondered if it would be better to instead arrange for
> bond_change_active_slave (and bond_select_active_slave, which calls it)
> to not be called when the bond is down, but that would require quite a
> bit of change to bond_enslave and bond_open.
[...]

Yes, it did seem to me that it would be better to defer all these
actions until bond_open, but I thought that would be too risky at this
stage in the release cycle.  Please do clean this up further in
net-next-2.6.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

