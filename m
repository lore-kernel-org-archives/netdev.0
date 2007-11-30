From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 3/3] [UDP6]: Counter increment on BH mode
Date: Fri, 30 Nov 2007 11:19:49 +0000
Message-ID: <20071130111949.GB28277@gerrit.erg.abdn.ac.uk>
References: <474F7EE8.2040009@cn.fujitsu.com> <474F8255.5060501@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	andi@firstfloor.org, netdev@vger.kernel.org
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:56347 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755306AbXK3LUr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 06:20:47 -0500
Content-Disposition: inline
In-Reply-To: <474F8255.5060501@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Wang Chen:
| (This patch base on "PATCH 2/3".)
| 
| UDP_MIB_INERRORS increment is in different way for IPv4
| and IPv6. For the consistence, change UDP6_INC_STATS_USER
| to UDP6_INC_STATS_BH.
| 
| Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
| ---
|  udp.c |    2 +-
|  1 files changed, 1 insertion(+), 1 deletion(-)
| 
| --- linux-2.6.24.rc3.org/net/ipv6/udp.c	2007-11-30 10:38:36.000000000 +0800
| +++ linux-2.6.24.rc3/net/ipv6/udp.c	2007-11-30 10:39:01.000000000 +0800
| @@ -207,7 +207,7 @@ out:
|  	return err;
|  
|  csum_copy_err:
| -	UDP6_INC_STATS_USER(UDP_MIB_INERRORS, is_udplite);
| +	UDP6_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);
|  	skb_kill_datagram(sk, skb, flags);
|  
|  	if (flags & MSG_DONTWAIT)
| 
Is it not the other way round ?? :- 

	struct proto udp{,v6}_prot = {
		// ...
		.recvmsg           = udp{,v6}_recvmsg,
	};

