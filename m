From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 19:48:04 +0400
Message-ID: <20070510154804.GA17474@2ka.mipt.ru>
References: <20070510150833.GB24898@2ka.mipt.ru> <OF305F038C.A48D4C37-ON652572D7.00538ECA-652572D7.00546E39@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:56744 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754584AbXEJPsM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 11:48:12 -0400
Content-Disposition: inline
In-Reply-To: <OF305F038C.A48D4C37-ON652572D7.00538ECA-652572D7.00546E39@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 10, 2007 at 08:52:12PM +0530, Krishna Kumar2 (krkumar2@in.ibm.com) wrote:
> > > The reason to implement the same was to speed up IPoIB driver. But
> > > before doing that, a proof of concept for E1000/AMSO drivers was
> > > considered (as most of the code is generic) before implementing for
> > > IPoIB. I do not have test results at this time but I am working on it.
> > >
> > > Please let me know if this approach is acceptable, or any suggestions.
> >
> > Doesn't it looks exactly like GSO/TSO/LRO stuff implemented already?
> 
> It is the reverse - GSO will segment one super-packet just before calling
> the driver so that the stack is traversed only once. In my case, I am
> trying to send out multiple skbs, possibly small packets, in one shot.
> GSO will not help for small packets.

And you can create that packet yourself, if it not enough to combine
into MSS sized chunk.

> > Btw, main CPU limiting factor here is syscall overhead (userspace
> protocol
> > processing with 1500 MTU allows to reduce CPU usage and increase
> > performance for 128 bytes packets sending/receiving total of 10 times).
> 
> I will test this also. But I was curious to see if without any changes to
> applications, I can get better performance by linking packets and sending
> it once to the driver.

Without changes it will unlikely to be visible.

> What is your opinion ?

IMHO if you do not see in profile anything related to driver's xmit
function, it does not require to be fixed. But as starting point, why
just not increase skb allocation size (say twice) in tcp_sendmsg() and
see results? It of course can endup with worse behaviour (if mtu is
small), but it is noticebly simpler to implement and test first.

> thanks,
> 
> - KK
> 
> >
> > > Thanks,
> > >
> > > - KK
> >
> > --
> >    Evgeniy Polyakov

-- 
	Evgeniy Polyakov
