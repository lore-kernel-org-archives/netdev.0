From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Sat, 6 Sep 2014 07:55:33 +0900
Message-ID: <20140905225533.GE15723@mtj.dyndns.org>
References: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com>
 <CAB=NE6Wti1RpAFk5q_YeZn2F9Rd=wsiwhyPszu74nG9fXwH5vQ@mail.gmail.com>
 <20140905141241.GC10455@mtj.dyndns.org>
 <20140905164405.GA28964@core.coreip.homeip.net>
 <20140905174925.GA12991@mtj.dyndns.org>
 <20140905181003.GA29003@core.coreip.homeip.net>
 <20140905222956.GA15723@mtj.dyndns.org>
 <20140905223139.GB15723@mtj.dyndns.org>
 <20140905224917.GB35667@core.coreip.homeip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Wu Zhangjin <falcon@meizu.com>, Takashi Iwai <tiwai@suse.de>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Oleg Nesterov <oleg@redhat.com>, hare@suse.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Benjamin Poirier <bpoirier@suse.de>,
	Santosh Rastapur <santosh@chelsio.com>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140905224917.GB35667@core.coreip.homeip.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Dmitry.

On Fri, Sep 05, 2014 at 03:49:17PM -0700, Dmitry Torokhov wrote:
> On Sat, Sep 06, 2014 at 07:31:39AM +0900, Tejun Heo wrote:
> > On Sat, Sep 06, 2014 at 07:29:56AM +0900, Tejun Heo wrote:
> > > It is for storage devices which always have guaranteed synchronous
> > > probing on module load and well-defined probing order.
> 
> Agree about probing order (IIRC that is why we had to revert the
> wholesale asynchronous probing a few years back) but totally disagree
> about synchronous module loading.

I don't get it.  This is a behavior userland already depends on for
boots.  What's there to agree or disagree?  This is just a fact that
we can't do this w/o disturbing some userlands in a major way.

> Anyway, I just posted a patch that I think preserves module loading
> behavior and solves my issue with built-in modules. It does not help
> Luis' issue though (but then I think the main problem is with systemd
> being stupid there).

This sure can be worked around from userland side too by not imposing
any timeout on module loading but that said for the same reasons that
you've been arguing until now, I actually do think that it's kinda
silly to make device probing synchronous to module loading at this
time and age.  What we disagree on is not that we want to separate
those waits.  It is about how to achieve it.

> > To add a bit, if the argument here is that dependency on such behavior
> > shouldn't exist and module loading and device probing should always be
> > asynchronous, the right approach is implementing "synchronous_probing"
> > flag not the other way around.  I actually wouldn't hate to see that
> > change happening but whoever submits and routes such a change should
> > be ready for a major shitstorm, I'm afraid.
> 
> I think we already had this storm and that is why here we have opt-in
> behavior for the drivers.

It's a different shitstorm where we actively break bootings on some
userlands.  Trust me.  That's gonna be a lot worse.

Thanks.

-- 
tejun
