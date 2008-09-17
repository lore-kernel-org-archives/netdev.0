From: Paul Moore <paul.moore@hp.com>
Subject: Re: [Bug #11500] /proc/net bug related to selinux
Date: Wed, 17 Sep 2008 18:12:59 -0400
Message-ID: <200809171812.59693.paul.moore@hp.com>
References: <j3zWxt-CgYL.A.WTF.bbsyIB@albercik> <200809171724.36269.paul.moore@hp.com> <20080917144842.7df59f9e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: sds@tycho.nsa.gov, jmorris@namei.org, rjw@sisk.pl,
	linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755834AbYIQWNW@vger.kernel.org>
In-Reply-To: <20080917144842.7df59f9e.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 17 September 2008 5:48:42 pm Andrew Morton wrote:
> On Wed, 17 Sep 2008 17:24:36 -0400
>
> Paul Moore <paul.moore@hp.com> wrote:
> > On Wednesday 17 September 2008 3:50:53 pm Andrew Morton wrote:
> > > On Mon, 15 Sep 2008 09:05:26 -0400
> > >
> > > Stephen Smalley <sds@tycho.nsa.gov> wrote:
> > > > However, the most likely explanation is simply that when
> > > > /proc/net was changed from being a directory to being a symlink
> > > > to /proc/self/net, that introduced an additional permission
> > > > check on accesses of /proc/net/<whatever>, namely the read
> > > > check on the symlink itself. And since that check wasn't
> > > > happening on /proc/net accesses with older kernels, older
> > > > policies didn't allow it.
> > > >
> > > > As to why others haven't reported it, I expect that they have
> > > > updated their policies to newer ones that allow the necessary
> > > > access.  The fact that legacy distros wouldn't have such
> > > > updated policies isn't surprising - they don't push updates to
> > > > those distros for new kernels.  FC5 and FC6 are both EOL'd,
> > > > right?
> > > >
> > > > In any event, we didn't change anything in SELinux - the change
> > > > was elsewhere (in the proc/net implementation).  Don't blame
> > > > the messenger please.
> > >
> > > Vanilla FC5 broke and vanilla FC6 broke.  Did vanilla FC7, 8 or 9
> > > break?
> > >
> > > http://smolt.fedoraproject.org/static/stats/stats.html shows
> > > 11,000-odd people running FC5 and FC6.  It would be incautious to
> > > assume that all those people have updated their selinux rules.
> > >
> > > And _requiring_ people to update their selinux rules to fix a
> > > kernel-caused regression is a pretty big deal for some people, I
> > > expect.
> >
> > Just so I'm clear on the context of the problem, it sounds like if
> > a FC5 (I'm limiting myself to FC5 for the moment) user upgraded to
> > a recent (2.6.25+) kernel (non-distro supplied in the case of FC5)
> > then they will run into problems unless they also upgrade their
> > SELinux policy, yes?
>
> That only true if the 2.6.25+ kernel.org kernel is
> backward-incompatible with the distro kernel.

Yep, just wanted to make sure I was understanding the problem correctly.

> > If that is the case I'm not sure it is really that big of a deal. 
> > Maybe I'm in the minority here, but in my mind once you step away
> > from the distro supplied kernel (also applies to other packages,
> > although those are arguably less critical) you should also bear the
> > responsibility to make sure you upgrade/tweak/install whatever
> > other bits need to be fixed.
>
> Nope.  Releasing a non-backward-compatible kernel.org kernel is a big
> deal.

Well, there is also the issue of distro specific "special sauce" patches 
which might cause different behavior from the kernel.org kernel, but 
now we are starting to do down a rat hole ...

> We'll do it sometimes, with long notice, much care and much
> deliberation.
>
> We did it this time by sheer accident.  That's known in the trade as
> a "bug".

It is somewhat comforting to know that we can call what we do a "trade", 
further commentary on my part is best left to the imagination :)

> > > Then again, given that this regression has been out there since
> > > 2.6.25, I guess not too many people are hurting from it.  But we
> > > suck.
> >
> > We suck?  Maybe, but some explanation about why we suck in this
> > particular case would be helpful as far as I'm concerned.  I don't
> > really care about identifying the guilty suckees, I'm more
> > interested in finding out what happened to cause us to suck because
> > of this.
>
> Because we unintentionally and unknowingly released a kernel which is
> not compatible with previous kernels without notifying any of our
> users and without any consideration or planning.
>
> Yes, often the consequences of the screwup are fairly small, but it's
> a screwup nonetheless.

Okay, so we suck because broke something in 2.6.25 that went undetected 
because current SELinux policies happen to be compatible with the 
breakage.  Gotcha.

> We don't even know the extent of the damage yet.  Which distros were
> affected? With which versions of which userspace packages?

Can I assume that the "right" thing to do would be to find the problem 
and revert whatever change caused the issue, yes?  Or are we happy to 
wait and see since the fallout so far has been minimal?

-- 
paul moore
linux @ hp
