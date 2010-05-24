From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ipv6: Store ndisc_nodeid in IP6CB().
Date: Sun, 23 May 2010 23:58:58 -0700 (PDT)
Message-ID: <20100523.235858.262775026.davem@davemloft.net>
References: <20100519.195536.32704411.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@redhat.com, nhorman@tuxdriver.com, nhorman@redhat.com,
	eric.dumazet@gmail.com, herbert@gondor.hengli.com.au,
	netdev@vger.kernel.org
To: bmb@athenacr.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38553
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755860Ab0EXG6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 02:58:48 -0400
In-Reply-To: <20100519.195536.32704411.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 19 May 2010 19:55:36 -0700 (PDT)

> 
> There is no reason we need to use up space in the generic
> SKB area for this.  All packet input paths in ipv6 explicitly
> clear out the IP6CB() area and therefore the default value
> for ndisc_nodeid will be correct.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

Turns out the patch doesn't build, because it throws the
DCCP control block beyond the skb->cb[] size of 48 bytes
with ipv6 enabled on 64-bit.

Ho hum...
