From: Daniel Mack <daniel@caiaq.de>
Subject: Re: [PATCH] Libertas: fix buffer overflow in lbs_get_essid()
Date: Thu, 17 Dec 2009 07:15:08 +0800
Message-ID: <20091216231508.GX28375@buzzloop.caiaq.de>
References: <1260936778-2096-1-git-send-email-daniel@caiaq.de>
 <1260982667.2179.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Holger Schurig <holgerschurig@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Maithili Hinge <maithili@marvell.com>,
	Kiran Divekar <dkiran@marvell.com>,
	Michael Hirsch <m.hirsch@raumfeld.com>, netdev@vger.kernel.org,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	stable@kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from buzzloop.caiaq.de ([212.112.241.133]:40760 "EHLO
	buzzloop.caiaq.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935282AbZLPXPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 18:15:16 -0500
Content-Disposition: inline
In-Reply-To: <1260982667.2179.9.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 16, 2009 at 08:57:47AM -0800, Dan Williams wrote:
> On Wed, 2009-12-16 at 05:12 +0100, Daniel Mack wrote:
> > The libertas driver copies the SSID buffer back to the wireless core and
> > appends a trailing NULL character for termination. This is
> > 
> > a) unnecessary because the buffer is allocated with kzalloc and is hence
> >    already NULLed when this function is called, and
> > 
> > b) for priv->curbssparams.ssid_len == 32, it writes back one byte too
> >    much which causes memory corruptions.
> > 
> > Fix this by removing the extra write.
> 
> Acked-by: Dan Williams <dcbw@redhat.com>

Thanks, everyone. Who will care to pick an queue this one?

Daniel


> > Signed-off-by: Daniel Mack <daniel@caiaq.de>
> > Cc: Dan Williams <dcbw@redhat.com>
> > Cc: Holger Schurig <holgerschurig@gmail.com>
> > Cc: John W. Linville <linville@tuxdriver.com>
> > Cc: Stephen Hemminger <shemminger@vyatta.com>
> > Cc: Maithili Hinge <maithili@marvell.com>
> > Cc: Kiran Divekar <dkiran@marvell.com>
> > Cc: Michael Hirsch <m.hirsch@raumfeld.com>
> > Cc: netdev@vger.kernel.org
> > Cc: libertas-dev@lists.infradead.org
> > Cc: linux-wireless@lists.infradead.org
> > Cc: stable@kernel.org
> > ---
> >  drivers/net/wireless/libertas/wext.c |    2 --
> >  1 files changed, 0 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/wireless/libertas/wext.c b/drivers/net/wireless/libertas/wext.c
> > index be837a0..01c738b 100644
> > --- a/drivers/net/wireless/libertas/wext.c
> > +++ b/drivers/net/wireless/libertas/wext.c
> > @@ -1953,10 +1953,8 @@ static int lbs_get_essid(struct net_device *dev, struct iw_request_info *info,
> >  	if (priv->connect_status == LBS_CONNECTED) {
> >  		memcpy(extra, priv->curbssparams.ssid,
> >  		       priv->curbssparams.ssid_len);
> > -		extra[priv->curbssparams.ssid_len] = '\0';
> >  	} else {
> >  		memset(extra, 0, 32);
> > -		extra[priv->curbssparams.ssid_len] = '\0';
> >  	}
> >  	/*
> >  	 * If none, we may want to get the one that was set
> 
