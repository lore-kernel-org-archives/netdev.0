From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Sun, 30 Aug 2009 09:51:55 +0930
Message-ID: <20090830095155.5ba1cdc5.lk-netdev@lk-netdev.nosense.org>
References: <alpine.DEB.1.10.0908271139450.14277@gentwo.org>
	<alpine.DEB.1.10.0908271621260.28029@gentwo.org>
	<alpine.DEB.1.10.0908280948320.3747@gentwo.org>
	<20090828.122459.245170385.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: cl@linux-foundation.org, sri@us.ibm.com, dlstevens@us.ibm.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	niv@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.adam.net.au ([202.136.110.247]:36060 "EHLO
	smtp4.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752301AbZH3AWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 20:22:19 -0400
In-Reply-To: <20090828.122459.245170385.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Aug 2009 12:24:59 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Christoph Lameter <cl@linux-foundation.org>
> Date: Fri, 28 Aug 2009 09:53:40 -0400 (EDT)
> 
> > Seems though that the qdisc drop count does not flow into the tx_dropped
> > counter for the interface.
> 
> And it should not.
> 
> The qdisc drops the packet due to flow control, not the hardware
> device.
> 
> Device drops are for things like transmission errors on the wire.
> 
> If you start incrementing tx_dropped here, people won't be able
> to tell they have a deteriorating cable or bad switch or similar.

And it does, because Cisco do it this way, although they record them as
TX errors not drops. It's quite annoying to have to keep reminding
yourself that the errors shown on the traffic graphs probably aren't
actually errors - of course real errors then become hidden in the
"normal" ones.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
