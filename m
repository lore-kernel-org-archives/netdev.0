From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Mon, 8 Sep 2014 20:19:12 -0700
Message-ID: <CAB=NE6UGNC7VHnkuv8huaVHLX3Kuh2kOTK92SCw07ehJ3LdXFg@mail.gmail.com>
References: <CAB=NE6Uz1VD5qpMFSBfQRV8ih9FQcCUhNtWMvD38t5hdDvix4Q@mail.gmail.com>
 <20140909011059.GB11706@mtj.dyndns.org> <20140909012227.GE11706@mtj.dyndns.org>
 <CAB=NE6Vn3hA_VKJyi4kgMi6iMtTtA104-_UfFm6vgX14RoDOTw@mail.gmail.com>
 <20140909012933.GF11706@mtj.dyndns.org> <CAB=NE6V+of_RLQtjFpkLN49nKgfONx0T4cbu8kkNU69tUyNozw@mail.gmail.com>
 <20140909014754.GG11706@mtj.dyndns.org> <CAB=NE6VAe_96dezJmdXkOjy8mSz8EABX6i8C46GzUJRC-HLAZQ@mail.gmail.com>
 <20140909023943.GH11706@mtj.dyndns.org> <CAB=NE6XH64QLfwoE3r7uf3SYKNJMzP-tjUkrxDwVca7G2zOxBQ@mail.gmail.com>
 <20140909030353.GI11706@mtj.dyndns.org>
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
In-Reply-To: <20140909030353.GI11706@mtj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 8, 2014 at 8:03 PM, Tejun Heo <tj@kernel.org> wrote:
> On Mon, Sep 08, 2014 at 07:57:28PM -0700, Luis R. Rodriguez wrote:
>> > I think we
>> > just should make exceptions sensible so that it works fine in practice
>> > for now (and I don't think that'd be too hard).  So, the only
>> > cooperation necessary from userland would be just saying "I don't
>> > wanna wait for device probing on module load."
>>
>> But we're talking about drivers that have a flag that says 'you gotta
>> wait sucker', what do we want systemd to do then? I'd be happy if it'd
>> would not send the sigkill for these drivers, for example.
>
> Hah?  Can you give me an example?  I'm having hard time imagining a
> driver with such requirement given our current driver core
> implementation.

I didn't say I had one in mind, but if you're certain these *shouldn't
exist* that's sufficient by me as well.

OK so I'll respin this series to enable a sysctl that would enable
async probe for *all drivers* using queue_work(system_unbound_wq) and
only use sync probe for now on request_module() users, we'll address
scheduling issues as they come up. I'll be ignoring built-in.

On the systemd side of things it should enable this sysctl and for
older kernels what should it do?

 Luis
