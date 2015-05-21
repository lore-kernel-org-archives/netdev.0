From: Laura Abbott <labbott@redhat.com>
Subject: Re: [RESEND][PATCH] Bluetooth: Make request workqueue freezable
Date: Thu, 21 May 2015 11:17:21 -0700
Message-ID: <555E2131.60306@redhat.com>
References: <s5hsiaq3pv4.wl-tiwai@suse.de>	<Pine.LNX.4.44L0.1505211332520.1397-100000@iolanthe.rowland.org> <s5hk2w14x8b.wl-tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Oliver Neukum <oneukum@suse.com>,
	Ming Lei <ming.lei@canonical.com>,
	"David S. Miller" <davem@davemloft.net>,
	Laura Abbott <labbott@fedoraproject.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	"bluez mailin list (linux-bluetooth@vger.kernel.org)"
	<linux-bluetooth@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	USB list <linux-usb@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Takashi Iwai <tiwai@suse.de>,
	Alan Stern <stern@rowland.harvard.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <s5hk2w14x8b.wl-tiwai@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/21/2015 11:11 AM, Takashi Iwai wrote:
> At Thu, 21 May 2015 13:37:56 -0400 (EDT),
> Alan Stern wrote:
>>
>> On Thu, 21 May 2015, Takashi Iwai wrote:
>>
>>> At Thu, 21 May 2015 11:26:17 -0400 (EDT),
>>> Alan Stern wrote:
>>>>
>>>> On Thu, 21 May 2015, Takashi Iwai wrote:
>>>>
>>>>> At Thu, 21 May 2015 10:18:08 -0400 (EDT),
>>>>> Alan Stern wrote:
>>>>>>
>>>>>> On Thu, 21 May 2015, Takashi Iwai wrote:
>>>>>>
>>>>>>> Then avoiding the failed firmware is no solution, indeed.
>>>>>>> If it's a new probe, it should be never executed during resume.
>>>>>>
>>>>>> Can you expand this comment?  What's wrong with probing during resume?
>>>>>
>>>>> Well, if the probe requires the access to a user-space file, it can't
>>>>> be done during resume.  That's the very problem we're seeing now.
>>>>> The firmware loader can't help much alone if it's a new device
>>>>> object.
>>>>
>>>> But the same thing happens during early boot, if the driver is built
>>>> into the kernel.  When the probe occurs, userspace isn't up and running
>>>> yet, so the firmware loader can't do anything.
>>>>
>>>> Why should probe during resume be any worse than probe during early
>>>> boot?
>>>
>>> The early boot has initrd, so the files can be there.  But the resume
>>> has no way to fetch the file except for cached data.
>>
>> I suppose USB could delay re-probing until userspace is running again,
>> if we knew when that was.  But it would be awkward and prone to races.
>> It also would leave a user-visible window of time during which the
>> device does not exist, which we want to avoid.  (This may not matter
>> for bluetooth, but it does matter for other kinds of devices.)
>
> Right.
>
>> I would prefer to solve this problem in a different way, if possible.
>
> Well, we're back in square again :)
>
> But, before going further the discussion in loop again, I'd like to
> know which firmware file actually hits.  Is it a non-existing
> firmware?  Or is it a firmware that should have been cached?  In the
> latter case, why it isn't used?
>

Non-existent firmware. The firmware was never present in the system and
was never loaded at all.

>
> Takashi
>

Thanks,
Laura
