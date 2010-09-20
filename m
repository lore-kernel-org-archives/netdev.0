From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlcnic: dont assume NET_IP_ALIGN is 2
Date: Mon, 20 Sep 2010 08:58:57 -0700 (PDT)
Message-ID: <20100920.085857.98907191.davem@davemloft.net>
References: <1284700483-16397-2-git-send-email-amit.salecha@qlogic.com>
	<1284717448.3391.75.camel@edumazet-laptop>
	<99737F4847ED0A48AECC9F4A1974A4B80F86F8018D@MNEXMB2.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com, anirban.chakraborty@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34648
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752938Ab0ITP6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 11:58:38 -0400
In-Reply-To: <99737F4847ED0A48AECC9F4A1974A4B80F86F8018D@MNEXMB2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Salecha <amit.salecha@qlogic.com>
Date: Mon, 20 Sep 2010 06:16:31 -0500

> Though I have one doubt. We are allocating larger packets than the actual data used.
> Doesn't it will break accounting ?

No, it will "fix" accounting.

You must charge to the SKB all of the non-shared memory that was
allocated to the SKB.

This means even if the packet only uses 128 bytes of the SKB
data area, you must still account for the full blob of linear
memory that was allocated for the SKB data area in skb->truesize.

Otherwise remote attackers could consume enormous amounts of memory by
tricking our socket accounting via carefully sized packets.
