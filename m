From: Jamal Hadi Salim <hadi@cyberus.ca>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help()
	2.6.18-rc3
Date: Tue, 01 Aug 2006 08:00:48 -0400
Message-ID: <1154433648.5170.84.camel@jzny2>
References: <44CE4DCA.8000609@trash.net> <44CF0086.1030404@trash.net>
	 <20060801072358.GB3802@gondor.apana.org.au>
	 <20060801.003614.54188740.davem@davemloft.net>
	 <20060801074504.GA4272@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:55021 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1750773AbWHAMA5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 08:00:57 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1G7svi-0003cr-DI
	for netdev@vger.kernel.org; Tue, 01 Aug 2006 08:00:58 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060801074504.GA4272@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-01-08 at 17:45 +1000, Herbert Xu wrote:
> On Tue, Aug 01, 2006 at 12:36:14AM -0700, David Miller wrote:
> > 
> > > > - tc_verd/tc_index/input_dev: when directing a packet from a device
> > > >   supporting GSO to a device not supporting GSO using tc actions,
> > > >   these fields may be set.
> > > 
> > > This doesn't look right though.  GSO should occur just before
> > > hard_start_xmit (after all tc actions have taken place) so we
> > > shouldn't have any more tc actions to perform.
> > 
> > Hmmm, what about loopback?  Yeah yeah, LOOPBACK_TSO is not defined :)
> > but what I'm really referring to is that loopback preserves the
> > traffic classifier bits of the skb.
> 
> I don't know.  Jamal, is there a scenario where these three attributes
> are needed for loopback packets?


I didnt fully understand the scope of the discussion, but a little
explanation may help answer the question:

If the only spot where the GSO kicks in is at or after qdisc_is_running
level, then the redirect will happen way before that point at
qdisc->enqueue time.
When we redirect or mirror, the packet is cloned and any metadata
preserved at clone time needs to stay intact before dev_queue_xmit is
hit for the destination device. 
And of course we have no checks for whether we are redirecting from a
device that is GSO capable to one that is not (or vice-versa). If thats
important, we could add a check.

I am not sure if I answered the question ;->

cheers,
jamal



