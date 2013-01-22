From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] Add support for netconsole driver used on bridge device
 with VIF attached
Date: Tue, 22 Jan 2013 09:23:32 +0000
Message-ID: <1358846612.3279.282.camel@zakaz.uk.xensource.com>
References: <5757e54b-902b-4338-8ac9-43857cd1906c@default>
	 <1358789308.3279.271.camel@zakaz.uk.xensource.com>
	 <50FD8243.6000501@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "yuval.shaia@oracle.com" <yuval.shaia@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:41313 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738Ab3AVJXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 04:23:35 -0500
In-Reply-To: <50FD8243.6000501@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-21 at 18:00 +0000, yuval.shaia@oracle.com wrote:
> On 01/21/2013 07:28 PM, Ian Campbell wrote:
> > On Mon, 2013-01-21 at 17:17 +0000, Yuval Shaia wrote:
> >
> >> When starting a VM which has virtual interface attached to the same
> >> bridge (i.e vif = [type=netfront,bridge=xenbr0'] in vm.cfg) which is
> >> used for netconsole the
> >> following message appears (after about 60 seconds) and VM creation
> >> operation fails.
> >>        Error: Device 0 (vif) could not be connected. Hotplug scripts not
> >> working.
> > I'm not sure how this can relate netconsole since this happens before
> > the guest even runs, doesn't it?
> Running the same scenario without netconsole runs smoothly.

But why? I can't make sense of your scenario and therefore cannot
explain why this patch would make any difference. Perhaps your patch is
just papering over some other issue?

> >> As i see it, netconsole driver requires ndo_poll_controller from the
> >> device's controlling driver (function __netpoll_setup in
> >> net/core/netpoll.c), a thing that is not supported currently in
> >> xen_netback driver which is the driver that runs on dom0 and serve
> >> VM's virtual interface.
> > Which domain is using netconsole? Is it dom0 or domU? What parameters do
> > you give it?
> dom0.
> parameters: netconsole=1111@src-ip/xenbr0,2002@dst-ip/dst-mac

You give these parameters to dom0 so that dom0's own logs are sent to
some other host? 

Are dst-ip and dst-mac a domain on the same host or are they some offbox
logging service?

I can see why the *bridge* device might need an ndo_poll_controller hook
in this setup but I can't see any reason why the netback device would
need one.

> >
> > I assume it is the domU but if that's the case I don't see why a netback
> > rather than netfront patch would be required.
> >
> > Or is dom0 doing netconsole where the log receiver is a domU?
> Log received at dom0 as output of xm cr vm.cfg command.
> netconsole is used on dom0 to monitor its log

Are you now saying that logging goes from domU to dom0? Which is it?

In this scenario there is really no reason I can see that netback would
need an ndo_poll_controller hook -- that would be needed in the domU in
the netfront driver.

Please can you explain the exact code path which results in this new
hook being called.

BTW looking at the patch as it is any use of this hook should be wrapped
in CONFIG_NET_POLL_CONTROLLER.

Ian.
