From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: tc linklayer ADSL calc broken after commit 56b765b79 (htb:
 improved accuracy at high rates)
Date: Wed, 29 May 2013 15:50:34 -0700
Message-ID: <20130529155034.334092c5@nehalam.linuxnetplumber.net>
References: <20130529151330.22c5c89e@redhat.com>
	<1369842724.5109.44.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	David Miller <davem@redhat.com>, j.vimal@gmail.com,
	Michal Soltys <soltys@ziu.info>,
	Mike Frysinger <vapier@gentoo.org>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Patrick McHardy <kaber@trash.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Toke =?ISO-8859-1?B?SPhpbGFuZC1K+HJnZW5zZW4=?= <toke@toke.dk>,
	Dave Taht <dave.taht@gmail.com>, netdev@vger.kernel.org,
	bloat@lists.bufferbloat.net, Dan Siemon <dan@coverfire.com>,
	Jim Gettys <jg@freedesktop.org>,
	Steven Barth <cyrus@openwrt.org>, Felix Fietkau <nbd@nbd.name>,
	Jiri Benc <jbenc@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:49578 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966799Ab3E2Wuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 18:50:39 -0400
Received: by mail-pb0-f48.google.com with SMTP id md12so9899183pbc.35
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 15:50:39 -0700 (PDT)
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
> > But how do we facilitate a change to use "stab" system (for all the
> > scripts using the old option)?
> > 
> > Can we change the iproute2/tc command to handle this transparently, or
> > should we give an error/warning if someone uses "tc" and "linklayer" on
> > a kernel above v.3.8. ?
> > 
> > 
> > History:
> >  - My linklayer ATM changes appeared in kernel 2.6.24 (and iproute2 2.6.25)
> >  - The STAB changes appeared in kernel 2.6.27
> > 
> 
> Hi Jesper
> 
> stab suffers from the same problem : its table driven, so works only for
> packet smaller than a given size.
> 
> I am not sure it will solve the ATM logic (with the 5 bytes overhead per
> 48 bytes cell)
> 
> btw, even on old kernels :


How bad is the failure? If it is fixed, will it break existing installations?

Which probably means, is anyone but the original developers ever using it
and therefore likely to notice?
