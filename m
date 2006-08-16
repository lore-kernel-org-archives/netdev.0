From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to
	use rtnl_notify()
Date: Wed, 16 Aug 2006 08:36:31 -0400
Message-ID: <1155731791.5122.115.camel@jzny2>
References: <20060815122300.GV14627@postel.suug.ch>
	 <E1GDBbw-0006Kz-00@gondolin.me.apana.org.au>
	 <20060816105856.GW14627@postel.suug.ch>
	 <20060816111240.GA28846@gondor.apana.org.au>
	 <20060816113950.GA29003@gondor.apana.org.au>
	 <1155729864.5122.95.camel@jzny2>  <20060816120808.GA14627@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, hasso@estpak.ee,
	kuznet@ms2.inr.ac.ru, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:27084 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1751149AbWHPMgq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 08:36:46 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GDKdc-0005kr-4Y
	for netdev@vger.kernel.org; Wed, 16 Aug 2006 08:36:48 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060816120808.GA14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-16-08 at 14:08 +0200, Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-08-16 08:04
> > current->pid i think is coming out to be a bad idea. Thomas' patches
> > revert it out. Again this has everything to do with the original idea
> > what maps to pid now changing to socketid.
> 
> It probably developed from autobind using current->tid.

In one conversation with Alexey he told me there was some inspiration
from pfkey in the semantics of it i.e processid. Obviously with many
sockets on the same process etc, that assumption is no longer valid. 

On Wed, 2006-16-08 at 22:08 +1000, Herbert Xu wrote: 
> On Wed, Aug 16, 2006 at 08:04:24AM -0400, jamal wrote:
> > 
> > What do you think of the idea of infact rewriting the pid to be that of
> > the socket id?
> 
> Rewriting it with the netlink socket address? That's fine by me as
> long as there is a clear 1-to-1 relationship between the request
> and the notification.

you would have to call getpeername() to get a correct 1-1 mapping as is 
today when in doubt.
What i was suggesting is notifications using the pid that would id the socket and
would therefore require a getpeername() which identify the real socket it came 
from; if you are fine with what Thomas is doing, then this unnecessary since i was
suggesting it as a compromise for consistency you pointed was lacking.

cheers,
jamal

