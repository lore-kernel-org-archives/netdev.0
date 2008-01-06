From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.24-rc6-mm1
Date: Sun, 6 Jan 2008 15:52:27 +0100
Message-ID: <20080106145227.GB3117@ami.dom.local>
References: <64bb37e0801040223q17a76565k3c7667a197403ce5@mail.gmail.com> <20080104133031.GA3329@ff.dom.local> <64bb37e0801040721p57ff3d54wc3de00546d1d2ff1@mail.gmail.com> <20080105000700.GA3224@ami.dom.local> <64bb37e0801050001x65b104bdl5a68c731b3656d17@mail.gmail.com> <20080105101327.GA3103@ami.dom.local> <64bb37e0801050652t7568e438uf93208601df84ef6@mail.gmail.com> <20080106082740.GA3117@ami.dom.local> <64bb37e0801060230x6b392542la9556d72a184f306@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>, netdev@vger.kernel.org,
	Tom Tucker <tom@opengridcomputing.com>
To: Torsten Kaiser <just.for.lkml@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.187]:31065 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760039AbYAFOq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2008 09:46:59 -0500
Received: by fk-out-0910.google.com with SMTP id z23so8017038fkz.5
        for <netdev@vger.kernel.org>; Sun, 06 Jan 2008 06:46:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <64bb37e0801060230x6b392542la9556d72a184f306@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 06, 2008 at 11:30:48AM +0100, Torsten Kaiser wrote:
...
> I think this bug is highly timing dependent. Its not always the same
> package that dies and as this is a SMP system I would guess two CPUs
> using the same data will trigger this.
> And using the poison-option will definitily slow the system down and
> mess up the timings.

Of course it looks like using the same data, but it seems there is no
reason to think it needs the same time: e.g. some timer or workqueue
could retrigger after it's supposed to be killed. Any additional
debugging/poisonning might help to see it earlier, so this should be
safer for your system, but, most probably this would show data from
the damaged side, so not necessarily very helpful.

> What also speaks against the 'safer' offsets is, that after adding my
> notfreed-byte to skbuff the bug still triggered in the same way.

We are not even sure skbuffs were directly affected by this or they
were incorrectly freed because of other structures beeing damaged?

IMHO, e.g. starting your system with limited memory should cause
faster memory reclaiming, and thus more often triggering of these bugs,
but of course I can be wrong.

Jarek P.
