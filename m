From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH v2 7/7] driver-core: add preferred async probe option for
 built-in and modules
Date: Tue, 7 Oct 2014 11:55:16 -0700
Message-ID: <CAB=NE6V_1yyYPhzbV_yRzt7fg=_8yF2YYNBz4qH_2TbH0nozcw@mail.gmail.com>
References: <1412372683-2003-1-git-send-email-mcgrof@do-not-panic.com>
 <1412372683-2003-8-git-send-email-mcgrof@do-not-panic.com>
 <20141006201926.GF18303@htj.dyndns.org> <20141006203627.GZ14081@wotan.suse.de>
 <20141006210118.GG18303@htj.dyndns.org> <20141006231046.GD14081@wotan.suse.de>
 <20141007173404.GB31328@mtj.dyndns.org> <20141007175010.GH14081@wotan.suse.de>
 <20141007175503.GE31328@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Takashi Iwai <tiwai@suse.de>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Tom Gundersen <teg@jklm.no>,
	Robert Milasan <rmilasan@suse.com>, werner@suse.com,
	Oleg Nesterov <oleg@redhat.com>, hare <hare@suse.com>,
	Benjamin Poirier <bpoirier@suse.de>,
	Santosh Rastapur <santosh@chelsio.com>,
	Petr Mladek <pmladek@suse.cz>, dbueso@suse.com,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnam
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20141007175503.GE31328@mtj.dyndns.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 7, 2014 at 10:55 AM, Tejun Heo <tj@kernel.org> wrote:
> Hello,
>
> On Tue, Oct 07, 2014 at 07:50:10PM +0200, Luis R. Rodriguez wrote:
>> On Tue, Oct 07, 2014 at 01:34:04PM -0400, Tejun Heo wrote:
>> > But you can create a new workqueue and queue all the async probing
>> > work items there and flush the workqueue right after
>> > async_synchronize_full().
>>
>> On second thought I would prefer to avoid this, I see this being good
>> to help with old userspace but other than that I don't see a requirement
>> for new userspace. Do you?
>
> Hmmm... we batch up and do everything parallel, so I'm not sure how
> much gain we'd be looking at by not waiting for at the end before
> jumping into the userland.  Also, it's a bit of an orthogonal issue.
> If we wanna skip such synchornization point before passing control to
> userland, why are we applying that to this but not
> async_synchronize_full() which has a far larger impact?  It's weird to
> synchronize one while not the other, so yeah, if there are actual
> benefits we can consider it but let's do it separately.

OK I'll just kill bus.enable_kern_async=1 to enable built-in async
probe support *and* also have prefer_async_probe *always* be
respected, whether modular or not.

  Luis
