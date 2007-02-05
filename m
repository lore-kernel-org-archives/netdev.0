From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] apply cwnd rules to FIN packets with data
Date: Mon, 05 Feb 2007 15:08:15 -0800 (PST)
Message-ID: <20070205.150815.112291591.davem@davemloft.net>
References: <45C7A87A.5050200@psc.edu>
	<20070205.145615.92339659.davem@davemloft.net>
	<45C7B77B.9060506@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53300
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S964934AbXBEXIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 18:08:16 -0500
In-Reply-To: <45C7B77B.9060506@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Mon, 05 Feb 2007 18:02:19 -0500

> David Miller wrote:
> > From: John Heffner <jheffner@psc.edu>
> > Date: Mon, 05 Feb 2007 16:58:18 -0500
> > 
> >> This is especially important with TSO enabled.  Currently, it will send 
> >> a burst of up to 64k at the end of a connection, even when cwnd is much 
> >> smaller than 64k.  This patch still lets out empty FIN packets, but does 
> >> not apply the special case to FINs carrying data.
> > 
> > Good catch John.
> > 
> > But I think the correct test on skb->len would be to just make
> > sure that it is <= REAL_MSS.
> > 
> > What do you think about that?  This would match the original intention
> > of the logic in the pre-TSO days.
> 
> What was the intention of that logic?

Because a packet is a packet is a packet.

If we let a FIN out it's basically equivalent to a FIN+data
as far as the routers are concerned.  Either they will drop
the packet or they won't.  And they will do this regardless
of whether data is attached to the FIN.

Getting FINs out fast is important for another reason, the
faster the session closes the faster "smart" intermediate
routers can teardown cached routing or firewall tracking
entries for the flow.

> Actually, I think it would be better to leave the Nagle test as it was 
> (which is implicitly < real_mss), because there is obviously no point in 
> doing the nagle test when you know there is no more data that will be 
> sent.

True.

> However, I can't think of any reason why the cwnd test should not 
> apply.

Care to elaborate here?  You can view the FIN special case as an off
by one error in the CWND test, it's not going to melt the internet.
:-)
