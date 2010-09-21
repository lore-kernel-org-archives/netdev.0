From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlcnic: dont assume NET_IP_ALIGN is 2
Date: Tue, 21 Sep 2010 12:33:38 -0700 (PDT)
Message-ID: <20100921.123338.71122967.davem@davemloft.net>
References: <99737F4847ED0A48AECC9F4A1974A4B80F86F80270@MNEXMB2.qlogic.org>
	<1285058073.2617.73.camel@edumazet-laptop>
	<99737F4847ED0A48AECC9F4A1974A4B80F86F80278@MNEXMB2.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com, anirban.chakraborty@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46940
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755912Ab0IUTdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 15:33:18 -0400
In-Reply-To: <99737F4847ED0A48AECC9F4A1974A4B80F86F80278@MNEXMB2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Salecha <amit.salecha@qlogic.com>
Date: Tue, 21 Sep 2010 03:41:42 -0500

>> So in order to improve "throughput", you were allowing for memory
>> exhaust and freeze of the _machine_ ?
>>
> This won't lead to such problem. truesize is used for accounting only.

Yes, it will.

Do you understand that we enforce both socket-level and system-wide
networking buffer usage in the stack?  And this limiting is based
upon skb->truesize and therefore only works if skb->truesize is
accurate?

It's meant to keep people from attacking a server and consuming large
percentages of system memory with networking buffer memory such that
other tasks cannot complete successfully.

And by mis-reporting the truesize you are subverting that entirely.

This qlcnic truesize bug is a huge security hole, can't you see this
now?

