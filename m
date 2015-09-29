From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next 0/6] make non-modular code explicitly non-modular
Date: Tue, 29 Sep 2015 09:33:45 -0400
Message-ID: <20150929133344.GN1279@windriver.com>
References: <1443469890-19485-1-git-send-email-paul.gortmaker@windriver.com>
 <CAMuHMdXnk2ZoyoMj2U2iz2NYDkX=rQqZzMZyccy3g1JVqbrZMw@mail.gmail.com>
 <20150928213220.GK1279@windriver.com>
 <alpine.LNX.2.00.1509290908080.25162@nippy.intranet>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
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
To: Finn Thain <fthain@telegraphics.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:62221 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965003AbbI2NeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 09:34:22 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1509290908080.25162@nippy.intranet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Re: [PATCH net-next 0/6] make non-modular code explicitly non-modular] On 29/09/2015 (Tue 16:32) Finn Thain wrote:

> 
> Hi Paul,
> 
> On Mon, 28 Sep 2015, Paul Gortmaker wrote:
> 
> > On 28/09/2015 (Mon 23:09) Geert Uytterhoeven wrote:
> > 
> > > Hi Paul,
> ...
> > > 
> > > Why did you choose this approach?
> > > What about changing the "bool"s to "tristate"s in Kconfig instead?
> > 
> > Long answer is here:
> > 
> > https://lkml.org/lkml/2015/8/24/888
> 
> You wrote, "If there was demand for them to be tristate, then it would 
> have happened by now." I don't follow your reasoning. You might just as 
> well remove entire drivers and then argue, "If there was demand for 
> drivers without bugs, then someone would have written them by now".

I don't see those two sentences being alike, but in the end it does
not matter, since Geert has decided to do the conversion and test it.

And whatever code gets removed is never truly gone anyway; it lives on
in the git history forever.

Thanks,
Paul.
--

> 
> Perhaps you meant, "If there was sufficient demand for them to be 
> tristate, then sufficient resources would have been marshalled, as 
> required to get an enhancement written, tested, submitted, reviewed and 
> merged in the mainline kernel."
> 
> > 
> > To summarize, it adds functionality to code I can't test, and with 300 
> > or so of these, it already has been a large time sink.  Add to that 
> > extending the functionality and testing the new functionality, and it 
> > does not scale. Plus if something hasn't allowed tristate for over 10 
> > years, where is the value in adding it now?
> 
> There is value to be gained by completing the tristate support, and there 
> is value destroyed by removing the partial tristate support.
> 
> I'm not involved in building distro kernels, but I know that Debian's 
> would benefit from these tristates, because it would reduce the size of 
> the m68k multi-platform kernel binary.
> 
> And even if it is dead code you aim to remove, a lot of people have worked 
> on it (according to git blame), including myself. We should not disregard 
> that effort when we could leverage it instead.
> 
> For the macmace driver in particular, I did the platform driver 
> conversion, and it should work as a module. I did not change it to 
> tristate at the time because I did not want to deal with the question of 
> the 'psc' global, which lacks an EXPORT_SYMBOL(psc). Anyway, I'll send a 
> patch if Geert doesn't do so first.
> 
> > 
> > > I gave it a try, and with some small changes the three m68k ethernet 
> > > drivers build fine as modular drivers. I can send patches if you like 
> > > it.
> > 
> > Per above, I don't see the value in it, but if you want to do it and 
> > test it and own submitting the patches, then I can drop the 
> > corresponding ones from my queue.
> 
> I can't test right now but I have the hardware and will attend to any 
> issues if need be. I do not expect any issues, because the modular option 
> seems to involve the same code paths in the driver.
> 
> If the CONFIG_MACMACE=m option was implemented badly and did not work 
> correctly, at least it couldn't be called a regression, presuming that 'm' 
> builds okay, and that the default was 'y' or 'n'.
> 
> > Either way we get the code matching the Kconfig which is what I'm after 
> > out of this.
> 
> Yes, me too.
> 
> > 
> > Note that if you do decide to do this, the one driver really needs more 
> > than just tristate one line change, it had super ancient init code that 
> > predates module_init and probably needs an update.
> 
> I think the solution for mac8390 is to do in the modular case exactly what 
> Space.c does in the built-in case. That would mean that the modular driver 
> would support only one card, just like the built-in driver. (That 
> limitation is a problem which affects all Nubus card drivers, because they 
> have to do all their own bus matching, because Nubus still lacks the 
> necessary driver model support.)
> 
> I haven't looked at amd/hplance, but I expect that the issues are similar.
> 
> Geert, do plan to send patches for any of these drivers?
> 
> Regards,
> Finn
> 
> > 
> > Thanks,
> > Paul.
> > --
> > 
> > > 
> > > Thanks!
> > > 
> > > Gr{oetje,eeting}s,
> > > 
> > >                         Geert
> 
