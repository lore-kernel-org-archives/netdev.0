From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next] xen-netfront: convert to GRO API and advertise
 this feature
Date: Mon, 30 Sep 2013 10:12:11 +0100
Message-ID: <1380532331.1302.9.camel@kazak.uk.xensource.com>
References: <1379779543-27122-1-git-send-email-wei.liu2@citrix.com>
	 <20130928.153800.327243541797748645.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>, <abchak@juniper.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:17743 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752775Ab3I3JMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 05:12:15 -0400
In-Reply-To: <20130928.153800.327243541797748645.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-09-28 at 15:38 -0400, David Miller wrote:
> From: Wei Liu <wei.liu2@citrix.com>
> Date: Sat, 21 Sep 2013 17:05:43 +0100
> 
> > @@ -1371,7 +1373,8 @@ static struct net_device *xennet_create_dev(struct xenbus_device *dev)
> >  	netif_napi_add(netdev, &np->napi, xennet_poll, 64);
> >  	netdev->features        = NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
> >  				  NETIF_F_GSO_ROBUST;
> > -	netdev->hw_features	= NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO;
> > +	netdev->hw_features	= NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO |
> > +				  NETIF_F_GRO;
> 
> Please post a new version of this patch with the feedback you've been
> given integrated, in particular with this part removed because it is
> not necessary.
> 
> Ian, please review the patch when Wei posts it.

I will, but note:
        $ ./scripts/get_maintainer.pl -f drivers/net/xen-netfront.c 
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com> (supporter:XEN HYPERVISOR IN...)
        Jeremy Fitzhardinge <jeremy@goop.org> (supporter:XEN HYPERVISOR IN...)
        xen-devel@lists.xensource.com (moderated list:XEN HYPERVISOR IN...)
        virtualization@lists.linux-foundation.org (open list:XEN HYPERVISOR IN...)
        netdev@vger.kernel.org (open list:NETWORKING DRIVERS)
        linux-kernel@vger.kernel.org (open list)
        
Strictly speaking I maintain netback not front, so Wei please remember
to CC the right people (mainly Konrad) as well as me.

BTW I think this separation is a good thing since it keeps changes to
the protocol "honest". Doesn't matter so much for this particular patch
since don't think it actually touches the protocol.

Ian.
