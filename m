From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [RESEND][PATCH] Bluetooth: Make request workqueue freezable
Date: Thu, 21 May 2015 22:46:34 +0200
Message-ID: <555E442A.808@broadcom.com>
References: <33C25745-6839-4858-9A3E-19EC6408ECED@holtmann.org>	<Pine.LNX.4.44L0.1505211112310.1397-100000@iolanthe.rowland.org>	<s5hsiaq3pv4.wl-tiwai@suse.de>	<555E158D.4090607@broadcom.com> <s5hmw0x4z12.wl-tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alan Stern <stern@rowland.harvard.edu>,
	Marcel Holtmann <marcel@holtmann.org>,
	Laura Abbott <labbott@redhat.com>,
	Oliver Neukum <oneukum@suse.com>,
	Ming Lei <ming.lei@canonical.com>,
	"David S. Miller" <davem@davemloft.net>,
	Laura Abbott <labbott@fedoraproject.org>,
	"Johan Hedberg" <johan.hedberg@gmail.com>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	"bluez mailin list (linux-bluetooth@vger.kernel.org)"
	<linux-bluetooth@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	USB list <linux-usb@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Takashi Iwai <tiwai@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <s5hmw0x4z12.wl-tiwai@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/21/15 19:32, Takashi Iwai wrote:
> At Thu, 21 May 2015 19:27:41 +0200,
> Arend van Spriel wrote:
>>
>> On 05/21/15 17:35, Takashi Iwai wrote:
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

So you are saying each device driver should come up with some retry 
mechanism. Would make more sense to come up with something like that 
behind the scenes in the firmware loader so all device drivers can rely 
on one and the same solution.

Regards,
Arend

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
>> but initrd is optional so without initrd it is pretty much the same.
>
> User can build the firmware into the kernel.
>
>
> Takashi
> --
> To unsubscribe from this list: send the line "unsubscribe linux-bluetooth" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
