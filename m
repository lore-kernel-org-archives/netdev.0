From: Travis Stratman <tstratman@emacinc.com>
Subject: Re: data received but not detected
Date: Fri, 20 Jun 2008 13:17:06 -0500
Message-ID: <1213985826.9245.169.camel@localhost.localdomain>
References: <1213740538.5771.192.camel@localhost.localdomain>
	 <48583B37.5070708@candelatech.com>
	 <1213743506.5771.220.camel@localhost.localdomain>
	 <20080618062857.GA3598@2ka.mipt.ru>
	 <1213917029.9245.86.camel@localhost.localdomain>
	 <20080620060219.GA22784@2ka.mipt.ru>
	 <1213981859.9245.133.camel@localhost.localdomain>
	 <20080620172513.GA16673@2ka.mipt.ru>
	 <1213983664.9245.150.camel@localhost.localdomain>
	 <20080620175440.GA12197@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.emacinc.com ([63.245.244.68]:33051 "EHLO mail.emacinc.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750939AbYFTST2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2008 14:19:28 -0400
In-Reply-To: <20080620175440.GA12197@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-06-20 at 21:54 +0400, Evgeniy Polyakov wrote:
> > 
> > I see the packets being sent in tcpdump from the sending application,
> > but they don't show up in the receiving side until something else comes
> > in behind them. For example if you look at the client and server trace
> > that I sent yesterday side by side you will see how the timings line up.
> > The same packets are shown in each trace. Data needs to be received by
> > the board to unlock it, sending does not seem to have any effect.
> 
> So, packets are actually received by the host, since you see them in the
> receiving host tcpdump, but they do not reach socket queue. Please check
> UDP_MIB_INERRORS mib. You can do that via netstat -s.

Let me clarify this again... I see the packet being sent at the expected
time from the sender on the tcpdump. The packet does not show up in
tcpdump or in the application on the receive side. When some other data
is received by the receiver (i.e. ARP), the missing packet shows up in
the tcpdump and in the application at the same time. So the delay shows
up in the tcpdump as well. It seems to me that everything is pointing to
the packet being in the DMA buffer but the controller driver not knowing
anything about it.

netstat -s shows 0 UDP errors on both systems.

Thanks,

Travis

