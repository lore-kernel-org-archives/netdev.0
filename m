From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] skbuff: update sk truesize in pskb_expand_head
Date: Sat, 15 Oct 2011 00:02:35 -0400 (EDT)
Message-ID: <20111015.000235.314539622449271332.davem@davemloft.net>
References: <1318577970-19566-1-git-send-email-roy.qing.li@gmail.com>
	<20111014.034822.2255593021765068562.davem@davemloft.net>
	<CAJFZqHyvu5419zaJ6Ro+s2d06LZ3mBqbAPuGF=3K6JAUK_vHqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50252 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764Ab1JOECh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2011 00:02:37 -0400
In-Reply-To: <CAJFZqHyvu5419zaJ6Ro+s2d06LZ3mBqbAPuGF=3K6JAUK_vHqA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: RongQing Li <roy.qing.li@gmail.com>
Date: Sat, 15 Oct 2011 11:52:22 +0800

> About incorrectly impact on socket, I am consider it, but I still no
> idea about it.

Sockets attach themselves to packets, and assign a destructor.

This destructor atomically decrements the receive or send buffer
space used, and amount decremented is skb->truesize.

Therefore if you change skb->truesize on such an SKB, the wrong
amount will be decremented when the destructor is called.

This is a very fundamental aspec of SKB handling, perhaps you should
familiarize yourself with SKBs a little bit more before modifying code
which manages them.
