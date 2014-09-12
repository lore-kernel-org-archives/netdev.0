From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Fri, 12 Sep 2014 13:14:22 -0700
Message-ID: <CAB=NE6XpYZEZ=uKj+T3BtofCHOToQDottzYXCENSTMyhx83Rvg@mail.gmail.com>
References: <CAB=NE6Vn3hA_VKJyi4kgMi6iMtTtA104-_UfFm6vgX14RoDOTw@mail.gmail.com>
 <20140909012933.GF11706@mtj.dyndns.org> <CAB=NE6V+of_RLQtjFpkLN49nKgfONx0T4cbu8kkNU69tUyNozw@mail.gmail.com>
 <20140909014754.GG11706@mtj.dyndns.org> <CAB=NE6VAe_96dezJmdXkOjy8mSz8EABX6i8C46GzUJRC-HLAZQ@mail.gmail.com>
 <20140909023943.GH11706@mtj.dyndns.org> <CAB=NE6XH64QLfwoE3r7uf3SYKNJMzP-tjUkrxDwVca7G2zOxBQ@mail.gmail.com>
 <20140909030353.GI11706@mtj.dyndns.org> <CAB=NE6UGNC7VHnkuv8huaVHLX3Kuh2kOTK92SCw07ehJ3LdXFg@mail.gmail.com>
 <20140909032529.GJ11706@mtj.dyndns.org> <20140909230333.GD3154@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay@vrfy.org>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Wu Zhangjin <falcon@meizu.com>, Takashi Iwai <tiwai@suse.de>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Oleg Nesterov <oleg@redhat.com>, hare <hare@suse.com>,
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
	Sreekan
To: Tejun Heo <tj@kernel.org>, Tom Gundersen <teg@jklm.no>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20140909230333.GD3154@mtj.dyndns.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 9, 2014 at 4:03 PM, Tejun Heo <tj@kernel.org> wrote:
> On Tue, Sep 09, 2014 at 12:25:29PM +0900, Tejun Heo wrote:
>> Hello,
>>
>> On Mon, Sep 08, 2014 at 08:19:12PM -0700, Luis R. Rodriguez wrote:
>> > On the systemd side of things it should enable this sysctl and for
>> > older kernels what should it do?
>>
>> Supposing the change is backported via -stable, it can try to set the
>> sysctl on all kernels.  If the knob doesn't exist, the fix is not
>> there and nothing can be done about it.
>
> The more I think about it, the more I think this should be a
> per-insmod instance thing rather than a system-wide switch.

Agreed, a good use case that comes to mind would be systemd's
modules-load.d lists used by systemd services to require modules, the
hooks there however likely expect probe to complete as part of the
service, since the timeout is not applicable to these the synchronous
probe for them would be good while systemd would use async probe for
regular modules.

> Currently
> the kernel param code doesn't allow a generic param outside the ones
> specified by the module itself but adding support for something like
> driver.async_load=1 shouldn't be too difficult, applying that to
> existing systems shouldn't be much more difficult than a system-wide
> switch, and it'd be siginificantly cleaner than fiddling with driver
> blacklist.

Agreed.

  Luis
