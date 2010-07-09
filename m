From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 1/1] Bluetooth: hidp: Add support for hidraw   
 HIDIOCGFEATURE    and HIDIOCSFEATURE
Date: Fri, 09 Jul 2010 14:33:35 -0300
Message-ID: <1278696815.10421.137.camel@localhost.localdomain>
References: <1276467601-9066-1-git-send-email-alan@signal11.us>
	 <1278623485.10421.73.camel@localhost.localdomain>
	 <4C369CDC.9080104@signal11.us>
	 <1278662497.10421.94.camel@localhost.localdomain>
	 <4C371DE8.9020002@signal11.us>
	 <1278680790.10421.106.camel@localhost.localdomain>
	 <4C372CEE.3070109@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David S Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Michael Poole <mdpoole-IZmAEv5cUt1AfugRpC6u6w@public.gmane.org>,
	Bastien Nocera <hadess-0MeiytkfxGOsTnJN9+BGXg@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4C372CEE.3070109-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Alan,

> >>>>> I looked at this and I am bit worried that this should not be done in
> >>>>> this detail in the HIDP driver. Essentially HIDP is a pure transport
> >>>>> driver. It should not handle all these details. Can we make this a bit
> >>>>> easier for the transport drivers to support such features?
> >>>>>
> >>>>>            
> >>>> I put these changes (most notably the addition of hidp_get_raw_report())
> >>>> in hidp because that's where the parallel function
> >>>> hidp_output_raw_report() was already located. I figured the input should
> >>>> go with the output. That said, if there's a better place for both of
> >>>> them (input and output) to go, let me know where you think it should be,
> >>>> and I'll get them moved into the proper spot.
> >>>>
> >>>> I'm not sure what you mean about HIDP being a pure transport driver.
> >>>>
> >>>>          
> >>> what is usb-hid.ko doing here? I would expect a bunch of code
> >>> duplication with minor difference between USB and Bluetooth.
> >>>        
> >> usbhid doesn't have a lot of code for hidraw. Two functions are involved:
> >>       usbhid_output_raw_report()
> >>           - calls usb_control_msg() with Get_Report
> >>       usbhid_get_raw_report()
> >>           - calls usb_control_msg() with Set_Report
> >>               OR
> >>           - calls usb_interrupt_msg() on the Ouput pipe.
> >>
> >> This is of course easier than bluetooth because usb_control_msg() is
> >> synchronous, even when requesting reports, mostly because of the nature
> >> of USB, where the request and response are part of the same transfer.
> >>
> >> For Bluetooth, it's a bit more complicated since the kernel treats it
> >> more like a networking interface (and indeed it is). My understanding is
> >> that to make a synchronous transfer in bluetooth, one must:
> >>       - send the request packet
> >>       - block (wait_event_*())
> >>       - when the response is received in the input handler, wake_up_*().
> >>
> >> There's not really any code duplication, mostly because initiating
> >> synchronous USB transfers (input and output) is easy (because of the
> >> usb_*_msg() functions), while making synchronous Bluetooth transfers
> >> must be done manually. If there's a nice, convenient, synchronous
> >> function in Bluetooth similar to usb_control_msg() that I've missed,
> >> then let me know, as it would simplify this whole thing.
> >>      
> > there is not and I don't think we ever get one. My question here was
> > more in the direction why HID core is doing these synchronously in the
> > first place. Especially since USB can do everything async as well.
>
> I'm open to suggestions. The way I see it is from a user space 
> perspective. With Get_Feature being on an ioctl(), I don't see any clean 
> way to do it other than synchronously. Other operating systems (I can 
> say for sure Windows, Mac OS X, and FreeBSD) handle Get/Set Feature the 
> same way (synchronously) from user space.
> 
> You seem to be proposing an asynchronous interface. What would that look 
> like from user space?

not necessarily from user space, but at least from HID core to HIDP and
usb-hid transports. At least that is what I would expect, Jiri?

Regards

Marcel
