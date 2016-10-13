From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] qede: fix CONFIG_INFINIBAND_QEDR=m build error
Date: Thu, 13 Oct 2016 12:50:01 +0200
Message-ID: <42891984.bIYIOYDk0K@wuerfel>
References: <20161012103340.978726-1-arnd@arndb.de> <5662883.yo8OytxU65@wuerfel> <BL2PR07MB230634C0879011355A10B29A8DDC0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ariel Elior <Ariel.Elior@qlogic.com>,
        "everest-linux-l2@qlogic.com" <everest-linux-l2@qlogic.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        "Amrani, Ram" <Ram.Amrani@cavium.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.134]:58069 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752940AbcJMKwl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 06:52:41 -0400
In-Reply-To: <BL2PR07MB230634C0879011355A10B29A8DDC0@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, October 13, 2016 10:44:36 AM CEST Mintz, Yuval wrote:
> > > > > While I don't mind, you could have argued is that we're not
> > > > > removing enough, not too much.
> > > > > I.e., perhaps the rdma_msix_* fields should also have been
> > > > > ifdef-ed instead. [in which case this solution would not have
> > > > > worked]
> > > >
> > > > That would add even more #ifdefs though.
> > >
> > > I agree. Although I'm never clear on the guidelines for the tradeoff -
> > > How much memory/code is considered too much so that you'd have To
> > > ifdef code out instead of 'wasting'?
> > > [I obviously don't claim 64 bytes of memory hit that threshold]
> > 
> > I don't think code size should ever be a reason for an #ifdef in a .c
> > file: if the code is well-structured, you can always get the same object code
> > using if(IS_ENABLED()) checks within the code at better readability or better
> > compile-time coverage.
> > 
> > Between if(IS_ENABLED()) checks and inline helpers, it usually doesn't matter
> > much either way as long as the separation between the modules is clear enough.
> > In the example above, removing the structure fields however would require to
> > move the debugging output into another inline function though.
> 
> Still, the question remains - If we were to allocate X bytes of memory
> per-something [in this case, per qed owned PCI function], and that memory
> wouldn't be functional without a some CONFIG option enabled,
> how big should X become before we'd decide the fields should also be
> dependent on the option?
> It bears no real relevance to this case, as the fields involved are
> insignificantly small. But still - is there a rule of thumb here?

I don't think there is a good general rule for that, given the
vastly different memory sizes in machines. For a tiny embedded
machine with 2MB of RAM, saving one kilobyte is very significant,
while an any machine that uses a 500KB qed driver module probably
has many gigabytes of RAM and doesn't care much about a
a wasted megabyte.

	Arnd
