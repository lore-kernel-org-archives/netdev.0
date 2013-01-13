From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [RFC davem] revert: net: Make skb->skb_iif always track skb->dev
Date: Sun, 13 Jan 2013 12:01:53 +0100
Message-ID: <50F29421.1090405@hartkopp.net>
References: <50F1699E.1000200@hartkopp.net> <20130112.132316.2121287993605534669.davem@davemloft.net> <20130112.133630.257139657732337147.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:61101 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754201Ab3AMLB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 06:01:56 -0500
In-Reply-To: <20130112.133630.257139657732337147.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12.01.2013 22:36, David Miller wrote:

> As per your problem with CAN, that's also rediculous.  You have an SKB
> control block in skb->cb[] that you can put whatever values with
> whatever semantics you want.
> 
> Use it.


I'm not writing a RFC to you, when i'm not sure having checked several options
before.

In the tx path already net/sched is using cb[] for it's purposes.
Adding the information somewhere at the end of cb[] to not interfere with
sched becomes tricky. See users of qdisc_cb_private_validate().

So the 'incoming interface index' could be stored safely in the tx path in

- skb->data
- skb_shared_info
- skb_iif

skb_iif was the obvious choice then. And the question why a seven year old
if-statement in net/core/dev.c has been removed must be allowed.

Networking is not only IP networking.

Oliver
