From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: NAT stops forwarding ACKs after PMTU discovery
Date: Mon, 19 Aug 2013 17:33:28 +0200
Message-ID: <20130819153328.GH3583@cpaasch-mac>
References: <1376839467.21329.36.camel@edumazet-glaptop>
 <alpine.DEB.2.00.1308182314050.25515@blackhole.kfki.hu>
 <1376870425.4226.25.camel@edumazet-glaptop>
 <1376870592.4226.27.camel@edumazet-glaptop>
 <5211DAA6.1070302@fatooh.org>
 <20130819123314.GC3583@cpaasch-mac>
 <1376918657.4226.59.camel@edumazet-glaptop>
 <20130819134919.GF3583@cpaasch-mac>
 <1376920685.4226.61.camel@edumazet-glaptop>
 <20130819143509.GA31320@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Corey Hickey <bugfood-ml@fatooh.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Linux Netdev List <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Phil Oester <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:36875 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784Ab3HSPdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 11:33:35 -0400
Content-Disposition: inline
In-Reply-To: <20130819143509.GA31320@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/08/13 - 07:35:09, Phil Oester wrote:
> On Mon, Aug 19, 2013 at 06:58:05AM -0700, Eric Dumazet wrote:
> > Yeah, but here, this is conntrack who is blocking the thing.
> > 
> > TCP receiver has no chance to 'fix' it.
> > 
> > See conntrack is one of those buggy middle box as well.
> > 
> > So if you want to properly handle this mess, you'll also have to fix
> > conntrack.
> 
> Better to fix the box which is randomizing the acks and ignoring
> the SACKs.  Usually these are older Cisco PIX/ASA devices which just
> need a code upgrade.  

I agree, the problem are these horrid middleboxes...

Unfortunately, they will hardly go away in the near futur. Rather the
opposite is the case.


If you have a public server running, I would be interested in the count of
invalid SACK-blocks received (netstat -s | grep TCPSACKDiscard). This is an
indication for such kind of middlebox between your server and the client,
implying that these connections cannot benefit from TCP-FastRetransmission
and each packet-loss will require an RTO to recover.


Cheers,
Christoph
