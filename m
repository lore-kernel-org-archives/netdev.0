From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Thu, 27 Aug 2009 11:40:44 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908271139450.14277@gentwo.org>
References: <OFB18AD855.24C5AC71-ON8825761D.00687D5E-8825761D.0068BB9C@us.ibm.com>  <alpine.DEB.1.10.0908251514190.17963@gentwo.org>  <1251239734.3169.65.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908261223210.9933@gentwo.org>
 <1251309040.10599.34.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908261506590.9933@gentwo.org> <1251324666.10599.72.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Stevens <dlstevens@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	niv@linux.vnet.ibm.com
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.ultrahosting.com ([74.213.175.253]:36141 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751109AbZH0PlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2009 11:41:24 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E17B082C9B0
	for <netdev@vger.kernel.org>; Thu, 27 Aug 2009 11:42:30 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id MvbNHoZzqY1X for <netdev@vger.kernel.org>;
	Thu, 27 Aug 2009 11:42:30 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id EA6A282CA64
	for <netdev@vger.kernel.org>; Thu, 27 Aug 2009 11:42:16 -0400 (EDT)
In-Reply-To: <1251324666.10599.72.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Aug 2009, Sridhar Samudrala wrote:

> > ip_local_out is returning ENOBUFS. Something at the qdisc layer is
> > dropping the packet and not incrementing counters.
>
> Is the ENOBUFS return with your/Eric's patch? I thought you were
> were seeing NET_XMIT_DROP without any patches.

Both Erics latest patch and your patch were applied.

> > > I think we need to figure out where they are getting dropped and then
> > > decide on the appropriate counter to be incremented.
> >
> > Right. Where in the qdisc layer do drops occur?
>
> The normal path where the packets are dropped when the tx qlen is exceeded is
>   pfifo_fast_enqueue() -> qdisc_drop()
> In this path, drops are counted.
> The other place is in dev_queue_xmit(), but you are not hitting that case too.
>
> So it looks like there is another place where they are getting dropped.

Hmmm.. I need to find more time to dig into this.

Anyways it seems that Eric's latest patch is doing many good things for
packet loss accounting.

