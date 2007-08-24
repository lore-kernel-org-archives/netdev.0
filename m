From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH v2] [02/10] pasemi_mac: Stop using the pci config space
	accessors for register read/writes
Date: Fri, 24 Aug 2007 13:11:04 -0500
Message-ID: <20070824181104.GA17171@lixom.net>
References: <20070817205413.548020000@lixom.net> <20070822141248.GC16830@lixom.net> <20070823181310.GB31882@lixom.net> <20070824140531.ff7d66bf.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, linuxppc-dev@ozlabs.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:58633 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761546AbXHXTF4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2007 15:05:56 -0400
Content-Disposition: inline
In-Reply-To: <20070824140531.ff7d66bf.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 24, 2007 at 02:05:31PM +1000, Stephen Rothwell wrote:
> On Thu, 23 Aug 2007 13:13:10 -0500 Olof Johansson <olof@lixom.net> wrote:
> >
> >  out:
> > -	pci_dev_put(mac->iob_pdev);
> > -out_put_dma_pdev:
> > -	pci_dev_put(mac->dma_pdev);
> > -out_free_netdev:
> > +	if (mac->iob_pdev)
> > +		pci_dev_put(mac->iob_pdev);
> > +	if (mac->dma_pdev)
> > +		pci_dev_put(mac->dma_pdev);
> 
> It is not documented as such (as far as I can see), but pci_dev_put is
> safe to call with NULL. And there are other places in the kernel that
> explicitly use that fact.

Some places check, others do not. I'll leave it be for now but might take
care of it during some future cleanup. Thanks for point it out though.


-Olof
