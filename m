From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Wed, 23 Dec 2009 14:07:20 +0100
Message-ID: <200912231407.20130.bzolnier@gmail.com>
References: <4B1D4F29.8020309@gmail.com> <4B30F214.80206@codemonkey.ws> <20091223065129.GA19600@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Andi Kleen <andi@firstfloor.org>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	Avi Kivity <avi@redhat.com>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20091223065129.GA19600@elte.hu>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 23 December 2009 07:51:29 am Ingo Molnar wrote:
> 
> * Anthony Liguori <anthony@codemonkey.ws> wrote:
> 
> > On 12/22/2009 10:01 AM, Bartlomiej Zolnierkiewicz wrote:
> > >>new e1000 driver is more superior in architecture and do the required
> > >>work to make the new e1000 driver a full replacement for the old one.
> > >Right, like everyone actually does things this way..
> > >
> > >I wonder why do we have OSS, old Firewire and IDE stacks still around then?
> > 
> > And it's always a source of pain, isn't it.
> 
> Even putting aside the fact that such overlap sucks and is a pain to users 
> (and that 98% of driver and subsystem version transitions are done completely 
> seemlessly to users - the examples that were cited were the odd ones out of 
> 150K commits in the past 4 years, 149K+ of which are seemless), the comparison 
> does not even apply really.

Total commit number has nothing to do with the issue raised since the problem
is in the total source code complexity and the need to maintain separate code
bases.

[ BTW I find your habit of bringing the completely unrelated numbers into
  the discussion quite annoying.  Do you really think that throwing in some
  random numbers automatically increases the credibility of your opinion? ]

> e1000, OSS, old Firewire and IDE are hardware stacks, where hardware is a not 
> fully understood externality, with its inevitable set of compatibility voes. 
> There's often situations where one piece of hardware still works better with 
> the old driver, for some odd (or not so odd) reason.
> 
> Also, note that the 'new' hw drivers are generally intended and are maintained 
> as clear replacements for the old ones, and do so with minimal ABI changes - 
> or preferably with no ABI changes at all. Most driver developers just switch 
> from old to new and the old bits are left around and are phased out. We phased 
> out old OSS recently.

'We' as Fedora?

old OSS stuff is still there (sound/oss/ which is almost 45KLOC and would
be much more if not past efforts from Adrian Bunk to shrink it down)

Besides 'phase out' that you are talking about comes down to just waiting
for old hardware/user base to die and it takes years to accomplish..

I can understand how this is not an issue from i.e. Red Hat's POV when you
have one 'set in the stone' set of drivers in RHEL and the other 'constant
development flux' one in Fedora (which because of this fact cannot be no
longer consider as real distribution for real users BTW) but for everybody
else this is simply untrue.

> That is a very different situation from the AlacrityVM patches, which:
> 
>  - Are a pure software concept and any compatibility mismatch is
>    self-inflicted. The patches are in fact breaking the ABI to KVM 
>    intentionally (for better or worse).

Care to explain the 'breakage' and why KVM is more special in this regard
than other parts of the kernel (where we don't keep any such requirements)?

Truth to be told KVM is just another driver/subsystem and Gregory's changes
are only 4KLOC of clean and easily maintainable code..

>  - Gregory claims that the AlacricityVM patches are not a replacement for KVM.
>    I.e. there's no intention to phase out any 'old stuff' and it splits the 
>    pool of driver developers.

Talk double standards.  It was you & co. that officially legitimized this
style of doing things and now you are complaining about it?

> i.e. it has all the makings of a stupid, avoidable, permanent fork. The thing 
> is, if AlacricityVM is better, and KVM developers are not willing to fix their 
> stuff, replace KVM with it.
> 
> It's a bit as if someone found a performance problem with sys_open() and came 
> up with sys_open_v2() and claimed that he wants to work with the VFS 
> developers while not really doing so but advances sys_open_v2() all the time. 
> 
> Do we allow sys_open_v2() upstream, in the name of openness and diversity, 
> letting some apps use that syscall while other apps still use sys_open()? Or 
> do we say "enough is enough of this stupidity, come up with some strong 
> reasons to replace sys_open, and if so, replace the thing and be done with the 
> pain!".

I certainly missed the time when KVM became officially part of core ABI..

> Overlap and forking can still be done in special circumstances, when a project 
> splits and a hostile fork is inevitable due to prolongued and irreconcilable 
> differences between the parties and if there's no strong technical advantage 
> on either side. I havent seen evidence of this yet though: Gregory claims that 
> he wants to 'work with the community' and the KVM guys seem to agree violently 
> that performance can be improved - and are doing so (and are asking Gregory to 
> take part in that effort).

How it is different from any past forks?

The odium of proving that the existing framework is sufficient was always on
original authors or current maintainers.

KVM guys were offered assistance from Gregory and had few months to prove that
they can get the same kind of performance using existing architecture and they
DID NOT do it.

> The main difference is that Gregory claims that improved performance is not 
> possible within the existing KVM framework, while the KVM developers disagree. 
> 
> The good news is that this is a hard, testable fact.
> 
> I think we should try _much_ harder before giving up and forking the ABI of a 
> healthy project and intentionally inflicting pain on our users.

Then please try harder.  Gregory posted his initial patches in August,
it is December now and we only see artificial road-blocks instead of code
from KVM folks.

> And, at minimum, such kinds of things _have to_ be pointed out in pull 
> requests, because it's like utterly important. In fact i couldnt list any more 
> important thing to point out in a pull request.

I think that this part should be easily fixable..

--
Bartlomiej Zolnierkiewicz
