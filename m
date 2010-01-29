From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH net-next-2.6] packet: Add GSO/checksum offload support
 to af_packet sockets
Date: Fri, 29 Jan 2010 14:30:49 -0800
Message-ID: <4B636199.7080708@us.ibm.com>
References: <1264537819.24933.122.camel@w-sridhar.beaverton.ibm.com> <20100129085343.GB23140@gondor.apana.org.au> <1264800308.15980.395.camel@w-sridhar.beaverton.ibm.com> <20100129213619.GA6404@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:48301 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750919Ab0A2Wb2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 17:31:28 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e7.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o0TMOaw7022502
	for <netdev@vger.kernel.org>; Fri, 29 Jan 2010 17:24:36 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0TMVIGJ054348
	for <netdev@vger.kernel.org>; Fri, 29 Jan 2010 17:31:18 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0TMVHZd000940
	for <netdev@vger.kernel.org>; Fri, 29 Jan 2010 17:31:17 -0500
In-Reply-To: <20100129213619.GA6404@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/29/2010 1:36 PM, Herbert Xu wrote:
> On Fri, Jan 29, 2010 at 01:25:08PM -0800, Sridhar Samudrala wrote:
>    
>> This check is to dis-allow processing of packets with virtio_net_hdr
>> destined for non-ethernet devices.
>> Is it OK if i add a check in packet_bind() to not allow binding to
>> a non-ethernet device when PACKET_VNET_HDR option is set?
>>
>> I need to figure out a way to set the skb protocol correctly based
>> on the packet. Any clues?
>>      
> IMHO the skb protocol should be set by whatever is invoking the
> sendmsg call.  After all they would know what the L2 header is
> and should be able to deduce the protocol correctly.
>    
In this use-case, the component that is calling sendmsg() can be either 
the vhost-net in host kernel
or qemu. They get the buffer including the L2 header from the guest. 
They too need to parse the L2
header to find the protocol.
The packet itself originates from the guest virtio-net driver. but when 
it converts the skb to a virtio-ring
buffer, some of the information in the skb(including protocol and vlan 
info etc) is lost. I guess if we could
re-design, virtio_net_hdr would include this info too. But i think it is 
too late to make any such changes.
So either the callers of sendmsg() or packet_snd() need to parse the L2 
header to get the protocol and
vlan info etc. sendmsg() caller could fill in the protocol, but not the 
vlan info.

Thanks
Sridhar

