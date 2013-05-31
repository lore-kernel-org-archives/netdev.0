From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: RFC - VXLAN port range facility
Date: Fri, 31 May 2013 14:19:47 -0400
Message-ID: <OF5DED87DF.8E295C17-ON85257B7C.0061E7B1-85257B7C.0064B099@us.ibm.com>
References: <OF673FF136.10B22631-ON85257B7B.00436301-85257B7B.0045AAB7@us.ibm.com>	<20130530094141.7c125947@nehalam.linuxnetplumber.net>
	<OFD5BD589B.1842E46B-ON85257B7B.00610E03-85257B7B.0062F480@us.ibm.com>	<20130531091338.12fc7df5@nehalam.linuxnetplumber.net>
	<OF19ABC0E6.77100D83-ON85257B7C.005AFB01-85257B7C.005E33DC@us.ibm.com> <20130531102233.13e51cff@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:48815 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985Ab3EaSUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 14:20:20 -0400
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Fri, 31 May 2013 12:20:19 -0600
In-Reply-To: <20130531102233.13e51cff@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> wrote on 05/31/2013 
01:22:33 PM:

> > Now, maybe it wouldn't kill performance, and so doing a bind/unbind 
per
> > packet is still an option, but that would definitely hurt performance
> > for people who don't actually care about port entropy.
> 
> What about a peek operation that just avoids existing ports.

        That sounds like an excellent idea to me. But anything per-packet
interacting with other parts of the kernel has potential to be slow.
My concern there, if it is noticeably slower, is that someone who
doesn't need the entropy should not pay the penalty for it. So, if
whatever we do per-packet to ensure we're using unbound UDP ports
slows it down, I think we'd want a knob of some sort to allow just
using a pre-bound port or (smaller) set of ports, since those don't
require any per-packet checks.
        But absolutely, if we just do the port lookup and rehash if
the port is in use, even without actually binding, I think that would
work well; we wouldn't cause any troubles for long-term UDP bound
sockets and other emphemeral ports can get stray traffic from prior
use already.

                                                                +-DLS
