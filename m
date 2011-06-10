From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 01/10] net: introduce time stamping wrapper for
 netif_rx.
Date: Fri, 10 Jun 2011 19:27:47 +0200
Message-ID: <20110610172747.GA2925@riccoc20.at.omicron.at>
References: <cover.1307717675.git.richard.cochran@omicron.at>
 <34a4527448b3a36c88d0c1c3cb9ad8661e693d7a.1307717675.git.richard.cochran@omicron.at>
 <20110610082056.5ab6b981@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:63084 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755567Ab1FJR1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 13:27:53 -0400
Received: by bwz15 with SMTP id 15so2360995bwz.19
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 10:27:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110610082056.5ab6b981@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 10, 2011 at 08:20:56AM -0700, Stephen Hemminger wrote:
> On Fri, 10 Jun 2011 17:06:59 +0200
> Richard Cochran <richardcochran@gmail.com> wrote:
> 
> > +static inline int netif_rx_defer(struct sk_buff *skb)
> > +{
> > +	if (skb_defer_rx_timestamp(skb))
> > +		return NET_RX_SUCCESS;
> > +	return netif_rx(skb);
> > +}
> 
> Obvious question why not just put this in netif_rx.

Well, if a packet gets defered, then that means that the PHY driver
has decided to hold the packet until it obtains the time stamp from
the PHY hardware. Then, the driver delivers the packet using netif_rx.

So, we need to have two methods to deliver a frame, one with and one
without the hook, otherwise you get packets going round in circles.

Take a look at the one PHY driver using this (so far), on line 1017 of
drivers/net/phy/dp83640.c, to see how it works.

Thanks,
Richard

PS I did consider at renaming netif_rx to __netif_rx and then
implementing netif_rx as shown above, but I found many, many callers
of netif_rx which are not drivers, so I worry that bad side effects
would appear from such a change.


