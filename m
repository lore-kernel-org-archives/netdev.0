From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Tue, 22 May 2007 16:04:37 -0700 (PDT)
Message-ID: <20070522.160437.48528737.davem@davemloft.net>
References: <20070522.153636.115911096.davem@davemloft.net>
	<OFCF3EB7F8.9740C0C7-ON872572E3.007DADF6-882572E3.007E0E7B@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, herbert@gondor.apana.org.au, krkumar2@in.ibm.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	rdreier@cisco.com
To: xma@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47661
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756173AbXEVXEf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 19:04:35 -0400
In-Reply-To: <OFCF3EB7F8.9740C0C7-ON872572E3.007DADF6-882572E3.007E0E7B@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shirley Ma <xma@us.ibm.com>
Date: Tue, 22 May 2007 15:58:05 -0700

> Sorry for the confusion. I am thinking to avoid copy in skb_segment() for
> GSO. The way could be in tcp_sendmsg() to allocate small discontiguous
> buffers (equal = MTU) instead of allocating pages.

The SKB splitting algorithm in TCP's transmit engine depends upon the
skb_shared_info() array being splittable at arbitrary points with only
page counts to manage.  This is the only way I found to make SKB
splitting at transmit time extremely inexpensive.

SACK block processing needs to perform these kinds of splits
at well, so it really really has to be cheap.

The invariant is that every TCP TSO packet must have it's header
at skb->data and all of it's data in the paged skb_shared_info().
