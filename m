From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: tc linklayer ADSL calc broken after commit 56b765b79 (htb:
 improved accuracy at high rates)
Date: Thu, 30 May 2013 09:51:17 +0200
Message-ID: <20130530095117.503eeee7@redhat.com>
References: <20130529151330.22c5c89e@redhat.com>
	<1369842724.5109.44.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@redhat.com>, j.vimal@gmail.com,
	Michal Soltys <soltys@ziu.info>,
	Mike Frysinger <vapier@gentoo.org>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Patrick McHardy <kaber@trash.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Toke =?UTF-8?B?SMO4aWxhbmQtSsO4cmdlbnNlbg==?= <toke@toke.dk>,
	Dave Taht <dave.taht@gmail.com>, netdev@vger.kernel.org,
	bloat@lists.bufferbloat.net, Dan Siemon <dan@coverfire.com>,
	Jim Gettys <jg@freedesktop.org>,
	Steven Barth <cyrus@openwrt.org>, Felix Fietkau <nbd@nbd.name>,
	Jiri Benc <jbenc@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7658 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967758Ab3E3Hv5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 May 2013 03:51:57 -0400
In-Reply-To: <1369842724.5109.44.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 May 2013 08:52:04 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Wed, 2013-05-29 at 15:13 +0200, Jesper Dangaard Brouer wrote:
> > I recently discovered that the (traffic control) tc linklayer
> > calculations for ATM/ADSL have been broken by:
> >  commit 56b765b79 (htb: improved accuracy at high rates).
> > 
> > Thus, people shaping on ADSL links, using e.g.:
> >  tc class add ... htb rate X ceil Y linklayer atm overhead 10
> > 
> > Will no-longer get ATM cell tax/overhead adjusted.
> > 
> > How can we solve/fix this?
> > Perhaps we can change to use the "stab" system instead (as it does
> > not seem to be broken by the commit).
> > 
[...]
> 
> stab suffers from the same problem : its table driven, so works only
> for packet smaller than a given size.

You are referring to GSO/GRO packets. Yes, one must disable GSO for
this to work. Regardless ATM/ADSL, you should disable GSO when shaping
at low speeds.  Sending 64000 byte on a 512Kbit/s takes approx 1 sec.

http://netoptimizer.blogspot.dk/2010/12/buffer-bloat-calculations.html


> I am not sure it will solve the ATM logic (with the 5 bytes overhead
> per 48 bytes cell)

Are you talking about, that for GSO frames we are not adding a encap
overhead to each "sub" skb.


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
