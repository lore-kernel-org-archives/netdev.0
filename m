From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Mon, 8 Sep 2014 18:38:34 -0700
Message-ID: <CAB=NE6V+of_RLQtjFpkLN49nKgfONx0T4cbu8kkNU69tUyNozw@mail.gmail.com>
References: <CAB=NE6Wti1RpAFk5q_YeZn2F9Rd=wsiwhyPszu74nG9fXwH5vQ@mail.gmail.com>
 <20140905141241.GC10455@mtj.dyndns.org> <20140905164405.GA28964@core.coreip.homeip.net>
 <20140905174925.GA12991@mtj.dyndns.org> <CAB=NE6VPTV39pNujOgO422wbUvU44HZ7s=aaxPVraNECqA6e4Q@mail.gmail.com>
 <20140905224047.GC15723@mtj.dyndns.org> <CAB=NE6Uz1VD5qpMFSBfQRV8ih9FQcCUhNtWMvD38t5hdDvix4Q@mail.gmail.com>
 <20140909011059.GB11706@mtj.dyndns.org> <20140909012227.GE11706@mtj.dyndns.org>
 <CAB=NE6Vn3hA_VKJyi4kgMi6iMtTtA104-_UfFm6vgX14RoDOTw@mail.gmail.com> <20140909012933.GF11706@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140909012933.GF11706@mtj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 8, 2014 at 6:29 PM, Tejun Heo <tj@kernel.org> wrote:
> On Mon, Sep 08, 2014 at 06:26:04PM -0700, Luis R. Rodriguez wrote:
>> > Alternatively, add a module-generic param "async_probe" or whatever
>> > and use that to switch the behavior should work too.  I don't know
>> > which way is better but either should work fine.
>>
>> I take it by this you meant a generic system-wide sysctl or kernel cmd
>> line option to enable this for al drivers?
>
> Well, either global or per-insmod switch should work.  There probably
> are details that I haven't mentioned - e.g. probably global switch is
> easier to backport and deploy to existing systems

Yes a global sysctl solution might make it easier to backport.

> - but as long as it
> works I don't have fundmental objections either way.

OK then one only concern I would have with this is that the presence
of such a flag doesn't necessarily mean that all drivers on a system
have been tested for asynch probe yet. I'd feel much more comfortable
if this global flag allowed say specific drivers that *did* have such
a bool enabled, for example. Then that would enable synchronous
behaviour for the kernel by default, require the flag for enabling the
new async feature but only for drivers that have been tested.

That also still would not technically solve the issue of the current
existence of the timeout, unless of course we wish to ask systemd to
only make the timeout take effect *iff* the global sysctl flag /
whatever was enabled.

  Luis
