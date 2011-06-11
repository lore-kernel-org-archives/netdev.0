From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/10] net: introduce time stamping wrapper for
 netif_rx.
Date: Sat, 11 Jun 2011 16:10:25 -0700 (PDT)
Message-ID: <20110611.161025.317157517912316585.davem@davemloft.net>
References: <20110610082056.5ab6b981@nehalam.ftrdhcpuser.net>
	<20110610172747.GA2925@riccoc20.at.omicron.at>
	<20110610111924.54fede19@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55075 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751730Ab1FKXK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2011 19:10:28 -0400
In-Reply-To: <20110610111924.54fede19@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 10 Jun 2011 11:19:24 -0700

> On Fri, 10 Jun 2011 19:27:47 +0200
> Richard Cochran <richardcochran@gmail.com> wrote:
> 
>> On Fri, Jun 10, 2011 at 08:20:56AM -0700, Stephen Hemminger wrote:
>> > On Fri, 10 Jun 2011 17:06:59 +0200
>> > Richard Cochran <richardcochran@gmail.com> wrote:
>> > 
>> > > +static inline int netif_rx_defer(struct sk_buff *skb)
>> > > +{
>> > > +	if (skb_defer_rx_timestamp(skb))
>> > > +		return NET_RX_SUCCESS;
>> > > +	return netif_rx(skb);
>> > > +}
>> > 
>> > Obvious question why not just put this in netif_rx.
>> 
>> Well, if a packet gets defered, then that means that the PHY driver
>> has decided to hold the packet until it obtains the time stamp from
>> the PHY hardware. Then, the driver delivers the packet using netif_rx.
>> 
>> So, we need to have two methods to deliver a frame, one with and one
>> without the hook, otherwise you get packets going round in circles.
>> 
>> Take a look at the one PHY driver using this (so far), on line 1017 of
>> drivers/net/phy/dp83640.c, to see how it works.
>> 
>> Thanks,
>> Richard
>> 
>> PS I did consider at renaming netif_rx to __netif_rx and then
>> implementing netif_rx as shown above, but I found many, many callers
>> of netif_rx which are not drivers, so I worry that bad side effects
>> would appear from such a change.
> 
> Why not use a timestamp present flag like the receive hashing code
> already does.

I agree with Stephen that we should be decreasing the number of driver
interfaces not increasing them.

Also, it makes no sense to add this for obsolete RX processing such
that netif_rx() is.

If drivers want to add fancy features like this timestamping stuff,
they better move on to NAPI, GRO, etc. first.  Putting support for
new features into deprecating things like netif_rx() makes no
sense at all.

