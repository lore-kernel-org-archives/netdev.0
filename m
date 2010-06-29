From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH -next] vmxnet3: fail when try to setup unsupported
	features
Date: Tue, 29 Jun 2010 11:15:20 +0200
Message-ID: <20100629091519.GA2555@dhcp-lab-161.englab.brq.redhat.com>
References: <20100628112942.0c919746@dhcp-lab-109.englab.brq.redhat.com> <89E2752CFA8EC044846EB8499819134102BCC3C10A@EXCH-MBX-4.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Amerigo Wang <amwang@redhat.com>
To: Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36862 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753912Ab0F2JQR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jun 2010 05:16:17 -0400
Content-Disposition: inline
In-Reply-To: <89E2752CFA8EC044846EB8499819134102BCC3C10A@EXCH-MBX-4.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 28, 2010 at 10:45:57AM -0700, Shreyas Bhatewara wrote:
> > +vmxnet3_set_flags(struct net_device *netdev, u32 data)
> > +{
> >  	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
> >  	u8 lro_requested = (data & ETH_FLAG_LRO) == 0 ? 0 : 1;
> >  	u8 lro_present = (netdev->features & NETIF_F_LRO) == 0 ? 0 : 1;
> > 
> > +	if (data & ~ETH_FLAG_LRO)
> > +		return -EOPNOTSUPP;
> > +
> >  	if (lro_requested ^ lro_present) {
> >  		/* toggle the LRO feature*/
> >  		netdev->features ^= NETIF_F_LRO;
> > --
> > 1.5.5.6
> 
> 
> Does not make sense to me. Switching LRO on/off is supported from the driver, why should the function return -EOPNOTSUPP ?

We return EOPNOTSUPP only if someone will try to setup other features
than LRO, if data == ETH_FLAG_LRO we will turn LRO on, and turn it off
when data == 0. 

Stanislaw
