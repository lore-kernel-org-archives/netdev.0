From: Phil Oester <kernel@linuxace.com>
Subject: Re: NAT stops forwarding ACKs after PMTU discovery
Date: Mon, 19 Aug 2013 11:00:43 -0700
Message-ID: <20130819180043.GA31511@linuxace.com>
References: <1376870592.4226.27.camel@edumazet-glaptop>
 <5211DAA6.1070302@fatooh.org>
 <20130819123314.GC3583@cpaasch-mac>
 <1376918657.4226.59.camel@edumazet-glaptop>
 <20130819134919.GF3583@cpaasch-mac>
 <1376920685.4226.61.camel@edumazet-glaptop>
 <20130819143509.GA31320@linuxace.com>
 <20130819153328.GH3583@cpaasch-mac>
 <1376928031.4226.66.camel@edumazet-glaptop>
 <20130819171519.GA4008@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Corey Hickey <bugfood-ml@fatooh.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Linux Netdev List <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:62861 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751198Ab3HSSAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 14:00:34 -0400
Received: by mail-pb0-f52.google.com with SMTP id wz12so5194670pbc.25
        for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 11:00:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130819171519.GA4008@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 19, 2013 at 07:15:19PM +0200, Christoph Paasch wrote:
> On 19/08/13 - 09:00:31, Eric Dumazet wrote:
> > On Mon, 2013-08-19 at 17:33 +0200, Christoph Paasch wrote:
> > > Unfortunately, they will hardly go away in the near futur. Rather the
> > > opposite is the case.
> > > 
> > > 
> > > If you have a public server running, I would be interested in the count of
> > > invalid SACK-blocks received (netstat -s | grep TCPSACKDiscard). This is an
> > > indication for such kind of middlebox between your server and the client,
> > > implying that these connections cannot benefit from TCP-FastRetransmission
> > > and each packet-loss will require an RTO to recover.
> > > 
> > 
> > If the (random) sequence offset is small rather than completely out of
> > window, it's going to be hard to detect all problems.

It is not small unfortunately.  The bug is that with ISN randomization enabled
the PIX leaves the SACK sequence numbers untouched.  For reference, the cisco
bug is CSCse14419.

> Yes, it is not possible to make it 100% perfect. But considering the size of
> the seq-space, the probability is rather low that the SACK-block falls
> in-window.

s/rather low/nil/

> > Show us your patch ;)

Or just disable SACK on the box behind the problematic PIX.

Phil
