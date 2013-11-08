From: David Miller <davem@redhat.com>
Subject: Re: [PATCH v2 net-next] inet: fix a UFO regression
Date: Fri, 08 Nov 2013 02:08:28 -0500 (EST)
Message-ID: <20131108.020828.965655576855775437.davem@redhat.com>
References: <CAMEtUuwqmUhTgeKyodGKmOxhxe23=umnfc7nouhdVrqVNnk6zQ@mail.gmail.com>
	<1383871465.9412.118.camel@edumazet-glaptop2.roam.corp.google.com>
	<1383877926.9412.145.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	hannes@stressinduktion.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5482 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752669Ab3KHHIf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Nov 2013 02:08:35 -0500
In-Reply-To: <1383877926.9412.145.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 07 Nov 2013 18:32:06 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> While testing virtio_net and skb_segment() changes, Hannes reported
> that UFO was sending wrong frames.
> 
> It appears this was introduced by a recent commit :
> 8c3a897bfab1 ("inet: restore gso for vxlan")
> 
> The old condition to perform IP frag was :
> 
> tunnel = !!skb->encapsulation;
> ...
>         if (!tunnel && proto == IPPROTO_UDP) {
> 
> So the new one should be :
> 
> udpfrag = !skb->encapsulation && proto == IPPROTO_UDP;
> ...
>         if (udpfrag) {
> 
> Initialization of udpfrag must be done before call
> to ops->callbacks.gso_segment(skb, features), as
> skb_udp_tunnel_segment() clears skb->encapsulation
> 
> (We want udpfrag to be true for UFO, false for VXLAN)
> 
> With help from Alexei Starovoitov
> 
> Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks a lot Eric.
