From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH 1/2] smsc75xx: refactor entering suspend modes
Date: Tue, 27 Nov 2012 19:12:38 +0100
Message-ID: <87y5hm9ap5.fsf@nemi.mork.no>
References: <1354026482-10443-1-git-send-email-steve.glendinning@shawell.net>
	<1354026482-10443-2-git-send-email-steve.glendinning@shawell.net>
	<87624r9k1f.fsf@nemi.mork.no>
	<CAKh2mn4OiN7ZAX_0SJ_XHwRNPoyKUk=+4ha5esBMAajGD4BX=w@mail.gmail.com>
	<CAKh2mn7f94a7La_EQ9L_qwr7FZEXfawUiAajPMDO8ScS2fJupg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Steve Glendinning <steve-nksJyM/082jR7s880joybQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAKh2mn7f94a7La_EQ9L_qwr7FZEXfawUiAajPMDO8ScS2fJupg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Steve Glendinning's message of "Tue, 27 Nov 2012 17:55:33 +0000")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Steve Glendinning <steve-nksJyM/082jR7s880joybQ@public.gmane.org> writes:

> Hi Bjorn,
>
> On 27 November 2012 17:21, Steve Glendinning <steve-nksJyM/082jR7s880joybQ@public.gmane.org> wrot=
e:
>> Hi Bjorn,
>>
>>>> +     smsc75xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
>>>
>>> As mentioned in another comment to the smsc95xx driver: This is wei=
rd.
>>> Do you really need to do that?
>>>
>>> This is an USB interface driver.  The USB device is handled by the
>>> generic "usb" driver, which will do the right thing.  See
>>> drivers/usb/generic.c and drivers/usb/core/hub.c
>>
>> Thanks, I've tested removing all these calls from the driver and
>> wakeup functionality seems to still work.
>>
>> I'll resubmit my smsc75xx enhancement patchset with this change once
>> I've done some more testing.
>
> Further testing shows that removing these calls stop wakeup from
> system suspend working (although don't appear to impact runtime
> autosuspend).  Have I missed a flag or somewhere that causes
> udev->do_remote_wakeup to be set in the code you posted?

udev->do_remote_wakeup is set in choose_wakeup() in
drivers/usb/core/driver.c.  AFAICS it is always set as long as
device_may_wakeup(&udev->dev) is true.

But I am just trying to get a grasp of this code.  Others on the
linux-usb list will know these things much better than me...

Just a thought: Did you remember to remove the clear_feature you have i=
n
resume?


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
