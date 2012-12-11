From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH][RFC] smsc95xx: enable dynamic autosuspend (RFC)
Date: Tue, 11 Dec 2012 20:53:19 +0800
Message-ID: <CACVXFVMNshNMJ+hYHTCfE2+UOuMgGLb0dKq8qEM-LfUseuy2qA@mail.gmail.com>
References: <1353607526-19307-6-git-send-email-steve.glendinning@shawell.net>
	<CAKh2mn5LgZBJDJWNzN8A3NK72Vk_fiUjJfmdn5njSrm400q36w@mail.gmail.com>
	<CACVXFVOBgwoSyUDzxD+ghjkpFu5PL7MuaS5UJOZYvVnV0dwhGg@mail.gmail.com>
	<1881907.JmjSTg2PBW@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Steve Glendinning <steve-nksJyM/082jR7s880joybQ@public.gmane.org>,
	Steve Glendinning <steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1881907.JmjSTg2PBW-ugxBuEnWX9yG/4A2pS7c2Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 11, 2012 at 6:27 PM, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org> wrote:
> On Tuesday 11 December 2012 10:24:57 Ming Lei wrote:
>> On Mon, Dec 10, 2012 at 10:18 PM, Steve Glendinning <steve-nksJyM/082jR7s880joybQ@public.gmane.org> wrote:
>
>> > Thanks, so something like this should do the job?
>>
>> This will do, but not simple as clearing .manage_power function
>> pointer in bind(), and still disable runtime suspend for link off case
>> since these devices which don't support suspend 3 can generate
>> remote wakeup for link change event.
>
> So they can autosuspend if the interface is up and no cable is plugged
> in?

>From the open datasheet, that is the suspend 1 mode, which is supported
by all LAN95xx devices. Steve, correct me if I am wrong.

>
>> I suggest to introduce link-off triggered runtime suspend for these
>> usbnet devices(non-LAN9500A device, devices which don't support
>> USB auto-suspend), and I have posted one patch set before[1].
>> If no one objects that, I'd like to post them again with some fix and
>> update for checking link after link_reset().
>
> If you can get rid of a periodic work this would be great.

For the LAN95xx devices, the periodic work isn't needed because
they may generate remote wakeup when link change is detected.

In fact, I have test data which can show a much power save
on OMAP3 based beagle board plus asix usbnet device with
the periodic work. IMO, the power save after introducing periodic
timer depends on the arch or platform, there should be much power
save if the CPU power consumption is very less. So how about letting
module parameter switch on/off the periodic work?


Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
