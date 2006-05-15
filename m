From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] changing value of NETDEV_ALIGN to cacheline size
Date: Mon, 15 May 2006 14:39:23 -0700
Message-ID: <4468F50B.9000102@hp.com>
References: <200605151408.29688.borntrae@de.ibm.com>	<20060515080258.bdcfba5f.rdunlap@xenotime.net> <20060515.143011.36635008.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rdunlap@xenotime.net, borntrae@de.ibm.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:26547 "EHLO palrel11.hp.com")
	by vger.kernel.org with ESMTP id S964859AbWEOVjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 17:39:41 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060515.143011.36635008.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> From: "Randy.Dunlap" <rdunlap@xenotime.net>
> Date: Mon, 15 May 2006 08:02:58 -0700
> 
> 
>>>-#define	NETDEV_ALIGN		32
>>>+#define	NETDEV_ALIGN		L1_CACHE_BYTES
>>> #define	NETDEV_ALIGN_CONST	(NETDEV_ALIGN - 1)
>>
>>I don't know about the fixed value of 32, but if this patch is
>>accepted, I'd prefer NETDEV_ALIGN_MASK instead of NETDEV_ALIGN_CONST.
> 
> 
> The reason it's 32 is that old drivers depended on the
> struct being at least 32-byte aligned because they would
> embed structures DMA'd to/from the card in their private
> area and just assumed that would be aligned enough for
> the card's restrictions.
> 
> So setting it to L1_CACHE_BYTES would be wrong, because if
> that happens to be less than 32 it would violate said
> assumption which we are catering to.

How about:

#define NETDEV_ALIGN_MIN 32
#if L1_CACHE_BYTES > NETDEV_ALIGN_MIN
# define NETDEV_ALIGN L1_CACHE_BYTES
#else
# define NETDEV_ALIGN NETDEV_ALIGN_MIN
#endif

rick jones
