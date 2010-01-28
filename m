From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH] be2net: Bug fix to support newer generation
 of BE ASIC
Date: Thu, 28 Jan 2010 14:51:14 -0800
Message-ID: <20100128225114.GA1588@kroah.com>
References: <20100128075633.GA4785@serverengines.com>
 <1264718429.373.520.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ajit Khaparde <ajitk@serverengines.com>,
	netdev <netdev@vger.kernel.org>, stable-review@kernel.org,
	David Miller <davem@davemloft.net>, stable@kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:42344 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751616Ab0A1WwL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jan 2010 17:52:11 -0500
Content-Disposition: inline
In-Reply-To: <1264718429.373.520.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 28, 2010 at 10:40:29PM +0000, Ben Hutchings wrote:
> On Thu, 2010-01-28 at 13:26 +0530, Ajit Khaparde wrote:
> > Bug fix in be2net for newer generation of BladeEngine ASIC.
> [...]
> > @@ -2162,6 +2168,7 @@ static int be_stats_init(struct be_adapter *adapter)
> >  	cmd->va = pci_alloc_consistent(adapter->pdev, cmd->size, &cmd->dma);
> >  	if (cmd->va == NULL)
> >  		return -1;
> > +	memset(cmd->va, cmd->size, 0);

Heh, that's funny.  Yeah, that is not correct at all.  If that does
anything, something else is seriously wrong :)

> >  	return 0;
> >  }
> >  
> [...]
> 
> I don't think this does what you think it does.
> 
> Also, you should either send this patch to stable@kernel.org, or NAK the
> addition of PCI ids for BladeEngine 3 in 2.6.32.7.

Why?  How does the pci id patch for 2.6.32.7 matter with this change?

confused,

greg k-h
