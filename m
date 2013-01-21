From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [RFC:] struct net_device_ops: Add function pointer to fill
 device specific ndisc information
Date: Mon, 21 Jan 2013 09:09:51 +0100
Message-ID: <20130121090951.103c0680@stein>
References: <50FC2EE4.3080705@gmail.com>
	<50FC3BB1.4070005@linux-ipv6.org>
	<50FC6068.3020302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev <netdev@vger.kernel.org>,
	linux1394-devel@lists.sourceforge.net,
	David Miller <davem@davemloft.net>
To: stephan.gatzka@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:48036 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803Ab3AUIKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 03:10:09 -0500
In-Reply-To: <50FC6068.3020302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 20 Stephan Gatzka wrote:
> On 01/20/2013 07:47 PM, YOSHIFUJI Hideaki wrote:
> 
> > My current position is to change "mac address" to
> >
> > struct fwnet_hwaddr {
> > 	u8	guid[8];
> > 	u8	max_rec;
> > 	u8	sspd;
> > 	u8	fifo[6];
> > };
> >
> 
> That is something I'm not really convinced of. As Stefan Richter pointed 
> out clearly, the fifo address might be different between IPv4 and IPv6 
> communication.

If it is of any help, the initial implementation could assume that IPv4
unicast_FIFO and IPv6 unicast_FIFO are the same.  RFC 3146 is silent on
this topic (which means it can be one way or the other), but from an
implementation point of view, using one FIFO offset for both seems quite
natural.  Currently the only existing RFC 3146 implementation which is
known to us is Mac OS X, and since your tests with OS X 10.6 went well,
they obviously use one offset for both protocols.

But if we actually put this assumption into the implementation now, we
should make sure that we can easily expand the implementation later in the
event that a third implementation comes across which uses separate
unicast_FIFOs.
-- 
Stefan Richter
-=====-===-= ---= =-=-=
http://arcgraph.de/sr/
