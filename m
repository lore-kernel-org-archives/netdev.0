From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH net-next-2.6] packet: Add GSO/checksum offload support
 to af_packet sockets
Date: Fri, 29 Jan 2010 13:25:08 -0800
Message-ID: <1264800308.15980.395.camel@w-sridhar.beaverton.ibm.com>
References: <1264537819.24933.122.camel@w-sridhar.beaverton.ibm.com>
	 <20100129085343.GB23140@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:39734 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752709Ab0A2VZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 16:25:20 -0500
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e31.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o0TLH6Nr007460
	for <netdev@vger.kernel.org>; Fri, 29 Jan 2010 14:17:06 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0TLPB01034608
	for <netdev@vger.kernel.org>; Fri, 29 Jan 2010 14:25:15 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0TLP9rI005176
	for <netdev@vger.kernel.org>; Fri, 29 Jan 2010 14:25:11 -0700
In-Reply-To: <20100129085343.GB23140@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-01-29 at 21:53 +1300, Herbert Xu wrote:
> On Tue, Jan 26, 2010 at 12:30:19PM -0800, Sridhar Samudrala wrote:
> >
> > +	if (po->vnet_hdr) {
> > +		err = -EINVAL;
> > +		if (dev->type != ARPHRD_ETHER)
> > +			goto out_unlock;
> 
> We shouldn't have Ethernet-specific code in AF_PACKET.  What's
> more, just because the device type is Ethernet it doesn't mean
> that the packet is going to have an Ethernet header.

This check is to dis-allow processing of packets with virtio_net_hdr
destined for non-ethernet devices.
Is it OK if i add a check in packet_bind() to not allow binding to
a non-ethernet device when PACKET_VNET_HDR option is set?

I need to figure out a way to set the skb protocol correctly based
on the packet. Any clues?
Michael has posted a prototype patch that addresses this. Do you 
agree with this approach?
   http://lkml.org/lkml/2010/1/6/56

Did you get a chance to look at my other patch that adds a check
for VLAN packets in skb_gso_segment() to address a bug when sending
large VLAN packets from a guest?
  http://thread.gmane.org/gmane.linux.network/150198

Thanks
Sridhar

