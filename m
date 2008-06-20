From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: data received but not detected
Date: Fri, 20 Jun 2008 21:54:40 +0400
Message-ID: <20080620175440.GA12197@2ka.mipt.ru>
References: <1213740538.5771.192.camel@localhost.localdomain> <48583B37.5070708@candelatech.com> <1213743506.5771.220.camel@localhost.localdomain> <20080618062857.GA3598@2ka.mipt.ru> <1213917029.9245.86.camel@localhost.localdomain> <20080620060219.GA22784@2ka.mipt.ru> <1213981859.9245.133.camel@localhost.localdomain> <20080620172513.GA16673@2ka.mipt.ru> <1213983664.9245.150.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Travis Stratman <tstratman@emacinc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:41394 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751004AbYFTRyh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2008 13:54:37 -0400
Content-Disposition: inline
In-Reply-To: <1213983664.9245.150.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 20, 2008 at 12:41:04PM -0500, Travis Stratman (tstratman@emacinc.com) wrote:
> > Please also clarify this bit again: you see packets in tcpdump running
> > on receiving (frozen) host, but do not see them in userspace? After this
> > freeze happend system recvmsg/poll calls do not respond until some
> > activity on NIC happend? I.e. recv/poll 'unfreeze' only when something
> > is received (arp, icmp reply) or after sending too?
> 
> I see the packets being sent in tcpdump from the sending application,
> but they don't show up in the receiving side until something else comes
> in behind them. For example if you look at the client and server trace
> that I sent yesterday side by side you will see how the timings line up.
> The same packets are shown in each trace. Data needs to be received by
> the board to unlock it, sending does not seem to have any effect.

So, packets are actually received by the host, since you see them in the
receiving host tcpdump, but they do not reach socket queue. Please check
UDP_MIB_INERRORS mib. You can do that via netstat -s.

-- 
	Evgeniy Polyakov
