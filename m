From: Dmitry Popov <ixaphire@qrator.net>
Subject: Re: missing icmp redirects
Date: Wed, 11 Jun 2014 19:04:25 +0400
Message-ID: <20140611190425.6f5075756e726b743ed3f53c@qrator.net>
References: <5343FE4D.40805@computer.org>
	<DUB123-W19EE656C7ECB42B9D05319ED6B0@phx.gbl>
	<53974A0F.7080908@computer.org>
	<20140611000613.3fb3c563523b73244d90dc44@qrator.net>
	<539802FA.3040207@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Lukas Tribus <luky-37@hotmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Per Jessen <per@computer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:46830 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755302AbaFKPEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 11:04:30 -0400
Received: by mail-lb0-f181.google.com with SMTP id q8so4936560lbi.12
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2014 08:04:28 -0700 (PDT)
In-Reply-To: <539802FA.3040207@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Jun 2014 09:19:22 +0200
Per Jessen <per@computer.org> wrote:

> Dmitry Popov wrote:
> > On Tue, 10 Jun 2014 20:10:23 +0200
> > Per Jessen <per@computer.org> wrote:
> > 
> >> Lukas Tribus wrote:
> >>>> See complete description here:
> >>>>
> >>>> https://bugzilla.kernel.org/show_bug.cgi?id=72561
> >>>>
> >>>> Summary - some ICMP redirects seem to be missing.
> >>>>
> > It's probably not a bug, but intended behavior. See ip_rt_send_redirect in 
> > net/ipv4/route.c. The kernel has a built-in per-source-address limiter for icmp
> > redirects. 
> Any possibility that this limiter may have been inactive/faulty in e.g. 2.6.34? 

Hi!

This limiter worked per-destination-address before kernel v3.6. More precisely,
commit 1d861aa4b3(inet: Minimize use of cached route inetpeer) changed that
behavior. I don't know the reasons behind it (both approaches have pros and 
cons), I think you should ask David if you're curious.

* upd: it's not a limiter for icmp redirects only, it is used for other icmp
errors too. 

> > You can disable it for example with 
> > echo -1 > /proc/sys/net/ipv4/route/redirect_silence
> > Though I am not sure if it is ok in wild networks.
> 
> Okay, that worked on the first attempt.
> Should I also be looking at the other redirect settings?
> 
> /proc/sys/net/ipv4/route/redirect_load
> /proc/sys/net/ipv4/route/redirect_number

redirect_silence is enough, you can look at the algorithm (it's simple enough)
in net/ipv4/route.c:ip_rt_send_redirect if you're curious how it works and what 
those settings mean.
