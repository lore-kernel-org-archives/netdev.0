From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] Add support for netconsole driver used on bridge device
 with VIF attached
Date: Mon, 21 Jan 2013 17:28:28 +0000
Message-ID: <1358789308.3279.271.camel@zakaz.uk.xensource.com>
References: <5757e54b-902b-4338-8ac9-43857cd1906c@default>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Yuval Shaia <yuval.shaia@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:47210 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635Ab3AUR2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 12:28:31 -0500
In-Reply-To: <5757e54b-902b-4338-8ac9-43857cd1906c@default>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-21 at 17:17 +0000, Yuval Shaia wrote:

> When starting a VM which has virtual interface attached to the same 
> bridge (i.e vif = [type=netfront,bridge=xenbr0'] in vm.cfg) which is 
> used for netconsole the
> following message appears (after about 60 seconds) and VM creation 
> operation fails.
>       Error: Device 0 (vif) could not be connected. Hotplug scripts not 
> working.

I'm not sure how this can relate netconsole since this happens before
the guest even runs, doesn't it?

> As i see it, netconsole driver requires ndo_poll_controller from the
> device's controlling driver (function __netpoll_setup in
> net/core/netpoll.c), a thing that is not supported currently in
> xen_netback driver which is the driver that runs on dom0 and serve
> VM's virtual interface.

Which domain is using netconsole? Is it dom0 or domU? What parameters do
you give it?

I assume it is the domU but if that's the case I don't see why a netback
rather than netfront patch would be required.

Or is dom0 doing netconsole where the log receiver is a domU?

Ian.
