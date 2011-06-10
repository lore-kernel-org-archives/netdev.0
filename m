From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 01/10] net: introduce time stamping wrapper for
 netif_rx.
Date: Fri, 10 Jun 2011 11:19:24 -0700
Message-ID: <20110610111924.54fede19@nehalam.ftrdhcpuser.net>
References: <cover.1307717675.git.richard.cochran@omicron.at>
	<34a4527448b3a36c88d0c1c3cb9ad8661e693d7a.1307717675.git.richard.cochran@omicron.at>
	<20110610082056.5ab6b981@nehalam.ftrdhcpuser.net>
	<20110610172747.GA2925@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34374 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755904Ab1FJST1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2011 14:19:27 -0400
In-Reply-To: <20110610172747.GA2925@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 10 Jun 2011 19:27:47 +0200
Richard Cochran <richardcochran@gmail.com> wrote:

> On Fri, Jun 10, 2011 at 08:20:56AM -0700, Stephen Hemminger wrote:
> > On Fri, 10 Jun 2011 17:06:59 +0200
> > Richard Cochran <richardcochran@gmail.com> wrote:
> > 
> > > +static inline int netif_rx_defer(struct sk_buff *skb)
> > > +{
> > > +	if (skb_defer_rx_timestamp(skb))
> > > +		return NET_RX_SUCCESS;
> > > +	return netif_rx(skb);
> > > +}
> > 
> > Obvious question why not just put this in netif_rx.
> 
> Well, if a packet gets defered, then that means that the PHY driver
> has decided to hold the packet until it obtains the time stamp from
> the PHY hardware. Then, the driver delivers the packet using netif_rx.
> 
> So, we need to have two methods to deliver a frame, one with and one
> without the hook, otherwise you get packets going round in circles.
> 
> Take a look at the one PHY driver using this (so far), on line 1017 of
> drivers/net/phy/dp83640.c, to see how it works.
> 
> Thanks,
> Richard
> 
> PS I did consider at renaming netif_rx to __netif_rx and then
> implementing netif_rx as shown above, but I found many, many callers
> of netif_rx which are not drivers, so I worry that bad side effects
> would appear from such a change.

Why not use a timestamp present flag like the receive hashing code
already does.
