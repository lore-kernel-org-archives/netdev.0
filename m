From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Wed, 26 Aug 2009 15:09:49 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908261506590.9933@gentwo.org>
References: <OFB18AD855.24C5AC71-ON8825761D.00687D5E-8825761D.0068BB9C@us.ibm.com>  <alpine.DEB.1.10.0908251514190.17963@gentwo.org>  <1251239734.3169.65.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908261223210.9933@gentwo.org>
 <1251309040.10599.34.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Stevens <dlstevens@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	niv@linux.vnet.ibm.com
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.ultrahosting.com ([74.213.175.253]:59243 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751081AbZHZTKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 15:10:37 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1AB2F82C951
	for <netdev@vger.kernel.org>; Wed, 26 Aug 2009 15:11:38 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id TSuemLzy4AQn for <netdev@vger.kernel.org>;
	Wed, 26 Aug 2009 15:11:38 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 91C5182C970
	for <netdev@vger.kernel.org>; Wed, 26 Aug 2009 15:11:09 -0400 (EDT)
In-Reply-To: <1251309040.10599.34.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Aug 2009, Sridhar Samudrala wrote:

> >  They are reported for IP and UDP.
> Not clear what you meant by this.

The SNMP and UDP statistics show the loss. qdisc level does not show the
loss.

> > root@rd-strategy3-deb64:/home/clameter#tc -s qdisc show
> > qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1
> > 1 1 1 1
> >  Sent 6208 bytes 64 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
>
> Even the Sent count seems to be too low. Are you looking at the right
> device?

I would think that tc displays all queues? It says eth0 and eth0 is the
device that we sent the data out on.


> So based on the current analysis, the packets are getting dropped after
> the call to ip_local_out() in ip_push_pending_frames(). ip_local_out()
> is failing with NET_XMIT_DROP. But we are not sure where they are
> getting dropped. Is that right?

ip_local_out is returning ENOBUFS. Something at the qdisc layer is
dropping the packet and not incrementing counters.

> I think we need to figure out where they are getting dropped and then
> decide on the appropriate counter to be incremented.

Right. Where in the qdisc layer do drops occur?

