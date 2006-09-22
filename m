From: David Miller <davem@davemloft.net>
Subject: Re: IP fragmentation bug from NFS
Date: Fri, 22 Sep 2006 13:50:54 -0700 (PDT)
Message-ID: <20060922.135054.09947776.davem@davemloft.net>
References: <20060922133512.01a9e9d0@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:58529
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750775AbWIVUug (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Sep 2006 16:50:36 -0400
To: shemminger@osdl.org
In-Reply-To: <20060922133512.01a9e9d0@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 22 Sep 2006 13:35:12 -0700

> http://bugzilla.kernel.org/show_bug.cgi?id=7018
>
> Looking at this, it seems that when NFS hands UDP a fragmented
> (non-linear skb), it traps because it tries to trim bytes off a
> non-linear skb. Not sure if skb_trim needs fixing, or IP is broken..

Should be fixed by: e9fa4f7bd291c29a785666e2fa5a9cf3241ee6c3

[INET]: Use pskb_trim_unique when trimming paged unique skbs

The IPv4/IPv6 datagram output path was using skb_trim to trim paged
packets because they know that the packet has not been cloned yet
(since the packet hasn't been given to anything else in the system).

This broke because skb_trim no longer allows paged packets to be
trimmed.  Paged packets must be given to one of the pskb_trim functions
instead.

This patch adds a new pskb_trim_unique function to cover the IPv4/IPv6
datagram output path scenario and replaces the corresponding skb_trim
calls with it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
