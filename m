From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH] apply cwnd rules to FIN packets with data
Date: Mon, 05 Feb 2007 18:02:19 -0500
Message-ID: <45C7B77B.9060506@psc.edu>
References: <45C7A87A.5050200@psc.edu> <20070205.145615.92339659.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:59470 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965017AbXBEXPL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 18:15:11 -0500
In-Reply-To: <20070205.145615.92339659.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: John Heffner <jheffner@psc.edu>
> Date: Mon, 05 Feb 2007 16:58:18 -0500
> 
>> This is especially important with TSO enabled.  Currently, it will send 
>> a burst of up to 64k at the end of a connection, even when cwnd is much 
>> smaller than 64k.  This patch still lets out empty FIN packets, but does 
>> not apply the special case to FINs carrying data.
> 
> Good catch John.
> 
> But I think the correct test on skb->len would be to just make
> sure that it is <= REAL_MSS.
> 
> What do you think about that?  This would match the original intention
> of the logic in the pre-TSO days.

What was the intention of that logic?

Actually, I think it would be better to leave the Nagle test as it was 
(which is implicitly < real_mss), because there is obviously no point in 
doing the nagle test when you know there is no more data that will be 
sent.  However, I can't think of any reason why the cwnd test should not 
apply.

   -John
