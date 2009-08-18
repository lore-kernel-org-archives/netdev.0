From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Mon, 17 Aug 2009 17:12:12 -0700
Message-ID: <1250554332.25939.46.camel@w-sridhar.beaverton.ibm.com>
References: <alpine.DEB.1.10.0908171548040.20399@gentwo.org>
	 <4A89C026.4030402@us.ibm.com>
	 <alpine.DEB.1.10.0908171642500.20399@gentwo.org>
	 <1250545839.25939.21.camel@w-sridhar.beaverton.ibm.com>
	 <alpine.DEB.1.10.0908171813070.15956@gentwo.org>
	 <1250549034.25939.30.camel@w-sridhar.beaverton.ibm.com>
	 <alpine.DEB.1.10.0908171848370.15956@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Nivedita Singhvi <niv@us.ibm.com>, netdev@vger.kernel.org,
	Eric Dumazet <dada1@cosmosbay.com>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:59952 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758388AbZHRARH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 20:17:07 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7I0F7x1008714
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 18:15:07 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7I0H42C199082
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 18:17:04 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7I0H3Ia003939
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 18:17:04 -0600
In-Reply-To: <alpine.DEB.1.10.0908171848370.15956@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-08-17 at 18:52 -0400, Christoph Lameter wrote:
> On Mon, 17 Aug 2009, Sridhar Samudrala wrote:
> 
> > On Mon, 2009-08-17 at 18:13 -0400, Christoph Lameter wrote:
> > > On Mon, 17 Aug 2009, Sridhar Samudrala wrote:
> > >
> > > > What about ethtool -S ? Does it report any errors?
> > >
> > > Neither. This is is a broadcom bnx2 NIC.
> >
> > Are you sure the packets are dropped at the sender?
> 
> Yes I am sending 400k messages from the app and the receiver only gets
> 341k @300 byte (which is the line rate). There is no way that the 400k get
> over the line. Also if I reduce SO_SNDBUF then both receiver and
> sender get down to 341k.
> 
> I added the output of ethtool -S at the end.
> 
> The mcast tool can be had from http://gentwo.org/ll or from my directory
> on www.kernel.org.
> 
> > Another place where packet drops/errors are counted is
> >     /proc/net/softnet_stat
> > It tracks some counters that could result in drops. I thought these are
> > all receive statistics. But looks like cpu_collision is a tx stat. The
> > name of the structure is netif_rx_stat and it includes cpu_collison
> > counter.
> 
> How do I decode that information?
  total dropped time_squeeze 0 0 0 0 0 cpu_collision

The first 3 are rx stats and the last one is a tx stat.
Anyway, only the first field(total packets received) seems to be non-zero 
in your softnet_stat output on both sender and receiver.
So it is possible that there is some other place in the stack where the packets 
are gettting dropped but not counted.

-Sridhar


