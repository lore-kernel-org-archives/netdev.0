From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: jumbo frame regression fix
Date: Tue, 2 Oct 2007 21:53:16 -0700
Message-ID: <20071002215316.0faa7676@freepuppy.rosehill>
References: <1191372129.26233.12.camel@localhost>
	<20071002180209.47c350a3@freepuppy.rosehill>
	<4702EB4A.4000208@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pomac@vapor.com, Linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35033 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751150AbXJCExx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 00:53:53 -0400
In-Reply-To: <4702EB4A.4000208@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 02 Oct 2007 21:07:22 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Stephen Hemminger wrote:
> > Remove unneeded check that caused problems with jumbo frame sizes.
> > The check was recently added and is wrong.
> > When using jumbo frames the sky2 driver does fragmentation, so
> > rx_data_size is less than mtu.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> > 
> > --- a/drivers/net/sky2.c	2007-10-02 17:56:31.000000000 -0700
> > +++ b/drivers/net/sky2.c	2007-10-02 17:58:56.000000000 -0700
> > @@ -2163,9 +2163,6 @@ static struct sk_buff *sky2_receive(stru
> >  	sky2->rx_next = (sky2->rx_next + 1) % sky2->rx_pending;
> >  	prefetch(sky2->rx_ring + sky2->rx_next);
> >  
> > -	if (length < ETH_ZLEN || length > sky2->rx_data_size)
> > -		goto len_error;
> > -
> 
> 2.6.23?  2.6.24?  enquiring minds want to know...

2.6.23, since it is a regression

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
