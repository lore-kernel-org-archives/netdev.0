From: David Miller <davem@davemloft.net>
Subject: Re: TAHI CN-6-4-1 failed on Linux 2.6.32 kernel
Date: Thu, 19 Aug 2010 17:06:49 -0700 (PDT)
Message-ID: <20100819.170649.212693227.davem@davemloft.net>
References: <AANLkTik9=TcMWzNyKWYyDu+bbGscPne6++gD42aju9s_@mail.gmail.com>
	<AANLkTi=qP7BO2=Uhx2Xb0XiLbUz0mPutbg0vz6QnMgYb@mail.gmail.com>
	<AANLkTim+1=4VCmY=fO5HTvDwKnveGEPsY1h1O64vnT6L@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, usagi-users-ctl@ml.linux-ipv6.org,
	netdev@vger.kernel.org
To: schen@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39391
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750849Ab0HTAGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 20:06:33 -0400
In-Reply-To: <AANLkTim+1=4VCmY=fO5HTvDwKnveGEPsY1h1O64vnT6L@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Chen <schen@mvista.com>
Date: Thu, 19 Aug 2010 13:35:14 -0500

> I trace through the code.  It appears that the network driver (e1000e
> for my setup) always set ip_summed to CHECKSUM_UNNECESSARY.  I have
> been unsuccessful to get the driver to take the other branch where
> ip_summed is set to CHECKSUM_COMPLETE.  Even when I hard code
> ip_summed to CHECKSUM_COMPLETE, __skb_checksum_complete_head set
> ip_summed to CHECKSUM_UNNECESSARY after recomputing the checksum.
> 
> So far the only way I'm able to get ICMP to recompute checksum is
> through the attached hack.  Even though I can get all the tests to
> pass, but it just seem wrong.

If turning off hardware RX checksumming with ethtool has no effect,
and the problem is seen with multiple ethernet cards, the problem
is elsewhere.

First of all, if you turn RX checksumming off, the checksum field
of the SKB should always be skb->ip_summed = 0.  If this is not
happening, find out why.

Put diagnostics into drivers/net/e1000e/netdev.c:e1000_rx_checksum()
and see what's happening.

If that code isn't setting ->ip_summed, then something else is,
perhaps some decapsulation code?  Do these packets get embedded
in a tunnel or other kind of transport?  I see that this test
has IPSEC disabled, so it can't be that.
