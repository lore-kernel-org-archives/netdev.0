From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCH] qlcnic: dont assume NET_IP_ALIGN is 2
Date: Tue, 21 Sep 2010 03:19:21 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80F86F80270@MNEXMB2.qlogic.org>
References: <1284700483-16397-2-git-send-email-amit.salecha@qlogic.com>
	<1284717448.3391.75.camel@edumazet-laptop>
	<99737F4847ED0A48AECC9F4A1974A4B80F86F8018D@MNEXMB2.qlogic.org>
 <20100920.085857.98907191.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:17385 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756346Ab0IUIT1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 04:19:27 -0400
In-Reply-To: <20100920.085857.98907191.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, September 20, 2010 9:29 PM
> To: Amit Salecha
> Cc: eric.dumazet@gmail.com; netdev@vger.kernel.org; Ameen Rahman;
> Anirban Chakraborty
> Subject: Re: [PATCH] qlcnic: dont assume NET_IP_ALIGN is 2
> 
> From: Amit Salecha <amit.salecha@qlogic.com>
> Date: Mon, 20 Sep 2010 06:16:31 -0500
> 
> > Though I have one doubt. We are allocating larger packets than the
> actual data used.
> > Doesn't it will break accounting ?
> 
> No, it will "fix" accounting.
> 
> You must charge to the SKB all of the non-shared memory that was
> allocated to the SKB.
> 
> This means even if the packet only uses 128 bytes of the SKB
> data area, you must still account for the full blob of linear
> memory that was allocated for the SKB data area in skb->truesize.
> 
> Otherwise remote attackers could consume enormous amounts of memory by
> tricking our socket accounting via carefully sized packets.

Wont this affect throughput ?
As problem discuss in this thread http://www.mail-archive.com/netdev@vger.kernel.org/msg06848.html, it can affect tcp window scaling.

-Amit
