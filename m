From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Moving drivers into staging (was Re: [GIT PULL] SCSI fixes for
	2.6.32-rc3)
Date: Wed, 14 Oct 2009 20:36:57 +0200
Message-ID: <20091014183657.GB5133@elte.hu>
References: <1255357148.2850.91.camel@localhost.localdomain> <20091012145453.GD4565@elte.hu> <20091012150911.GB1656@suse.de> <20091012154244.GA13323@elte.hu> <20091012232429.GA24254@suse.de> <43e72e890910131108m789110b4hc35e25601ad67bb7@mail.gmail.com> <20091014044519.GA19199@suse.de> <1255497575.1851.16.camel@Joe-Laptop.home> <20091014063308.GE784@elte.hu> <4AD60FF9.40200@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>, Greg KH <gregkh@suse.de>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	James Bottomley <James.Bottomley@suse.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Theodore Tso <tytso@mit.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Jing Huang <huangj@brocade.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4AD60FF9.40200@s5r6.in-berlin.de>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Stefan Richter <stefanr@s5r6.in-berlin.de> wrote:

> Ingo Molnar wrote:
> > * Joe Perches <joe@perches.com> wrote:
> > 
> >> On Tue, 2009-10-13 at 21:45 -0700, Greg KH wrote:
> >> > How about when it was scheduled to be removed, we put it in staging and
> >> > I'll add it to my announcements about the staging tree every release?
> >> > Unless you can think of a better way?
> >> 
> >> staging/to_be_removed_unless_fixed_by/v.x.y ?
> > 
> > Yes, that's a real worry. Some time ago i suggested:
> > 
> >   drivers/staging/good/
> >   drivers/staging/bad/
> >   drivers/staging/ugly/
> 
> How well do "git am", "quilt import" and friends cope with ever 
> changing directories?

Once a driver is in a tree it's in Git and git mv is easy. People 
working with Linux better familiarize themselves with Git workflow - the 
sooner the better.

If it's not in tree then it will adopt to whatever layout there is once 
it gets into Greg's tree. I dont see the problem.

> How about using drivers/staging/this_driver/TODO and (or) its Kconfig 
> help text to leave a note about the plans for this driver?

Well, the answer is obvious i think. Tell me, at a glance, if you see a 
patch on lkml, which one is for a staging driver to be obsoleted, and 
which one is the one going upstream real soon? The patches say:

 +++ a/drivers/staging/foo/x.c

 +++ a/drivers/staging/bar/y.c

Then tell me the same at a glance if you see patches for:

 +++ a/drivers/staging/wip/x.c

 +++ a/drivers/staging/bad/y.c

> The worry that these will be ignored like 
> Documentation/feature-removal-schedule.txt is being ignored may apply 
> to the path name based solution too, I'm afraid.

It wont be 'ignored', as it's in every patch, it's in every commit, it's 
in every substantial communication about that driver.

The problem with feature-removal-schedule.txt is that it's too much out 
of sight and not part of the regular patch workflow. Same goes for any 
TODO file. Experience has shown that the actual _path_ were drivers end 
up does matter quite a bit, to general visibility and to mindset.

That's one of the reasons why we have _half a thousand_ directories in 
drivers/ to begin with. The directory namespace is very powerful, and we 
use it to convey all sorts of information about the logical category a 
driver is in.

Using it in drivers/staging/ instead of the current flat hierarchy would 
thus be pretty natural.

	Ingo
