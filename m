From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] Fixing up TCP/UDP checksum for UDP encap. ESP4
 packets in transport mode
Date: Sun, 17 May 2009 15:51:22 -0700 (PDT)
Message-ID: <20090517.155122.63991120.davem@davemloft.net>
References: <1240502696.18438.0.camel@leto.intern.saout.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: christophe@saout.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34850
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754683AbZEQWvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 18:51:24 -0400
In-Reply-To: <1240502696.18438.0.camel@leto.intern.saout.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christophe Saout <christophe@saout.de>
Date: Thu, 23 Apr 2009 18:04:56 +0200

> I was happily running an transport-mode IPSEC connection where I was
> running NAT at one endpoint.  This means that decrypted packets can be
> forwarded to another machine, as opposed to being delivered to a local
> application.
> 
> Later I was forced to encapsulate the IPSEC traffic into UDP because I
> had no choice but pass through a NAT device.  Then, unfortunately,
> things started to break.  The machine that would receive the answer to a
> TCP/SYN packet from the gateway box (that decrypts the packed and then
> forwards it) discarded the packets because of a wrong TCP checksum.
> 
> I checked the kernel code - esp4.c is just setting CHECKSUM_UNNECESSARY
> on these packets, so that they are accepted by local applications.
> However, when the packages leaves the machine via a NIC, the packet
> still carries the broken checksum.  I checked the RFC on the issue and
> one of the suggestions is to recompute the checksum for carried TCP/UDP
> packets.
> 
> I have a working (but possibly inelegant version), which I am proposing.
> I know there are obvious things that can be improved, but I'm just
> posting it here for discussion.  Also, I'm not sure my skb handling is
> fully correct.

Thanks for reporting this.  It seems we've choosen the simplest
of the 3 implementation options given in section 3.1.2 or
RFC 3948.

It definitely breaks that case you are using, and the only way
to fix it up is to recompute the checksum.

I'll think about this some more and figure out how exactly we
should fix this.

Thanks again.
