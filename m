From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] IPV6: remove addresses and routes when carrier is
 lost
Date: Tue, 3 Jun 2008 10:46:40 -0700
Message-ID: <20080603104640.21026cdb@extreme>
References: <20080603102144.571df55b@extreme>
	<20080603.102501.193702820.davem@davemloft.net>
	<20080604.022836.31952523.yoshfuji@linux-ipv6.org>
	<20080603.103059.193720094.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:36485 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753251AbYFCRqm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2008 13:46:42 -0400
In-Reply-To: <20080603.103059.193720094.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 03 Jun 2008 10:30:59 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date: Wed, 04 Jun 2008 02:28:36 +0900 (JST)
> 
> > In article <20080603.102501.193702820.davem@davemloft.net> (at Tue, 03 Jun 2008 10:25:01 -0700 (PDT)), David Miller <davem@davemloft.net> says:
> > 
> > > From: Stephen Hemminger <shemminger@vyatta.com>
> > > Date: Tue, 3 Jun 2008 10:21:44 -0700
> > > 
> > > > The patch just makes carrier_off respond the same as doing 'ip link set dev eth0 down'
> > > > (or ifconfig eth0 down). A router needs to be able to re-route when link fails.
> > > 
> > > But I can't see how this behavior makes sense for the normal desktop case
> > > and it disagrees with existing practice for many years.
> > > 
> > > If I pull out my network cable while making some adjustments in my
> > > rack, and then plug it back in, I don't expect to lose my static
> > > routes on that interface.
> > > 
> > > That doesn't make any sense at all.
> > 
> > How about ignoring routes via down interface?
> 
> Look at what happens now in my example case.  The packets simply get
> queued in the device queue until the carrier comes back up.  Once
> it comes back up, the packets go out with zero packet loss.
> 
> With your suggestion, the packets will get dropped if there are no
> other devices with active routes to the destination, which is a very
> poor quality of implementation decision in my opinion, especially for
> this case.

It is not what desktop users want, that is why it is a dynamic configuration
option via /proc/sys/net/ipv6/conf/ethX/link_detect.

But it is what a router wants. So why not allow it? Obviously, Vyatta
users expect systems behave same as Cisco.

The problem with doing it all in user space are not impossible just more difficult:
  * links bouncing lead to synchronization problems
  * existing Quagga code avoids messing with "system routes" 
  * Quagga has to be portable to Solaris/BSD etc..

More at:
http://osdir.com/ml/network.quagga.devel/2004-08/msg00009.html
