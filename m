From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] qdisc: allow setting default queuing discipline
Date: Tue, 27 Aug 2013 21:57:50 -0700
Message-ID: <1377665870.8828.163.camel@edumazet-glaptop>
References: <20130827161908.26062336@nehalam.linuxnetplumber.net>
	 <1377662448.8828.155.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:40676 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597Ab3H1E5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 00:57:52 -0400
Received: by mail-pd0-f174.google.com with SMTP id y13so5826886pdi.33
        for <netdev@vger.kernel.org>; Tue, 27 Aug 2013 21:57:51 -0700 (PDT)
In-Reply-To: <1377662448.8828.155.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-27 at 21:00 -0700, Eric Dumazet wrote:
> On Tue, 2013-08-27 at 16:19 -0700, Stephen Hemminger wrote:
> > By default, the pfifo_fast queue discipline has been used by default
> > for all devices. But we have better choices now.
> > 
> > This patch allow setting the default queueing discipline with sysctl.
> > This allows easy use of better queueing disciplines on all devices
> > without having to use tc qdisc scripts. It is intended to allow
> > an easy path for distributions to make fq_codel or sfq the default
> > qdisc.
> > 
> > This patch also makes pfifo_fast more of a first class qdisc, since
> > it is now possible to manually override the default and explicitly
> > use pfifo_fast. The behavior for systems who do not use the sysctl
> > is unchanged, they still get pfifo_fast
> > 
> > Also removes leftover random # in sysctl net core.
> > 
> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> > 
> > ---
> 
> I find this quite incredible, because I was going to write such patch
> tonight ;)
> 
> Now I can just relax, thanks so much Stephen !
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> 

I was wondering if we also could redefine the pfifo default, used for
example in HTB classes.

ie calls to qdisc_create_dflt( ... &pfifo_qdisc_ops )

/proc/sys/net/core/default_qdisc would 'define' the default pfifo_fast,

/proc/sys/net/core/default_pfifo_qdisc would 'define' the default pfifo,

Or something like that...
