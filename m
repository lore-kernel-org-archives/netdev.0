From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 3/3] [UDP6]: Counter increment on BH mode
Date: Mon, 03 Dec 2007 15:19:35 +0800
Message-ID: <4753AE07.1040906@cn.fujitsu.com>
References: <474F7EE8.2040009@cn.fujitsu.com> <474F8255.5060501@cn.fujitsu.com> <20071130111949.GB28277@gerrit.erg.abdn.ac.uk> <20071201015438.GC26895@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>, davem@davemloft.net,
	andi@firstfloor.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:63850 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751008AbXLCHWe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2007 02:22:34 -0500
In-Reply-To: <20071201015438.GC26895@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu said the following on 2007-12-1 9:54:
> On Fri, Nov 30, 2007 at 11:19:49AM +0000, Gerrit Renker wrote:
>> |  csum_copy_err:
>> | -	UDP6_INC_STATS_USER(UDP_MIB_INERRORS, is_udplite);
>> | +	UDP6_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);
>> |  	skb_kill_datagram(sk, skb, flags);
>> |  
>> |  	if (flags & MSG_DONTWAIT)
>> | 
>> Is it not the other way round ?? :- 
> 
> I agree.  Wang Chen, please change this and other appropriate
> BH calls to USER.  Basically recvmsg should always be USER while
> rcv is BH.
> 

Resubmit the patch.

System calls should be USER. So change the BH to USER for
UDP*_INC_STATS_BH().

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 ipv4/udp.c |    4 ++--
 ipv6/udp.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

--- linux-2.6.24.rc3.org/net/ipv4/udp.c	2007-12-03 15:10:49.000000000 +0800
+++ linux-2.6.24.rc3/net/ipv4/udp.c	2007-12-03 14:52:54.000000000 +0800
@@ -874,7 +874,7 @@ try_again:
 	if (err)
 		goto out_free;
 
-	UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS, is_udplite);
+	UDP_INC_STATS_USER(UDP_MIB_INDATAGRAMS, is_udplite);
 
 	sock_recv_timestamp(msg, sk, skb);
 
@@ -899,7 +899,7 @@ out:
 	return err;
 
 csum_copy_err:
-	UDP_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);
+	UDP_INC_STATS_USER(UDP_MIB_INERRORS, is_udplite);
 
 	skb_kill_datagram(sk, skb, flags);
 
--- linux-2.6.24.rc3.org/net/ipv6/udp.c	2007-12-03 15:10:49.000000000 +0800
+++ linux-2.6.24.rc3/net/ipv6/udp.c	2007-12-03 15:09:55.000000000 +0800
@@ -164,7 +164,7 @@ try_again:
 	if (err)
 		goto out_free;
 
-	UDP6_INC_STATS_BH(UDP_MIB_INDATAGRAMS, is_udplite);
+	UDP6_INC_STATS_USER(UDP_MIB_INDATAGRAMS, is_udplite);
 
 	sock_recv_timestamp(msg, sk, skb);

