From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [Patch] netxen_nic: Bugfix for wrong RUNNING status of NX3031
 NICs with no link
Date: Thu, 2 Jan 2014 18:00:24 +0000
Message-ID: <1388685624.9947.7.camel@bwh-desktop.uk.level5networks.com>
References: <OFEE191896.FD28476A-ON48257C54.003205EE-48257C54.0032F33D@zte.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <li.fengmao@zte.com.cn>,
	<manish.chopra@qlogic.com>, <netdev@vger.kernel.org>,
	<rajesh.borundia@qlogic.com>, <sony.chacko@qlogic.com>
To: <jiang.biao2@zte.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:64954 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751210AbaABSA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 13:00:29 -0500
In-Reply-To: <OFEE191896.FD28476A-ON48257C54.003205EE-48257C54.0032F33D@zte.com.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-02 at 17:16 +0800, jiang.biao2@zte.com.cn wrote:
> > You cannot do this, because at the very exact moment you call
> > register_netdevice() the device can be brought up and once the
> > device is up the link can be brought up.
> 
> > Therefore if you invoke netif_carrier_off() right after
> > register_netdevice(), it can cancel out a legitimate
> > netif_carrier_on() call.
> 
> register_netdevice() should be call in probe(), at that time, is
> it impossible to bring up device because the driver loading has
> not finished?

So far as the networking core is concerned, when register_netdevice() is
called the device is ready to use.  But you can do:

rtnl_lock();
register_netdevice();
netif_carrier_off();
rtnl_unlock();

However, as I said before, the current order in netxen_nic works and
only older kernel versions require you to call netif_carrier_off() after
registering the device.

> Even that, the netif_carrier_off() will be called before
> netif_carrier_on(), and that will not be a problem.
> 
> Besides, the other net drivers(e.g igb, e1000, e1000e) I saw all
> call netif_carrier_off() after register_netdev(). There is no such
> problems in these drivers.

It is not easy to hit the race condition but it is real.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
