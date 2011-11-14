From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 2/2] bnx2x: uses build_skb() in receive path
Date: Mon, 14 Nov 2011 16:21:27 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AEC2@saturn3.aculab.com>
References: <1321286734.2272.48.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	"Tom Herbert" <therbert@google.com>,
	"Jamal Hadi Salim" <hadi@mojatatu.com>,
	"Stephen Hemminger" <shemminger@vyatta.com>,
	"Thomas Graf" <tgraf@infradead.org>,
	"Herbert Xu" <herbert@gondor.apana.org.au>,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>,
	<pstaszewski@itcare.pl>, <eilong@broadcom.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:57417 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750696Ab1KNQXU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 11:23:20 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 27691-10 for <netdev@vger.kernel.org>;
 Mon, 14 Nov 2011 16:23:09 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1321286734.2272.48.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> bnx2x uses following formula to compute its rx_buf_sz :
> 
> dev->mtu + 2*L1_CACHE_BYTES + 14 + 8 + 8 + 2
> 
> Then core network adds NET_SKB_PAD and SKB_DATA_ALIGN(sizeof(struct
> skb_shared_info))
> 
> Final allocated size for skb head on x86_64 (L1_CACHE_BYTES = 64,
> MTU=1500) : 2112 bytes : SLUB/SLAB round this to 4096 bytes.
> 
> Since skb truesize is then bigger than SK_MEM_QUANTUM, we have lot of
> false sharing because of mem_reclaim in UDP stack.
> 
> One possible way to half truesize is to reduce the need by 64 bytes
> (2112 -> 2048 bytes)

Would seem to be worth trying to reduce the size for systems
where the L1 caches lines are 128 bytes - I think that includes
some of the large ppc systems.

If the alignment of the malloced memory can't be assumed/forced
maybe one of the sub-structures could be dynamically placed
before the data buffer?

	David
