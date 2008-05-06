From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/4] sky2: Hold RTNL while calling dev_close()
Date: Wed, 7 May 2008 00:59:39 +0100
Message-ID: <20080506235937.GK2217@solarflare.com>
References: <20080506182654.GF2217@solarflare.com> <20080506183958.GI2217@solarflare.com> <20080506161720.6475e5d4@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:54607 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754076AbYEGAAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 20:00:11 -0400
Content-Disposition: inline
In-Reply-To: <20080506161720.6475e5d4@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Tue, 6 May 2008 19:39:58 +0100
> Ben Hutchings <bhutchings@solarflare.com> wrote:
> 
> > dev_close() must be called holding the RTNL.  Compile-tested only.
> > 
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > ---
> >  drivers/net/sky2.c |    2 ++
> >  1 files changed, 2 insertions(+), 0 deletions(-)
> > 
> > diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> > index f226bca..9b046dd 100644
> > --- a/drivers/net/sky2.c
> > +++ b/drivers/net/sky2.c
> > @@ -2952,7 +2952,9 @@ static void sky2_restart(struct work_struct *work)
> >  			if (err) {
> >  				printk(KERN_INFO PFX "%s: could not restart %d\n",
> >  				       dev->name, err);
> > +				rtnl_lock();
> >  				dev_close(dev);
> > +				rtnl_unlock();
> >  			}
> >  		}
> >  	}
> > 
> 
> No this is bogus.  The rtnl mutex is already held.
> Look a little wider
<snip>

Sorry about that.  I made a list of functions to check and then edited
them in a second pass.  The function that needs locking in sky2.c is
sky2_resume() not sky2_restart().

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
