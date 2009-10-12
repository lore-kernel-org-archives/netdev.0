From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Moving drivers into staging (was Re: [GIT PULL] SCSI fixes for
	2.6.32-rc3)
Date: Mon, 12 Oct 2009 17:42:44 +0200
Message-ID: <20091012154244.GA13323@elte.hu>
References: <alpine.LFD.2.01.0910081252090.3432@localhost.localdomain> <alpine.LFD.2.01.0910081255510.3432@localhost.localdomain> <20091008210737.GD29181@mit.edu> <alpine.LFD.2.01.0910081410400.3432@localhost.localdomain> <20091009091538.GA4154@elte.hu> <1255097287.2934.21.camel@localhost.localdomain> <20091012130652.GB25464@elte.hu> <1255357148.2850.91.camel@localhost.localdomain> <20091012145453.GD4565@elte.hu> <20091012150911.GB1656@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Bottomley <James.Bottomley@suse.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Theodore Tso <tytso@mit.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Jing Huang <huangj@brocade.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Greg KH <gregkh@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754917AbZJLPni@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091012150911.GB1656@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Greg KH <gregkh@suse.de> wrote:

> > Sidenote, in fact i think we should expand on that: drivers/staging/ 
> > should be used in the _other_ direction as well - to un-upstream 
> > stale drivers that are abandoned and unused, in a gradual fashion. 
> > 'git mv' is cheap.
> 
> Ok, this is about the 3rd or 4th time I've heard this, from totally 
> different people lately. [...]

Heh. I guess i had a good crystal ball on that then - i raised that 
issue in my very first comments on drivers/staging/, 2.5 years ago - see 
the "Linux Kernel developer statement about closed source code" thread, 
where i wrote:

| - We must accept open-source drivers (which are license-compatible
|   with the kernel) for new hardware the moment they are offered. No 
|   ifs and when. No whining about quality, style, security, re-use, 
|   non-reuse, obsolete APIs, overlapping functionality, the already 
|   busy merge schedule of a maintainer or whatever other thing can come 
|   up on lkml.
|
|   We can create arbitrary quarantine mechanisms we wish to use: 
|   CONFIG_REALLY_BROKEN. We could even create drivers/staging/ as a 
|   temporary staging area for drivers.
|
|   What we cannot do is to _deny_ the distribution channel and exclude 
|   users. The moment we do that (and we still do that in way too many 
|   areas of the kernel) we have lost the availability race.

[...]

| If it's not maintained actively(sc) (i.e. it's a fire-and-forget 
| driver) then it can get marked BROKEN with time, and can get removed 
| as well.

Hm, i think i even gave drivers/staging/ its name?

> [...] It seems that I'm the only one that has the ability to drop 
> drivers out of the kernel tree, which is a funny situation :)

You are the only one who has the ability to send a warning shot towards 
drivers _without hurting users_, and by moving it into the focus of a 
team of cleanup oriented developers.

I think that's an important distinction ;-)

> In thinking about this a lot more, I don't really mind it.  If people 
> want to push stuff out of "real" places in the kernel, into 
> drivers/staging/ and give the original authors and maintainers notice 
> about what is going on, _and_ provide a TODO file for what needs to 
> happen to get the code back into the main portion of the kernel tree, 
> then I'll be happy to help out with this and manage it.
> 
> I think a 6-9 month window (basically 3 kernel releases) should be 
> sufficient time to have a driver that has been in drivers/staging/ be 
> cleaned up enough to move back into the main kernel tree.  If not, it 
> could be easily dropped.
> 
> Any objections to this?

Sounds excellent to me!

> > Basically, drivers/staging/ gives us an excellent opportunity to 
> > _increase_ the quality of drivers by applying stronger upstream 
> > inclusion filters, without having to hurt users/developers in the 
> > process. We just have to start using it that way as well.
> 
> I totally agree.  And so far, it does seem to be working well for 
> this. A number of companies have used it to successfully get their 
> code into the main kernel, as well as driving them to clean up their 
> code better to keep it from having to go into the staging tree.

Yeah. I think we were hurting from an under-estimated trust problem: 
driver authors couldnt trust _us maintainers_ to follow through with 
upstreaming. drivers/staging/ improved that IMHO.

I.e. the old process of upstreaming drivers was too arbitrary, incurred 
big latencies and was dependent on the whims of maintainers. I.e. new 
developers got exposed to some of the worst social aspects of a 
distributed development process.

Now there's basically a single (and friendly! ;-) upstreaming channel 
that people (yet-)unfamilar with Linux practices can standardize on. 
This reduces the pressure on maintainers and also creates a reference 
point for upstreaming honesty - which is almost unconditionally good i 
think.

	Ingo
