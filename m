From: Brice Goglin <brice@myri.com>
Subject: Re: [git patches] net driver updates for .28
Date: Sat, 20 Sep 2008 09:28:24 +0200
Message-ID: <48D4A618.5080403@myri.com>
References: <20080914022236.GA15673@havoc.gtf.org> <20080920.000914.219711773.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1906 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750867AbYITH3f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Sep 2008 03:29:35 -0400
In-Reply-To: <20080920.000914.219711773.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> No, that is crap.  I didn't create the ->select_tx_queue() callback so
> that each and every damn multiqueue driver will override the generic
> TX hash function in order to try and make the TX hashing match the RX
> hashing.
>
> That's not what it's for.
>
> The callback exists for things like wireless where the queues have
> a meaning other than flow seperation.
>
> We (specifically Herbert Xu and myself) know that for routing and
> firewalling applications matching the TX queue to the same hashing
> namespace of the RX multiqueueing is desirable for best performance.
>
> But we will do that generically by allowing the driver on the receive
> side to record the RX hash used (or alternatively, if the exact RSS
> hash isn't obtainable, the RX queue index itself) and on TX we will
> use this information to select the TX queue properly.
>   

Ok, I'll resend without the select_queue stuff. But you should really
document the above explanation. The only documentation we found was
"Devices or device layers can set this to control the queue selection
performed by dev_pick_tx()." in the git-log...

Brice

