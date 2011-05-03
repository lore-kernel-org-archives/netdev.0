From: Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] net: fix rtnl even race in register_netdevice()
Date: Tue, 03 May 2011 05:38:43 +0300
Message-ID: <87mxj4h5jg.fsf@purkki.adurom.net>
References: <20110429172634.27130.25375.stgit@x201>
	<20110429.135339.200375209.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110429.135339.200375209.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (David Miller's message of "Fri\, 29 Apr 2011 13\:53\:39 -0700 \(PDT\)")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> writes:

> From: Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org>
> Date: Fri, 29 Apr 2011 20:26:34 +0300
>
>> From: Kalle Valo <kalle.valo-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
>> 
>> There's a race in register_netdevice so that the rtnl event is sent before
>> the device is actually ready. This was visible with flimflam, chrome os
>> connection manager:

[...]

>> The fix is to call netdev_register_kobject() after the device is added
>> to the list.
>> 
>> Signed-off-by: Kalle Valo <kalle.valo-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
>
> This is not correct.
>
> If you move the kobject registry around, you have to change the
> error handling cleanup to match.
>
> This change will leave the netdevice on all sorts of lists, it will
> also leak a reference to the device.
>
> I also think this points a fundamental problem with this change, in
> that you can't register the kobject after the device is added to
> the various lists in list_netdevice().
>
> Once it's in those lists, any thread of control can find the device
> and those threads of control may try to get at the data backed by
> the kobject and therefore they really expect it to be there by
> then.
>
> What you can do instead is try to delay the NETREG_REGISTERED
> setting, and block the problematic notifications by testing
> reg_state or similar.

Thanks for the review. I'll investigate more about this and send v2
once I found a better solution.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
