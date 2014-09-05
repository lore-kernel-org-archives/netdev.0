From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Fri, 05 Sep 2014 16:05:30 -0700
Message-ID: <540A41BA.4010105@linux.intel.com>
References: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com> <CAB=NE6Wti1RpAFk5q_YeZn2F9Rd=wsiwhyPszu74nG9fXwH5vQ@mail.gmail.com> <20140905141241.GC10455@mtj.dyndns.org> <20140905164405.GA28964@core.coreip.homeip.net> <20140905174925.GA12991@mtj.dyndns.org> <20140905181003.GA29003@core.coreip.homeip.net> <20140905222956.GA15723@mtj.dyndns.org> <540A3CF4.5070508@linux.intel.com> <20140905225248.GC35667@core.coreip.homeip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <tj@kernel.org>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Wu Zhangjin <falcon@meizu.com>, Takashi Iwai <tiwai@suse.de>,
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
	Abhijit Mahajan <abhiji
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140905225248.GC35667@core.coreip.homeip.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/5/2014 3:52 PM, Dmitry Torokhov wrote:
> On Fri, Sep 05, 2014 at 03:45:08PM -0700, Arjan van de Ven wrote:
>> On 9/5/2014 3:29 PM, Tejun Heo wrote:
>>> Hello, Dmitry.
>>>
>>> On Fri, Sep 05, 2014 at 11:10:03AM -0700, Dmitry Torokhov wrote:
>>>> I do not agree that it is actually user-visible change: generally speaking you
>>>> do not really know if device is there or not. They come and go. Like I said,
>>>> consider all permutations, with hot-pluggable buses, deferred probing, etc,
>>>
>>> It is for storage devices which always have guaranteed synchronous
>>> probing on module load and well-defined probing order.  Sure, modern
>>> setups are a lot more dynamic but I'm quite certain that there are
>>> setups in the wild which depend on storage driver loading being
>>> synchronous.  We can't simply declare one day that such behavior is
>>> broken and break, most likely, their boots.
>>
>> we even depend on this in the mount-by-label cases
>>
>> many setups assume that the internal storage prevails over the USB stick in the case of conflicts.
>> it's a security issue; you don't want the built in secure bootloader that has a kernel root argument
>> by label/uuid.
>> the security there tends to assume that built-in wins over USB
>
> Ahem... and they sure it works reliably with large storage arrays? With
> SCSI doing probing asynchronously already?

you tend to trust your large storage array
you tend to not trust the walk up USB stick.
