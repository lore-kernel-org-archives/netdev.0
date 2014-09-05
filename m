From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Sat, 6 Sep 2014 02:49:25 +0900
Message-ID: <20140905174925.GA12991@mtj.dyndns.org>
References: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com>
 <CAB=NE6Wti1RpAFk5q_YeZn2F9Rd=wsiwhyPszu74nG9fXwH5vQ@mail.gmail.com>
 <20140905141241.GC10455@mtj.dyndns.org>
 <20140905164405.GA28964@core.coreip.homeip.net>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140905164405.GA28964@core.coreip.homeip.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Fri, Sep 05, 2014 at 09:44:05AM -0700, Dmitry Torokhov wrote:
> Which problem are we talking about here though? It does solve the slow device
> stalling the rest if the kernel booting (non-module case) for me.

The other one.  The one with timeout.  Neither cxgb4 or pata_marvell
has slow probing stalling boot problem.

> I also reject the notion that anyone should be relying on drivers to be fully
> bound on module loading. It is not nineties anymore. We have hot pluggable
> buses, deferred probing, and even for not hot-pluggable ones the module
> providing the device itself might not be yet loaded. Any scripts that expect to
> find device 100% ready after module loading are simply broken.

We've been treating loading + probing as a single operation when
loading drivers and the assumption has always been that the existing
devices at the time of loading finished probing by the time insmod
finishes.  We now need to split loading and probing and wait for each
of them differently.  The *only* thing we can do is somehow making the
issuer specify that it's gonna wait for probing separately.  I'm not
sure this can even be up for discussion.  We're talking about a major
userland visible behavior change.  We simply can't change it
underneath the existing users.

Thanks.

-- 
tejun
