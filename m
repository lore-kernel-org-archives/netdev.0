From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: tc linklayer ADSL calc broken after commit 56b765b79 (htb:
 improved accuracy at high rates)
Date: Thu, 30 May 2013 10:09:52 +0200
Message-ID: <20130530100952.032a4b61@redhat.com>
References: <20130529151330.22c5c89e@redhat.com>
	<1369842724.5109.44.camel@edumazet-glaptop>
	<20130529155034.334092c5@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	David Miller <davem@redhat.com>, j.vimal@gmail.com,
	Michal Soltys <soltys@ziu.info>,
	Mike Frysinger <vapier@gentoo.org>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Patrick McHardy <kaber@trash.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Toke =?UTF-8?B?SMO4aWxhbmQtSsO4cmdlbnNl?= =?UTF-8?B?bg==?=
	<toke@toke.dk>, Dave Taht <dave.taht@gmail.com>,
	netdev@vger.kernel.org, bloat@lists.bufferbloat.net,
	Dan Siemon <dan@coverfire.com>,
	Jim Gettys <jg@freedesktop.org>,
	Steven Barth <cyrus@openwrt.org>, Felix Fietkau <nbd@nbd.name>,
	Jiri Benc <jbenc@redhat.com>, russell-tcatm@stuart.id.au
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7831 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967631Ab3E3IKs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 May 2013 04:10:48 -0400
In-Reply-To: <20130529155034.334092c5@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 May 2013 15:50:34 -0700
Stephen Hemminger <stephen@networkplumber.org> wrote:

> On Wed, 29 May 2013 08:52:04 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > On Wed, 2013-05-29 at 15:13 +0200, Jesper Dangaard Brouer wrote:
> > > I recently discovered that the (traffic control) tc linklayer
> > > calculations for ATM/ADSL have been broken by:
> > >  commit 56b765b79 (htb: improved accuracy at high rates).
> > > 
> > > Thus, people shaping on ADSL links, using e.g.:
> > >  tc class add ... htb rate X ceil Y linklayer atm overhead 10
> > > 
> > > Will no-longer get ATM cell tax/overhead adjusted.
> > > 
> > > How can we solve/fix this?
> > > Perhaps we can change to use the "stab" system instead (as it does
> > > not seem to be broken by the commit).
> > > 
> > > But how do we facilitate a change to use "stab" system (for all
> > > the scripts using the old option)?
> > > 
> > > Can we change the iproute2/tc command to handle this
> > > transparently, or should we give an error/warning if someone uses
> > > "tc" and "linklayer" on a kernel above v.3.8. ?
> > > 
[...]
> 
> How bad is the failure? If it is fixed, will it break existing
> installations?

There is no "failure", the ATM-aligned rate table send to the kernel is
silently ignored.

People using the linklayer ATM option will just be confused why their
shaping scripts does not work, when situation of bufferbloat occurs.

I guess that was why Dave Taht, was so confused, when he wanted to make
his scripts DSL aware...


> Which probably means, is anyone but the original developers ever
> using it and therefore likely to notice?

Me the "original developer" actually don't use as I don't have a ADSL
line any-longer.  I know of people using this.  Dan Siemon have it as
an option in his scripts (but uses VDSL with out ATM himself). I
recently got contacted from someone in China, asking me to reconstruct
my homepage: http://www.adsl-optimizer.dk/ as they were using it.

The question is how do we fix this in a backward compatible manor?


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
