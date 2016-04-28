From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2 0/2] pegasus: correct buffer sizes
Date: Thu, 28 Apr 2016 08:49:37 +0200
Message-ID: <1461826177.2352.1.camel@sipsolutions.net>
References: <1461742525-2748-1-git-send-email-petkan@mip-labs.com>
	 <1461743175.3723.1.camel@sipsolutions.net> <20160427093358.GA30444@p310>
	 <1461750245.3723.8.camel@sipsolutions.net>
	 <063D6719AE5E284EB5DD2968C1650D6D5F4ABB06@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"a1291762@gmail.com" <a1291762@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>,
	Petko Manolov <petkan@mip-labs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:57184 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752440AbcD1Gto (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2016 02:49:44 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D5F4ABB06@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-04-27 at 16:26 +0000, David Laight wrote:
> From: Johannes Berg
> > 
> > Sent: 27 April 2016 10:44
> > On Wed, 2016-04-27 at 12:33 +0300, Petko Manolov wrote:
> > > 
> > > 
> > > Your guess turned out to be not so wild.;)All Pegasus devices are
> > > configured (by the driver) to append CRC at the end of each RX
> > > packet.However, the driver reports packet length that does not
> > > include it.
> > Interesting, then my guess was wrong though, since the length is
> > reported without it, or am I misunderstanding this?
> ...
> 
> It is even possible that the crc is written into the rx buffer even
> though the length the hardware reports excludes it.
> 

Right. I think a proper test would be to construct some kind of
ethernet-only frames, and check that they come out properly on the
other side. IP always has its own length field, so may be happy with
trailing garbage reported to the network stack, but doing raw ethernet
will let you check that the frame length is correct.

johannes
