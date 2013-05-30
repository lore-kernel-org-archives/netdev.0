From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: tc linklayer ADSL calc broken after commit 56b765b79 (htb:
 improved accuracy at high rates)
Date: Thu, 30 May 2013 11:15:47 +0200
Message-ID: <20130530111547.07397287@redhat.com>
References: <20130529151330.22c5c89e@redhat.com>
	<1369842724.5109.44.camel@edumazet-glaptop>
	<20130529155034.334092c5@nehalam.linuxnetplumber.net>
	<1369869506.5109.87.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
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
	Jiri Benc <jbenc@redhat.com>,
	"russell-tcatm@stuart.id.au" <russell-tcatm@stuart.id.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37580 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030276Ab3E3JQd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 May 2013 05:16:33 -0400
In-Reply-To: <1369869506.5109.87.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 29 May 2013 16:18:26 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2013-05-29 at 15:50 -0700, Stephen Hemminger wrote:
> > On Wed, 29 May 2013 08:52:04 -0700
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > 
> > > On Wed, 2013-05-29 at 15:13 +0200, Jesper Dangaard Brouer wrote:
> > > > I recently discovered that the (traffic control) tc linklayer
> > > > calculations for ATM/ADSL have been broken by:
> > > >  commit 56b765b79 (htb: improved accuracy at high rates).
> > > > 
> > > > Thus, people shaping on ADSL links, using e.g.:
> > > >  tc class add ... htb rate X ceil Y linklayer atm overhead 10
> > > > 
> > > > Will no-longer get ATM cell tax/overhead adjusted.
> > > > 
> 
> Adding the logic on the kernel is doable, by adding some clean
> attributes so that tc can setup the feature, and report the attributes
> back.

Yes, doing the logic in the kernel might be a better solution.
But the question is how do we keep iproute2 backward compatible with
older kernels?



> cpus are fast today and can perform the atm cell/overhead faster than
> a table lookup.

Do remember that the target CPU is small embedded router boxes.
BUT I do agree that, the following code required, is probably faster
than a table lookup:

 int pkt_len = skb->len + (encap_overhead * gso_segments);
 int wire_sz = DIV_ROUND_UP(pkt_len,48)*53;

(I suspect, that the compiler might even optimize and remove any
real divisions, I bet Eric can tell us.)

Looking at how simple the above code is, I'm a little appalled by all
the table lookup infrastructure and hacks we added, to
support/implement this.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
