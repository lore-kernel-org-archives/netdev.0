From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Tue, 9 Sep 2014 10:47:54 +0900
Message-ID: <20140909014754.GG11706@mtj.dyndns.org>
References: <20140905164405.GA28964@core.coreip.homeip.net>
 <20140905174925.GA12991@mtj.dyndns.org>
 <CAB=NE6VPTV39pNujOgO422wbUvU44HZ7s=aaxPVraNECqA6e4Q@mail.gmail.com>
 <20140905224047.GC15723@mtj.dyndns.org>
 <CAB=NE6Uz1VD5qpMFSBfQRV8ih9FQcCUhNtWMvD38t5hdDvix4Q@mail.gmail.com>
 <20140909011059.GB11706@mtj.dyndns.org>
 <20140909012227.GE11706@mtj.dyndns.org>
 <CAB=NE6Vn3hA_VKJyi4kgMi6iMtTtA104-_UfFm6vgX14RoDOTw@mail.gmail.com>
 <20140909012933.GF11706@mtj.dyndns.org>
 <CAB=NE6V+of_RLQtjFpkLN49nKgfONx0T4cbu8kkNU69tUyNozw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay@vrfy.org>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
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
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Redd
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAB=NE6V+of_RLQtjFpkLN49nKgfONx0T4cbu8kkNU69tUyNozw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Mon, Sep 08, 2014 at 06:38:34PM -0700, Luis R. Rodriguez wrote:
> OK then one only concern I would have with this is that the presence
> of such a flag doesn't necessarily mean that all drivers on a system
> have been tested for asynch probe yet. I'd feel much more comfortable

Given that the behvaior change is from driver core and that device
probing can happen post-loading anyway, I don't think we need to worry
about drivers breaking from probing made asynchronous to loading.  The
problem is the expectation of the entity which initiated loading of
the module.  If it's depending on device being probed synchronously
but insmod returns before that, it can break things.  We probably
should audit request_module() users and see which ones expect such
behavior.

> if this global flag allowed say specific drivers that *did* have such
> a bool enabled, for example. Then that would enable synchronous
> behaviour for the kernel by default, require the flag for enabling the
> new async feature but only for drivers that have been tested.

If we're gonna do the global switch, I personally think the right
approach is blacklisting instead of the other way around because each
specific driver doesn't really have much to do with it and the
exceptions are about specific use cases that we don't have a good way
to identify them from module loading path.

> That also still would not technically solve the issue of the current
> existence of the timeout, unless of course we wish to ask systemd to
> only make the timeout take effect *iff* the global sysctl flag /
> whatever was enabled.

Userland could backport a fix to set the sysctl.  Given that we need
both synchrnous and asynchronous behaviors, it's unlikely that we can
come up with a solution which doesn't need cooperation from userland.

Thanks.

-- 
tejun
