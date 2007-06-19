From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Tue, 19 Jun 2007 20:44:20 +0400
Message-ID: <20070619164420.GB17942@2ka.mipt.ru>
References: <OFB311484E.057E34E9-ON652572F3.001D5838-652572F3.0022766D@in.ibm.com> <1181216629.4064.22.camel@localhost> <20070619132148.GA32078@2ka.mipt.ru> <20070619133333.GA19667@2ka.mipt.ru> <20070619140038.GA13629@2ka.mipt.ru> <20070619140944.GA26241@2ka.mipt.ru> <1182270768.4968.78.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Gagan Arneja <gaagaan@gmail.com>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:46900 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750939AbXFSReN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2007 13:34:13 -0400
Content-Disposition: inline
In-Reply-To: <1182270768.4968.78.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 19, 2007 at 12:32:48PM -0400, jamal (hadi@cyberus.ca) wrote:
> > > pktgen reults are quite poor:
> > > batch (changed from default script: count reduced, clone increased to 10k)
> > > 241319pps 115Mb/sec
> 
> BTW, dont turn on the cloning - leave it as 1 so we can have every
> packet alloced so as to have worst case scenario.

here is with batch_min 400 and clone 1:
184251pps 88Mb/sec (88440480bps) errors: 0
A bit better than without cloning, but that might be a noise.

batch_min 0 and clone 1:
258564pps 124Mb/sec (124110720bps) errors: 0
Noticebly better than with cloning, but still much worse than mainline.

> > > mainline (the same script, on start it wrote about unsupported batch_low
> > > parameter:
> > > 497520pps 238Mb/sec
> > 
> > 
> > And here is with batch_low=400:
> 
> I am going to get rid of that batch param - it doesnt seem to matter
> what that value is in the long run.

Hmm, with that parameter result is 87Mb/sec while with batch_min equal
to zero it is 115Mb/sec. Without batching result is even better -
238Mb/sec, so it does seem to affect performance.

> > Result: OK: T4143884(U4143864+I20+A4007752+T127073) usec, P1000000 TE8511TS1(B60,-1frags)
> 
> So on average you have been sending about 120 packets per batch - which
> should give you decent numbers. Lets see how Robert responds and if you
> have time, turn off the kernel configs like i did.

It is not turned on in my config.

> cheers,
> jamal

-- 
	Evgeniy Polyakov
