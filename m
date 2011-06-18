From: Marius Kotsbak <marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net/usb: Add Samsung Kalmia driver for Samsung GT-B3730
Date: Sat, 18 Jun 2011 22:03:18 +0200
Message-ID: <4DFD0486.7040300@gmail.com>
References: <1307748870-12950-1-git-send-email-marius@kotsbak.com>	 <1307977039.2117.7.camel@dcbw.foobar.com> <4DF62656.8060506@gmail.com> <1307978364.2117.11.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Marius B. Kotsbak" <marius-iy5w9mehe2BBDgjK7y7TUQ@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1307978364.2117.11.camel-wKZy7rqYPVb5EHUCmHmTqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 13. juni 2011 17:19, Dan Williams wrote:
> On Mon, 2011-06-13 at 17:01 +0200, Marius Kotsbak wrote:
>> On 13. juni 2011 16:57, Dan Williams wrote:
>>>
>>> Why make the driver bind to both the switched and unswitched USB IDs?
>>> Shouldn't the kernel bind the driver after switch when the device
>>> reconnects with the new IDs?
>> No, I tried and it did not happen, so I assumed that the kernel modules
>> are only loaded at USB insertion event, not when the interfaces changes.
>> Does anyone here know if my observation is right?
>>
>> Usb_modeswitch autoloads "option" module after switching, but not my
>> kalmia module.
> Try killing the modeswitch autoload thing first by moving the udev
> script out of the way.  Then plug your device in, and run
> "usb-modeswitch -c /path/to/config" so that the usb_modeswitch autoload
> thing doesn't run.  Does that work?  I don't want to slander
> usb_modeswitch but I've seen some odd behavior which I suspect is it's
> module force-loading feature, though I haven't investigated too much
> yet.  But ruling that out could be helpful.

I tried that now, and the "option" module does not load after switch,
even though it is supposed to recognize the switched modem interface
(but not the unswitched):

alias:          usb:v04E8p6889d*dc*dsc*dp*ic0Aisc00ip00*

I guess what is happening is that the modem just changes it internal
state to give another usb configuration, but only when requested by the
host (as at modem insertion). The reason "option" module is normally
loaded is that usb_modeswitch does it explicit, but it does not know
that it should insert the "kalmia" module.

Thus I leave the unswitched USB ID there if not anyone has any better
working solution.

--
Marius


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
