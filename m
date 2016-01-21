From: David Miller <davem@davemloft.net>
Subject: Re: Optimizing instruction-cache, more packets at each stage
Date: Thu, 21 Jan 2016 10:54:01 -0800 (PST)
Message-ID: <20160121.105401.1793719917762270884.davem@davemloft.net>
References: <1453330945.1223.329.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S34H67o64q3YoYiHQ+VSSuSsuSjBXmexSSXF_Hq8fcN0iw@mail.gmail.com>
	<20160121122730.6330a84b@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, eric.dumazet@gmail.com, gerlitz.or@gmail.com,
	edumazet@google.com, netdev@vger.kernel.org,
	alexander.duyck@gmail.com, alexei.starovoitov@gmail.com,
	borkmann@iogearbox.net, marek@cloudflare.com,
	hannes@stressinduktion.org, fw@strlen.de, pabeni@redhat.com,
	john.r.fastabend@intel.com, amirva@gmail.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46165 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752442AbcAUSyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 13:54:02 -0500
In-Reply-To: <20160121122730.6330a84b@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 21 Jan 2016 12:27:30 +0100

> eth_type_trans() does two things:
> 
> 1) determine skb->protocol
> 2) setup skb->pkt_type = PACKET_{BROADCAST,MULTICAST,OTHERHOST}
> 
> Could the HW descriptor deliver the "proto", or perhaps just some bits
> on the most common proto's?
> 
> The skb->pkt_type don't need many bits.  And I bet the HW already have
> the information.  The BROADCAST and MULTICAST indication are easy.  The
> PACKET_OTHERHOST, can be turned around, by instead set a PACKET_HOST
> indication, if the eth->h_dest match the devices dev->dev_addr (else a
> SW compare is required).
> 
> Is that doable in hardware?

I feel like we've had this discussion before several years ago.

I think having just the protocol value would be enough.

skb->pkt_type we could deal with by using always an accessor and
evaluating it lazily.  Nothing needs it until we hit ip_rcv() or
similar.
