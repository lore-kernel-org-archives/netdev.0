From: Matthew Whitehead <tedheadster@gmail.com>
Subject: Re: [PATCH net-next] 8390 : Replace ei_debug with
 msg_enable/NETIF_MSG_* feature
Date: Thu, 7 Nov 2013 16:42:22 -0500
Message-ID: <20131107214222.GA28471@mwhitehe.csb>
References: <1383771418-28616-1-git-send-email-tedheadster@gmail.com>
 <1383781753.7940.38.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f49.google.com ([209.85.128.49]:36660 "EHLO
	mail-qe0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752751Ab3KGVmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 16:42:45 -0500
Received: by mail-qe0-f49.google.com with SMTP id a11so1114446qen.22
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 13:42:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1383781753.7940.38.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 06, 2013 at 03:49:13PM -0800, Joe Perches wrote:
> On Wed, 2013-11-06 at 15:56 -0500, Matthew Whitehead wrote:
> > Removed the shared ei_debug variable. Replaced it by adding u32 msg_enable to
> > the private struct ei_device. Now each 8390 ethernet instance has a per-device
> > logging variable.
> > 
> > Changed printk() calls to netdev_(dbg|info|warn|err) when possible.
> 
> Hello Matthew.
> 
> Ideally, some of these would use:
> 
> 	netif_<level>(struct ei_device *, type, struct net_device *, fmt, ...)
> 
> > @@ -352,10 +360,12 @@ static void
> []
> > +    if (ei_local->msg_enable & NETIF_MSG_HW)
> > +		netdev_dbg(dev, "resetting the 8390 t=%ld...\n", jiffies);
> 
> 	netif_dbg(ei_local, hw, dev, "resetting the 8390 t=%...\n", jiffies);
> 

Joe,
  what about using netif_msg_(drv|probe|ifdown|rx_err|tx_err|tx_queued|intr|rx_status|hw) calls?
For example:

if (netif_msg_rx_err(ei_local))
        netdev_err(dev, "Couldn't allocate a sk_buff of size %d\n", pkt_len);

I did a V2 in this style, but I'll change it to

netif_<level>(struct ei_device *, type, struct net_device *, fmt, ...)

if that is the more preferred style

- Matthew
