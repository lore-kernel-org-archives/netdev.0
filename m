From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.24-rc6-mm1
Date: Sun, 6 Jan 2008 09:27:40 +0100
Message-ID: <20080106082740.GA3117@ami.dom.local>
References: <64bb37e0801040223q17a76565k3c7667a197403ce5@mail.gmail.com> <20080104133031.GA3329@ff.dom.local> <64bb37e0801040721p57ff3d54wc3de00546d1d2ff1@mail.gmail.com> <20080105000700.GA3224@ami.dom.local> <64bb37e0801050001x65b104bdl5a68c731b3656d17@mail.gmail.com> <20080105101327.GA3103@ami.dom.local> <64bb37e0801050652t7568e438uf93208601df84ef6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>, netdev@vger.kernel.org,
	Tom Tucker <tom@opengridcomputing.com>
To: Torsten Kaiser <just.for.lkml@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:65229 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751817AbYAFIZB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2008 03:25:01 -0500
Received: by fg-out-1718.google.com with SMTP id e21so4003888fga.17
        for <netdev@vger.kernel.org>; Sun, 06 Jan 2008 00:25:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <64bb37e0801050652t7568e438uf93208601df84ef6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 05, 2008 at 03:52:32PM +0100, Torsten Kaiser wrote:
...
> So my personal conclusion would be, that someone is writing to memory
> that he no longer owns. Most probably 0-bytes. (the complete_routine
> got NULLed and the warning about dst->__refcnt being 0).
> 
> Use-after-free or something else?

I agree: your conclusion seems to be the most probable explanation for
this. Then it could be really hard to solve this without bisection or
something similar. But there is some probabability this something could
try kfree later too, but simply this list debugging triggers earlier.

> > > If you think some other slub_debug might catch it, I would try this...

You can try to add "U" to these other slub_debug options. As a matter
of fact, if your above diagnose is right, it seems you risk to damage
your system or even the box with these tests, so if you want to
continue, you should probably turn any possible debugging on (not in
mm only).

BTW, you've written that some debugging options seem to delay the bug.
Since they often change sizes of some structures than such wrong
writes could have some 'safer' offsets. So, this could really delay
e.g. these list's bugs, but maybe this could also let to stay 'alive'
to such wrong kfree?

Cheers,
Jarek P.
