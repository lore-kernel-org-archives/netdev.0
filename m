From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: RE: [PATCH net-next 0/4] enic: improve rq buff allocation and reduce
 dma mapping
Date: Mon, 2 Feb 2015 23:19:31 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1502022224220.23196@ws.cisco>
References: <1422707290-939-1-git-send-email-_govind@gmx.com> <063D6719AE5E284EB5DD2968C1650D6D1CAD8FD1@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: 'Govindarajulu Varadarajan' <_govind@gmx.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ssujith@cisco.com" <ssujith@cisco.com>,
	"benve@cisco.com" <benve@cisco.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:63995 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752972AbbBBRuA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Feb 2015 12:50:00 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAD8FD1@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2 Feb 2015, David Laight wrote:
> Two questions:
> 1) How are you handling the skb's true_size ?

skb->true_size is set to ksize(data) for data allocated using alloc_page and
kmalloc. For frags we set it to size of frag. Check the function build_skb()

> 2) Memory fragmentation could easily make the allocation of 32k fail.
>

With huge memory these days order-3 allocation failure is quite rare. In my
testing on system with 8G memory I have never encountered order-3 failure.
This is probably why __netdev_alloc_frag tries order-3 page allocation first.

If order-3 page allocation fails, we drop to minimum order required for the
given size.
