From: Kulikov Vasiliy <segooon@gmail.com>
Subject: Re: [PATCH] eth16i: fix memory leak
Date: Tue, 13 Jul 2010 23:48:10 +0400
Message-ID: <20100713194810.GA15596@albatros>
References: <1279020138-9398-1-git-send-email-segooon@gmail.com>
 <20100713114347.GK5658@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org, Mika Kuoppala <miku@iki.fi>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tejun Heo <tj@kernel.org>, Jiri Pirko <jpirko@redhat.com>,
	netdev@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:42662 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399Ab0GMTsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 15:48:16 -0400
Content-Disposition: inline
In-Reply-To: <20100713114347.GK5658@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 13, 2010 at 13:43 +0200, Dan Carpenter wrote:
> On Tue, Jul 13, 2010 at 03:22:18PM +0400, Kulikov Vasiliy wrote:
> > Free allocated netdev if no probe is expected.
> > 
> > Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
> > ---
> >  drivers/net/eth16i.c |    4 +++-
> >  1 files changed, 3 insertions(+), 1 deletions(-)
> > 
> > diff --git a/drivers/net/eth16i.c b/drivers/net/eth16i.c
> > index 874973f..2bdd394 100644
> > --- a/drivers/net/eth16i.c
> > +++ b/drivers/net/eth16i.c
> > @@ -1442,8 +1442,10 @@ int __init init_module(void)
> >  		dev->if_port = eth16i_parse_mediatype(mediatype[this_dev]);
> >  
> >  		if(io[this_dev] == 0) {
> > -			if(this_dev != 0) /* Only autoprobe 1st one */
> > +			if (this_dev != 0) { /* Only autoprobe 1st one */
> > +				free_netdev(def);
> 					    ^^^
> 				free_netdev(dev);
Heh, this function is surrounded with #ifdef MODULE #endif, so this typo
was not detected at my test nonmoduled compilation. Thanks.

Patch v2 is comming.

> 
> regards,
> dan carpenter
> 
> >  				break;
> > +			}
> >  
> >  			printk(KERN_NOTICE "eth16i.c: Presently autoprobing (not recommended) for a single card.\n");
> >  		}
> > -- 
> 
