From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: Hold RTNL while calling dev_close() [2nd try]
Date: Tue, 10 Jun 2008 15:25:01 -0700
Message-ID: <20080610152501.5c45ce02@extreme>
References: <20080506182654.GF2217@solarflare.com>
	<20080506183958.GI2217@solarflare.com>
	<20080506161720.6475e5d4@extreme>
	<20080506235937.GK2217@solarflare.com>
	<20080531155251.GM1743@solarflare.com>
	<484EFD4A.3030107@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55756 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760086AbYFJWZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 18:25:38 -0400
In-Reply-To: <484EFD4A.3030107@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Jun 2008 18:16:42 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Ben Hutchings wrote:
> > dev_close() must be called holding the RTNL.  Compile-tested only.
> > 
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > ---
> >  drivers/net/sky2.c |    2 ++
> >  1 files changed, 2 insertions(+), 0 deletions(-)
> > 
> > diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> > index f226bca..b9bdf88 100644
> > --- a/drivers/net/sky2.c
> > +++ b/drivers/net/sky2.c
> > @@ -4395,7 +4395,9 @@ static int sky2_resume(struct pci_dev *pdev)
> >  			if (err) {
> >  				printk(KERN_ERR PFX "%s: could not up: %d\n",
> >  				       dev->name, err);
> > +				rtnl_lock();
> >  				dev_close(dev);
> > +				rtnl_unlock();
> >  				goto out;
> >  			}
> 
> stephen acked this?  I don't see that in my notes...
> 
> 

yes. this should go in
