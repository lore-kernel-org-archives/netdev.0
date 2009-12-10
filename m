From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH] net: export the number of times the recv queue was full
Date: Thu, 10 Dec 2009 16:52:27 -0500
Message-ID: <1260481947.2784.33.camel@localhost>
References: <20091210210920.6820.12664.stgit@paris.rdu.redhat.com>
	 <4B216A61.7020704@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27737 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761738AbZLJVyI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Dec 2009 16:54:08 -0500
In-Reply-To: <4B216A61.7020704@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-12-10 at 13:38 -0800, Rick Jones wrote:
> Eric Paris wrote:
> > We got a request in which a customer was trying to determine how often their
> > recieve queue was full and thus they were sending a zero window back to the
> > other side.  By the time they would notice the slowdowns they would have all
> > empty receive queues and wouldn't know which socket was a problem. 
> 
> Wouldn't a tcpdump command with suitable filter expression on the window field 
> of the TCP header do?

It could as a post processing measure be used to find this situation.  I
believe they want a more 'on the fly' method.

> > It also
> > allows them to find the sockets in which they need to up the recv queue size
> > rather than doing it for all sockets across the box. 
> 
> Doesn't Linux by default "autotune" the socket buffers? (Or perhaps is that how 
> they got zero windows from time to time anyway?)
> 
> Or does this customer's application(s) bypass that by making explicit 
> setsockopt() calls, and presumably have a way to tell the application(s) on a 
> destination by destination basis which connections to increase?

I believe their intent is to explicitly set the size larger for the
sockets they learn that their application needs it for and smaller for
those it knows it doesn't.

> More generically, zero window means the application isn't calling read/recv fast 
> enough right?  Or is it "known" that the traffic the applcation is receiving is 
> bursty and this isn't a sustained overload situation?

My understanding it that that is correct, it is not a sustained load
situation so looking at the rx-queue after the fact is useless for
discovering where they are getting overloaded.

