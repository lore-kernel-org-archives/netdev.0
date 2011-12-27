From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] skge: restore multicast rx filter on resume
Date: Tue, 27 Dec 2011 09:56:35 -0800
Message-ID: <20111227095635.19087752@nehalam.linuxnetplumber.net>
References: <20111225081833.GC3088@florz.florz.dyndns.org>
	<20111226.151754.417402855307646295.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: florz@florz.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48232 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754520Ab1L0R4i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Dec 2011 12:56:38 -0500
In-Reply-To: <20111226.151754.417402855307646295.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 Dec 2011 15:17:54 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Florian Zumbiehl <florz@florz.de>
> Date: Sun, 25 Dec 2011 09:18:33 +0100
> 
> > skge: restore multicast rx filter on resume
> >     
> > Signed-off-by: Florian Zumbiehl <florz@florz.de>
> 
> Stephen?  This one looks fine to me.
> 
> > diff --git a/drivers/net/skge.c b/drivers/net/skge.c
> > index f4be5c7..cd968e5 100644
> > --- a/drivers/net/skge.c
> > +++ b/drivers/net/skge.c
> > @@ -4046,6 +4046,7 @@ static int skge_resume(struct device *dev)
> >  				dev_close(dev);
> >  				goto out;
> >  			}
> > +			skge_set_multicast(dev);
> >  		}
> >  	}
> >  out:

Right idea, but it needs to be done in a different spot to catch
all the other device restart cases like changing settings.
