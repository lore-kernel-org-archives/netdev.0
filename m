From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: pskb_expand_head() optimization
Date: Mon, 20 Sep 2010 09:59:20 -0700 (PDT)
Message-ID: <20100920.095920.52212843.davem@davemloft.net>
References: <20100911123140.GA1939@del.dom.local>
	<20100919.171725.245378386.davem@davemloft.net>
	<20100920072149.GA6353@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38601
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753691Ab0ITQ7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 12:59:01 -0400
In-Reply-To: <20100920072149.GA6353@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 20 Sep 2010 07:21:49 +0000

> On Sun, Sep 19, 2010 at 05:17:25PM -0700, David Miller wrote:
>> We definitely don't use frag lists for performance, if you look
>> in the GRO history the GRO code specifically has been changed
>> to prefer accumulating into the page vector whenever possible
>> because using frag lists is a lot slower.
> 
> Yes, and GRO made frag lists more popular btw.

Yes.  However, realize that this is only really a legacy from
inet_lro.

These drivers could restructure themselves to operate on pages.
I am pretty sure the hardware would be amicable to this and it
would likely improve performance just as favoring page vector
accumulation did for GRO.

> Btw, I wonder what is the exact reason we can't use only
> NET_SKBUFF_DATA_USES_OFFSET?

As Eric explained, and then demonstrated, it generates a non-trivial
increased amount of code.

This is almost certainly why Arnaldo didn't make it unconditional
back when he implemented the SKB data offset changes for 64-bit.

In my opinion, this duality of SKB pointer handling never causes
real problems because any change mistakenly accessing the pointers
directly usually gets caught by the first person who builds it on
64-bit :-)
