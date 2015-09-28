From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next 0/6] make non-modular code explicitly non-modular
Date: Mon, 28 Sep 2015 17:32:21 -0400
Message-ID: <20150928213220.GK1279@windriver.com>
References: <1443469890-19485-1-git-send-email-paul.gortmaker@windriver.com>
 <CAMuHMdXnk2ZoyoMj2U2iz2NYDkX=rQqZzMZyccy3g1JVqbrZMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Anish Bhatt <anish@chelsio.com>,
	Craig Gallek <kraig@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Linux/m68k <linux-m68k@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:37495 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753780AbbI1VdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 17:33:00 -0400
Content-Disposition: inline
In-Reply-To: <CAMuHMdXnk2ZoyoMj2U2iz2NYDkX=rQqZzMZyccy3g1JVqbrZMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Re: [PATCH net-next 0/6] make non-modular code explicitly non-modular] On 28/09/2015 (Mon 23:09) Geert Uytterhoeven wrote:

> Hi Paul,
> 
> On Mon, Sep 28, 2015 at 9:51 PM, Paul Gortmaker
> <paul.gortmaker@windriver.com> wrote:
> > In a previous merge window, we made changes to allow better
> > delineation between modular and non-modular code in commit
> > 0fd972a7d91d6e15393c449492a04d94c0b89351 ("module: relocate module_init
> > from init.h to module.h").  This allows us to now ensure module code
> > looks modular and non-modular code does not accidentally look modular
> > just to avoid suffering build breakage.
> >
> > Here we target code that is, by nature of their Makefile and/or
> > Kconfig settings, only available to be built-in, but implicitly
> > presenting itself as being possibly modular by way of using modular
> > headers, macros, and functions.
> >
> > The goal here is to remove that illusion of modularity from these
> > files, but in a way that leaves the actual runtime unchanged.
> > In doing so, we remove code that has never been tested and adds
> > no value to the tree.  And we continue the process of expecting a
> > level of consistency between the Kconfig/Makefile of code and the
> > code in use itself.
> >
> > Fortuntately the net subsystem has relatively few instances, given
> > the overall amount of code and drivers it contains.  For comparison
> > there are over 300 instances tree wide, resulting in a possible net
> > removal of on the order of 5000 lines of unused code.
> >
> > Build tested on net-next 34c2d9fb0498 on m68k, since that is the arch
> > where the three ethernet drivers changed here are available.
> 
> >   net/ethernet: make amd/hplance.c driver explicitly non-modular
> >   net/ethernet: make 8390/mac8390.c driver explicitly non-modular
> >   net/ethernet: make apple/macmace.c driver explicitly non-modular
> 
> Why did you choose this approach?
> What about changing the "bool"s to "tristate"s in Kconfig instead?

Long answer is here:

https://lkml.org/lkml/2015/8/24/888

To summarize, it adds functionality to code I can't test, and with 300
or so of these, it already has been a large time sink.  Add to that
extending the functionality and testing the new functionality, and it
does not scale.   Plus if something hasn't allowed tristate for over
10 years, where is the value in adding it now?

> I gave it a try, and with some small changes the three m68k ethernet drivers
> build fine as modular drivers. I can send patches if you like it.

Per above, I don't see the value in it, but if you want to do it and
test it and own submitting the patches, then I can drop the corresponding
ones from my queue.  Either way we get the code matching the Kconfig
which is what I'm after out of this.

Note that if you do decide to do this, the one driver really needs more
than just tristate one line change, it had super ancient init code that
predates module_init and probably needs an update.

Thanks,
Paul.
--

> 
> Thanks!
> 
> Gr{oetje,eeting}s,
> 
>                         Geert
> 
> --
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org
> 
> In personal conversations with technical people, I call myself a hacker. But
> when I'm talking to journalists I just say "programmer" or something like that.
>                                 -- Linus Torvalds
