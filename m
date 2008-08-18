From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH]: Schedule correct qdisc in watchdog.
Date: Mon, 18 Aug 2008 09:47:27 +0000
Message-ID: <20080818094727.GA6388@ff.dom.local>
References: <20080818.013954.187452037.davem@davemloft.net> <20080818091011.GC5434@ff.dom.local> <20080818.023105.01989851.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.189]:8266 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751514AbYHRJrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 05:47:33 -0400
Received: by fk-out-0910.google.com with SMTP id 18so2110083fkq.5
        for <netdev@vger.kernel.org>; Mon, 18 Aug 2008 02:47:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080818.023105.01989851.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 18, 2008 at 02:31:05AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Mon, 18 Aug 2008 09:10:12 +0000
> 
> > Yes, this was one of the reasons, but not the only one, and my oldbie
> > version of this fix could be found here as "02-fix1.patch":
> > 
> > http://permalink.gmane.org/gmane.linux.network/103039
> 
> This is what I get for failing to be able to follow that
> flurry of patches :)  I'll apply your version in the
> end, thanks.
> 
> > It's a bit different, because I think wd->qdisc can probably
> > point to the noop_qdisc (if it's the root qdisc).
> 
> noop_qdisc does not use the watchdogs as far as I can see.
> 
> But, if we are in dev_deactivate() state, root qdisc can
> be &noop_qdisc and scheduling that is fine and just a nop.

Maybe I wrote this wrong. wd->qdisc stores qdisc from the
qdisc_watchdog_init() time, and this could be &noop_qdisc.
So qdisc_root() would schedule wrong qdisc later. BTW, my
version would probably do the same for root qdisc, but in
these tests there was a problem with leafs.

And of course, scheduling &noop_qdisc isn't bad, until we
sometimes schedule something else too.

Jarek P.
