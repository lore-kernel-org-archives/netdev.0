From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC 2/2] shrink size of scatterlist on common i386/x86-64
Date: Thu, 05 Jul 2007 16:32:45 -0700
Message-ID: <adak5te2zqa.fsf@cisco.com>
References: <20070705231412.021359760@linux-foundation.org>
	<20070705231615.451797310@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:65073 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758694AbXGEXct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2007 19:32:49 -0400
In-Reply-To: <20070705231615.451797310@linux-foundation.org> (Stephen Hemminger's message of "Thu, 05 Jul 2007 16:14:14 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > --- a/include/asm-i386/scatterlist.h	2007-07-05 14:37:11.000000000 -0700
 > +++ b/include/asm-i386/scatterlist.h	2007-07-05 15:44:51.000000000 -0700
 > @@ -5,9 +5,9 @@
 >  
 >  struct scatterlist {
 >      struct page		*page;
 > -    unsigned int	offset;
 >      dma_addr_t		dma_address;
 > -    unsigned int	length;
 > +    u16			offset;
 > +    u16			length;
 >  };

Actually this struct layout could be even better, since pointers are
32 bits but dma_addr_t may be 64 bits... having

struct scatterlist {
	dma_addr_t	dma_address;
	struct page    *page;
	u16		offset;
	u16		length;
};

would allow struct scatterlist to be 16 bytes.  Seems like a good thing...

 - R.
