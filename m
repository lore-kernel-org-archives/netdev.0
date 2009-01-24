From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [PATCH 02/21] [next] qlge: Add new functions for signaling link
	up/down.
Date: Sat, 24 Jan 2009 11:32:21 -0800
Message-ID: <20090124193221.GC18522@linux-ox1b.qlogic.org>
References: <20090123151513.GA8526@linux-ox1b.qlogic.org> <1232723799-8620-2-git-send-email-ron.mercer@qlogic.com> <1232753014.3005.2.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Driver <Linux-Driver@qlogic.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:6213 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752516AbZAXTdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jan 2009 14:33:31 -0500
Content-Disposition: inline
In-Reply-To: <1232753014.3005.2.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 23, 2009 at 03:23:33PM -0800, Ben Hutchings wrote:
> On Fri, 2009-01-23 at 07:16 -0800, Ron Mercer wrote:
> > Centralize this call as it will also be used by firmware events.
> > 
> > Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
> > ---
> >  drivers/net/qlge/qlge_main.c |   38 ++++++++++++++++++++++++--------------
> >  1 files changed, 24 insertions(+), 14 deletions(-)
> > 
> > diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
> > index a530f5b..e6f9146 100644
> > --- a/drivers/net/qlge/qlge_main.c
> > +++ b/drivers/net/qlge/qlge_main.c
> > @@ -240,6 +240,24 @@ exit:
> >  	return status;
> >  }
> >  
> > +static void ql_link_on(struct ql_adapter *qdev)
> > +{
> > +	if (!netif_carrier_ok(qdev->ndev)) {
> > +		QPRINTK(qdev, LINK, INFO, "Link is Up.\n");
> > +		netif_carrier_on(qdev->ndev);
> > +		netif_wake_queue(qdev->ndev);
> > +	}
> > +}
> > +
> > +static void ql_link_off(struct ql_adapter *qdev)
> > +{
> > +	if (netif_carrier_ok(qdev->ndev)) {
> > +		QPRINTK(qdev, LINK, INFO, "Link is Down.\n");
> > +		netif_carrier_off(qdev->ndev);
> > +		netif_stop_queue(qdev->ndev);
> > +	}
> > +}
> > +
> 
> netif_{wake,stop_queue}() are redundant with netif_carrier_{on,off}() so
> I think this patch is (mostly?) unnecessary.
> 
> Ben.
> 
> -- 
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.

Yes, I see that some of the other drivers got rid of the
start/stop/wake.  If I have to re-submit this patch series I will remove
those lines.  If Dave accepts these patches then I will remove the lines
in my next series.

Thanks,
Ron
