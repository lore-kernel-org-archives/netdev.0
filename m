From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: gro: support sit protocol
Date: Wed, 21 Oct 2015 19:37:02 -0700 (PDT)
Message-ID: <20151021.193702.1623864743998748289.davem@davemloft.net>
References: <1445009029.25595.16.camel@edumazet-glaptop2.roam.corp.google.com>
	<1445306641.30896.42.camel@edumazet-glaptop2.roam.corp.google.com>
	<1445312417.30896.64.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hkchu@google.com, jesse@nicira.com, tom@herbertland.com,
	netdev@vger.kernel.org, kernel-team@fb.com, linux@stwm.de,
	herbert@gondor.apana.org.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49985 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756326AbbJVCUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 22:20:37 -0400
In-Reply-To: <1445312417.30896.64.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 19 Oct 2015 20:40:17 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Tom Herbert added SIT support to GRO with commit
> 19424e052fb4 ("sit: Add gro callbacks to sit_offload"),
> later reverted by Herbert Xu.
> 
> The problem came because Tom patch was building GRO
> packets without proper meta data : If packets were locally
> delivered, we would not care.
> 
> But if packets needed to be forwarded, GSO engine was not
> able to segment individual segments.
> 
> With the following patch, we correctly set skb->encapsulation
> and inner network header. We also update gso_type.
> 
> Tested:
 ...
> Checked on server traffic copied on dummy0 and verify segments were
> properly rebuilt, with proper IP headers, TCP checksums...
> 
> tcpdump on eth0 shows proper GRO aggregation takes place.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
