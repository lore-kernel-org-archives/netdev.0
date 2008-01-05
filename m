From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.24-rc6-mm1
Date: Sat, 5 Jan 2008 11:13:27 +0100
Message-ID: <20080105101327.GA3103@ami.dom.local>
References: <64bb37e0801040223q17a76565k3c7667a197403ce5@mail.gmail.com> <20080104133031.GA3329@ff.dom.local> <64bb37e0801040721p57ff3d54wc3de00546d1d2ff1@mail.gmail.com> <20080105000700.GA3224@ami.dom.local> <64bb37e0801050001x65b104bdl5a68c731b3656d17@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>, netdev@vger.kernel.org,
	Tom Tucker <tom@opengridcomputing.com>
To: Torsten Kaiser <just.for.lkml@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:43539 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753733AbYAEKLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 05:11:03 -0500
Received: by fg-out-1718.google.com with SMTP id e21so3795108fga.17
        for <netdev@vger.kernel.org>; Sat, 05 Jan 2008 02:10:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <64bb37e0801050001x65b104bdl5a68c731b3656d17@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 05, 2008 at 09:01:02AM +0100, Torsten Kaiser wrote:
> On Jan 5, 2008 1:07 AM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> > On Fri, Jan 04, 2008 at 04:21:26PM +0100, Torsten Kaiser wrote:
> > > On Jan 4, 2008 2:30 PM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> > > The only thing that is sadly not practical is bisecting the borkenout
> > > mm-patches, as triggering this error is to unreliable /
> > > time-consuming.
> >
> > Right, but it seems there are these 2 main suspects here...
> >
> > > > - is it still vanilla -rc6-mm1; I've seen on kernel list you tried
> > > > some fixes around raid?
> > >
> > > Yes, without these fixes I can't boot.
> > > But they should only be run during starting the arrays, so I doubt
> > > that this is that cause.
> > > (Also -rc3-mm2 did not need this fix)
> >
> > You've written vanilla -rc6 is OK. Does it mean -rc6 with these fixes?
> 
> vanilla -rc6 is fine without these fixes.
> The raid-bugs from -rc6-mm1 are probably introduced by
> md-allow-devices-to-be-shared-between-md-arrays.patch and that patch
> is new in this mm-release.
> 
> > I think it would be easier just to start with this working -rc6 and
> > simply check if we have 'right' suspects, so: git-net.patch and
> > git-nfsd.patch from -mm1-broken-out, as suggested by Herbert (I hope,
> > can compile - otherwise you could try the other way: add the whole -mm
> > and revert these two). Using current gits could complicate this
> > "investigation".
> 
> OK, I will try this...

It seems that this last report gives the third one: ieee1394 to the pack,
so probably, you can hold on a "minute" - this all needs some rethinking.
(But, if you've begun with this already, let it be clear at last too.)

> > I didn't read all this thread, so probably I miss many points, but are
> > you sure there are no problems with filesystem corruption around these
> > packets or where you compile(?) them (e.g. after these raid problems)?
> 
> For my setup: It's a gentoo system, so compiling packages is the
> normal way of installing something.
> The compile itself is done on a tmpfs so a filesystem corruption there
> should be rather impossible. ;)
> (The system has 4Gb RAM, so it doesn't even need to swap)
> The sources are taken from a nfsv4 share that is served from a
> different system. Also gentoo checksums all sources it will use.

Yes, since this was no problem with vanilla 2.6.24-rc6, I've probably
gone astray...

> If you think some other slub_debug might catch it, I would try this...

OK! But, in the meantime could you send your current .config? I wonder
e.g. if there could be used this new ieee1394 code from
init_ohci1394_dma.c?
 
You are really helpful, thanks,
Jarek P.
