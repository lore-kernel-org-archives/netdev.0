From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: Limit mtu to 65572 bytes
Date: Thu, 10 Apr 2014 20:14:50 -0700
Message-ID: <1397186090.16584.82.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5345A2B3.7040602@gmail.com>
	 <1397079665.16584.17.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140409223546.GH27255@order.stressinduktion.org>
	 <1397090170.16584.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140410235459.GK27255@order.stressinduktion.org>
	 <1397176824.16584.52.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1397180530.16584.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <534753D4.6070600@linux-ipv6.org>
	 <20140411025707.GM27255@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>,
	Francois WELLENREITER <f.wellenreiter@gmail.com>,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:60250 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754798AbaDKDOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 23:14:52 -0400
Received: by mail-pd0-f176.google.com with SMTP id r10so4707957pdi.35
        for <netdev@vger.kernel.org>; Thu, 10 Apr 2014 20:14:51 -0700 (PDT)
In-Reply-To: <20140411025707.GM27255@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-04-11 at 04:57 +0200, Hannes Frederic Sowa wrote:
> On Fri, Apr 11, 2014 at 11:30:44AM +0900, YOSHIFUJI Hideaki wrote:
> > Eric Dumazet wrote:
> > 
> > > We must limit the IPv6 MTU to (65535 + 40) bytes in theory.
> > > 
> > > In practice, its better to align to a multiple of 4 for optimal TCP
> > > performance.
> > 
> > It is a TCP issue.  We should not limit the mtu to 65532+40.
> > I am for 65535+40. Otherwise, other protocol such as UDP cannot
> > use full mtu as before.
> 
> I have not seen problems with max ipv6 mtu limit of 65535+40 and tcp.
> 
> I agree this would be a better approach, and maybe & ~3 the mtu/mss
> in tcp code? I assume people expect maximum udp packet sizes working
> over loopback?

Yes, recent Intel cpus have really fast mem copy, even with different
alignments for source/dest.

But old cpus or other arches might have an issue here. Apparently nobody
really cares, so I wont argue and send a V2.
