From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: pskb_expand_head() optimization
Date: Sun, 12 Sep 2010 08:58:33 -0700 (PDT)
Message-ID: <20100912.085833.226777368.davem@davemloft.net>
References: <20100911123140.GA1939@del.dom.local>
	<20100911.203002.193707453.davem@davemloft.net>
	<20100912104534.GA2056@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59692
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753584Ab0ILP6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Sep 2010 11:58:14 -0400
In-Reply-To: <20100912104534.GA2056@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sun, 12 Sep 2010 12:45:34 +0200

> Then a few more questions:
> 1) if doubly linked lists really require such pskb_copying, isn't it
>    all too costly?

In the common case the data reference will be one, so we will not
copy.

> 2) why skb_clone isn't enough instead of pskb_copy?

Can't share the metadata.

> 3) since skb_clone has some cost too, why e.g. saving only the pointer
>    to the tail of the list in skb_shared_info isn't enough?

Then we won't get the rest of the advantages of using list_head such
as prefetching during traversals, automatic debugging facilities, et al.
