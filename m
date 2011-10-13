From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH net-next] net: more accurate skb truesize
Date: Thu, 13 Oct 2011 13:33:52 -0700
Message-ID: <20111013203352.GA5707@tassilo.jf.intel.com>
References: <1318519581.2393.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:58345 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751761Ab1JMUdx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Oct 2011 16:33:53 -0400
Content-Disposition: inline
In-Reply-To: <1318519581.2393.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 13, 2011 at 05:26:21PM +0200, Eric Dumazet wrote:
> skb truesize currently accounts for sk_buff struct and part of skb head.
> 
> Considering that skb_shared_info is larger than sk_buff, its time to
> take it into account for better memory accounting.
> 
> This patch introduces SKB_TRUESIZE(X) macro to centralize various
> assumptions into a single place.

It's still quite inaccurate, especially for the kmalloced data area if it's not
paged. It would be better to ask slab how much memory was really 
allocated. But at least this could be done more easily now with the new 
macro, so it's definitely a step in the right direction.

-Andi
