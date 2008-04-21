From: David Miller <davem@davemloft.net>
Subject: Re: [6/6] [VIRTIO] net: Allow receiving SG packets
Date: Mon, 21 Apr 2008 13:04:18 -0700 (PDT)
Message-ID: <20080421.130418.01258045.davem@davemloft.net>
References: <20080418032142.GD18071@gondor.apana.org.au>
	<20080418032427.GE18071@gondor.apana.org.au>
	<200804220506.16887.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org,
	herbert@gondor.apana.org.au, virtualization@lists.osdl.org,
	netdev@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43686
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755875AbYDUUEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 16:04:16 -0400
In-Reply-To: <200804220506.16887.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Tue, 22 Apr 2008 05:06:16 +1000

> I'm not sure what the right number is here.  Say worst case is header which 
> goes over a page boundary then MAX_SKB_FRAGS in the skb, but for some reason 
> that already has a +2:
> 
> /* To allow 64K frame to be packed as single skb without frag_list */
> #define MAX_SKB_FRAGS (65536/PAGE_SIZE + 2)
> 
> Unless someone explains, I'll change the xmit sg to 2+MAX_SKB_FRAGS as well.

MAX_SKB_FRAGS + 1 is what you ought to need.

MAX_SKB_FRAGS is only accounting for the skb frag pages.
If you want to know how many segments skb->data might
consume as well, you have to add one.

skb->data is linear, therefore it's not possible to need
more than one scatterlist entry for it.
