From: Balazs Scheidler <bazsi@balabit.hu>
Subject: Re: [tproxy] udp + tproxy
Date: Wed, 12 Nov 2008 20:27:10 +0100
Message-ID: <1226518030.10667.68.camel@bzorp.balabit>
References: <1226490030.31896.12.camel@sysandrey.icomswg.local>
	 <20081112185910.GA1793@sch.bme.hu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrey Luzgin <andrey@icomsw.com>, tproxy@lists.balabit.hu,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: KOVACS Krisztian <hidden@sch.bme.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from support.balabit.hu ([195.70.41.86]:49996 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752303AbYKLTs7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2008 14:48:59 -0500
In-Reply-To: <20081112185910.GA1793@sch.bme.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-11-12 at 19:59 +0100, KOVACS Krisztian wrote:
> Hi,
> 
> On sze, nov 12, 2008 at 11:40:30 +0000, Andrey Luzgin wrote:
> > Hello,
> > 
> > While I can see example of using udp on tproxy2 onto the
> > redirect-udp-recv.c
> > file, I can't find equivalent on tproxy4.
> > 
> > For getting the original destination IP, I just use setsockopt
> > IP_PKTINFO:
> > setsockopt(sd, SOL_IP, IP_PKTINFO , &flags, sizeof(flags));
> > 
> > But I don't know how to get the original destination port:
> > 
> > a) I manually defined IP_RECVORIGADDRS  to be 11273 as I find on
> > tproxy2:
> > setsockopt(sd, SOL_IP, IP_RECVORIGADDRS , &flags, sizeof(flags));
> > but the setsockopt failed.
> > 
> > b) the getsockname give me the server listening port.
> 
> 
> Since tproxy 4 (unlike tproxy 2) doesn't modify the incoming packets in
> any way you should be able to get the correct destination address by
> simply calling recvfrom() and using the source address returned by the
> kernel.
> 

This is not true, recvfrom() returns the client address and does not
return the original destination. There was a hack in 2.2 kernels, that
it could return the targeted address in the 2nd half of the "struct
sockaddr_in" structure.

But that hack was crude. 

I can only see two options to proceed with full udp proxying: accept()
support for UDP, or a recvmsg() ancillary data (IP_RECVORIGADDRS) as
above.

I'll see whether I can come up with a patch for the latter.

In Zorp we're using accept() for UDP sockets, but I doubt it could be
integrated to mainline, the other option is doable, although potentially
racy.

-- 
Bazsi


