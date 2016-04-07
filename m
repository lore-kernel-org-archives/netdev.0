From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] udp: GRO in UDP sockets
Date: Thu, 07 Apr 2016 16:54:01 -0400 (EDT)
Message-ID: <20160407.165401.1543999509717183827.davem@davemloft.net>
References: <1459869776-2090500-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55672 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753278AbcDGUyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 16:54:03 -0400
In-Reply-To: <1459869776-2090500-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 5 Apr 2016 08:22:48 -0700

> This patch set adds GRO functions (gro_receive and gro_complete) to UDP
> sockets and removes udp_offload infrastructure.
> 
> Add GRO functions (gro_receive and gro_complete) to UDP sockets. In
> udp_gro_receive and udp_gro_complete a socket lookup is done instead of
> looking up the port number in udp_offloads.  If a socket is found and
> there are GRO functions for it then those are called. This feature
> allows binding GRO functions to more than just a port number.
> Eventually, we will be able to use this technique to allow application
> defined GRO for an application protocol by attaching BPF porgrams to UDP
> sockets for doing GRO.
> 
> In order to implement these functions, we added exported
> udp6_lib_lookup_skb and udp4_lib_lookup_skb functions in ipv4/udp.c and
> ipv6/udp.c. Also, inet_iif and references to skb_dst() were changed to
> check that dst is set in skbuf before derefencing. In the GRO path there
> is now a UDP socket lookup performed before dst is set, to the get the
> device in that case we simply use skb->dev.
> 
> Tested:
> 
> Ran various combinations of VXLAN and GUE TCP_STREAM and TCP_RR tests.
> Did not see any material regression.

Series applied thanks Tom.
