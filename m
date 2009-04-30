From: David Miller <davem@davemloft.net>
Subject: Re: tx queue hashing hot-spots and poor performance (multiq, ixgbe)
Date: Thu, 30 Apr 2009 07:08:11 -0700 (PDT)
Message-ID: <20090430.070811.260649067.davem@davemloft.net>
References: <96ff3930904300207l4ecfe90byd6cce3f56ce4e113@mail.gmail.com>
	<20090430.022417.07019547.davem@davemloft.net>
	<606676310904300704p5308e3b6le2c469d320cc669@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jelaas@gmail.com, netdev@vger.kernel.org
To: andrew@whydna.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49059
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762532AbZD3OIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 10:08:18 -0400
In-Reply-To: <606676310904300704p5308e3b6le2c469d320cc669@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Dickinson <andrew@whydna.net>
Date: Thu, 30 Apr 2009 07:04:33 -0700

>  I'll do some debugging around skb_tx_hash() and see if I can make
> sense of it.  I'll let you know what I find.  My hypothesis is that
> skb_record_rx_queue() isn't being called, but I should dig into it
> before I start making claims. ;-P

That's one possibility.

Another is that the hashing isn't working out.  One way to
play with that is to simply replace the:

		hash = skb_get_rx_queue(skb);

in skb_tx_hash() with something like:

		return skb_get_rx_queue(skb) % dev->real_num_tx_queues;

and see if that improves the situation.
