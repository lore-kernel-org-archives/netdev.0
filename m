From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Sat, 6 Sep 2014 07:40:47 +0900
Message-ID: <20140905224047.GC15723@mtj.dyndns.org>
References: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com>
 <CAB=NE6Wti1RpAFk5q_YeZn2F9Rd=wsiwhyPszu74nG9fXwH5vQ@mail.gmail.com>
 <20140905141241.GC10455@mtj.dyndns.org>
 <20140905164405.GA28964@core.coreip.homeip.net>
 <20140905174925.GA12991@mtj.dyndns.org>
 <CAB=NE6VPTV39pNujOgO422wbUvU44HZ7s=aaxPVraNECqA6e4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>,
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
	Abhijit Ma
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAB=NE6VPTV39pNujOgO422wbUvU44HZ7s=aaxPVraNECqA6e4Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Luis.

On Fri, Sep 05, 2014 at 11:12:17AM -0700, Luis R. Rodriguez wrote:
> Meanwhile we are allowing a major design consideration such as a 30
> second timeout for both init + probe all of a sudden become a hard
> requirement for device drivers. I see your point but can't also be
> introducing major design changes willy nilly either. We *need* a
> solution for the affected drivers.

Yes, make the behavior specifically specified from userland.  When did
I ever say that there should be no solution for the problem?  I've
been saying that the behavior should be selected from userland from
the get-go, haven't I?

I have no idea how the seleciton should be.  It could be per-insmod or
maybe just a system-wide flag with explicit exceptions marked on
drivers is good enough.  I don't know.

> Also what stops drivers from going ahead and just implementing their
> own async probe? Would that now be frowned upon as it strives away

The drivers can't.  How many times should I explain the same thing
over and over again.  libata can't simply make probing asynchronous
w.r.t. module loading no matter how it does it.  Yeah, sure, there can
be other drivers which can do that without most people noticing it but
a storage driver isn't one of them and the storage drivers are the
problematic ones already, right?

> from the original design? The bool would let those drivers do this
> easily, and we would still need to identify these drivers, although
> this particular change can be NAK'd Oleg's suggestion on
> WARN_ON(fatal_signal_pending() at the end of load_module() seems to me
> at least needed. And if its not async probe... what do those with
> failed drivers do?

I'm getting tired of explaining the same thing over and over again.
The said change was nacked because the whole approach of "let's see
which drivers get reported on the issue which exists basically for all
drivers and just change the behavior of them" is braindead.  It makes
no sense whatsoever.  It doesn't address the root cause of the problem
while making the same class of drivers behave significantly
differently for no good reason.  Please stop chasing your own tail and
try to understand the larger picture.

Thanks.

-- 
tejun
