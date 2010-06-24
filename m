From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 1/2] syncookies: do not store rcv_wscale in tcp
 timestamp
Date: Thu, 24 Jun 2010 09:53:04 +0200
Message-ID: <20100624075304.GH27132@Chamillionaire.breakpoint.cc>
References: <1277156925-7295-1-git-send-email-fw@strlen.de>
 <20100623202759.GA3581@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:39079 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753950Ab0FXHxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 03:53:07 -0400
Content-Disposition: inline
In-Reply-To: <20100623202759.GA3581@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hagen Paul Pfeifer <hagen@jauu.net> wrote:
> * Florian Westphal | 2010-06-21 23:48:44 [+0200]:
> 
> >As pointed out by Fernando Gont there is no need to encode rcv_wscale
> >into the cookie.
> >
> >We did not use the restored rcv_wscale anyway; it is recomputed
> >via tcp_select_initial_window().
> 
> I speculate that this behavior was and is not correct. I suppose that their is
> a race between the SYN/ACK where we initial force a particular window scale
> and the next time where we recalculate the window via tcp_select_initial_window().

Yes, but it is not the only one. We also do a route lookup to get the
current window size.

> If the user change net.core.rmem_max or net.ipv4.tcp_rmem in between this
> time, the recalculated window scale (rcv_wscale) can be smaller. But the
> receiver still operates with the initial window scale and can overshot the
> granted window - and bang.

Why "bang"?
Sure, its not nice, but is it such a severe problem that we have to keep
rcv_wscale around in the timestamp?

> There are several solutions: encode rcv_wscale into the syn cookie and don't
> recalculate

I would prefer to avoid having to keep rcv_wscale in the timstamp for the sake of
a sysctl change. At the moment the state eats up 9 bits in the timestamp and I don't
like to grow it (which has to be done iff we want to support more options in the future).

>  or disable window scaling and don't transmit any scaling option
> when SYN cookies are active.

No, I would rather see this patch rejected than that.
