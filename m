From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] qdisc: allow setting default queuing
 discipline
Date: Wed, 28 Aug 2013 09:18:36 -0700
Message-ID: <20130828091836.5c8285f4@nehalam.linuxnetplumber.net>
References: <20130827161908.26062336@nehalam.linuxnetplumber.net>
	<1377662448.8828.155.camel@edumazet-glaptop>
	<1377665870.8828.163.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:41148 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754059Ab3H1QSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 12:18:39 -0400
Received: by mail-pa0-f49.google.com with SMTP id ld10so6437145pab.36
        for <netdev@vger.kernel.org>; Wed, 28 Aug 2013 09:18:39 -0700 (PDT)
In-Reply-To: <1377665870.8828.163.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Aug 2013 21:57:50 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Tue, 2013-08-27 at 21:00 -0700, Eric Dumazet wrote:
> > On Tue, 2013-08-27 at 16:19 -0700, Stephen Hemminger wrote:
> > > By default, the pfifo_fast queue discipline has been used by default
> > > for all devices. But we have better choices now.
> > > 
> > > This patch allow setting the default queueing discipline with sysctl.
> > > This allows easy use of better queueing disciplines on all devices
> > > without having to use tc qdisc scripts. It is intended to allow
> > > an easy path for distributions to make fq_codel or sfq the default
> > > qdisc.
> > > 
> > > This patch also makes pfifo_fast more of a first class qdisc, since
> > > it is now possible to manually override the default and explicitly
> > > use pfifo_fast. The behavior for systems who do not use the sysctl
> > > is unchanged, they still get pfifo_fast
> > > 
> > > Also removes leftover random # in sysctl net core.
> > > 
> > > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> > > 
> > > ---
> > 
> > I find this quite incredible, because I was going to write such patch
> > tonight ;)
> > 
> > Now I can just relax, thanks so much Stephen !
> > 
> > Acked-by: Eric Dumazet <edumazet@google.com>
> > 
> 
> I was wondering if we also could redefine the pfifo default, used for
> example in HTB classes.
> 
> ie calls to qdisc_create_dflt( ... &pfifo_qdisc_ops )
> 
> /proc/sys/net/core/default_qdisc would 'define' the default pfifo_fast,
> 
> /proc/sys/net/core/default_pfifo_qdisc would 'define' the default pfifo,
> 
> Or something like that...

Although your idea adds completeness, not sure if it is worth it.
The thing is if user is using HTB, they already are using tc
commands to set it up, therefore the additional script steps to choose some
other qdisc for the leaf nodes doesn't seem like a burden.
Therefore the sysctl doesn't help much and might even create more
confusion because there is now two places to update.
