From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 1/2] usbnet: allow status interrupt URB to always be active
Date: Fri, 11 Jan 2013 11:06:00 +0800
Message-ID: <CACVXFVOAjHMxRC=uok-OWPYjw-7D1MSnbaWo97LcGFAVRq+o2g@mail.gmail.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<1357318096.5370.15.camel@dcbw.foobar.com>
	<2212516.GkG3xP33yG@linux-5eaq.site>
	<1357349193.19684.3.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Rory Filer <rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Phil Sutter <phil-ydcDiazATMQ@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1357349193.19684.3.camel-wKZy7rqYPVb5EHUCmHmTqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 5, 2013 at 9:26 AM, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Fri, 2013-01-04 at 23:16 +0100, Oliver Neukum wrote:
>> On Friday 04 January 2013 10:48:16 Dan Williams wrote:
>> > Some drivers (ex sierra_net) need the status interrupt URB
>> > active even when the device is closed, because they receive
>> > custom indications from firmware.  Allow sub-drivers to set
>> > a flag that submits the status interrupt URB on probe and
>> > keeps the URB alive over device open/close.  The URB is still
>> > killed/re-submitted for suspend/resume, as before.
>> >
>> > Signed-off-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>> > ---
>> > Oliver: alternatively, is there a problem with *always*
>> > submitting the interrupt URB, and then simply not calling
>> > the subdriver's .status function when the netdev is
>> > closed?  That would be a much simpler patch.
>>
>> That is quite radical. We have no idea what a device
>> does when we do not react to a status update. I would
>> much prefer to not take the risk.
>> Besides, we don't use bandwidth if we don't have to.
>
> Ok, so scratch the alternative.  Thus, does the posted patch look like
> the right course of action?
>
> If I wasn't clear enough before, sierra_net needs to listen to the
> status interrupt URB to receive the custom Restart indication as part of
> the driver's device setup.  Thus for sierra_net at least, tying the

I am curious who are interested in the 'custom Restart indication'
information after the interface is closed.

If sierra_net provides ways(such as read registers) to query the
indication event, you can just query the information and setup
the device in driver_info->reset() during device open, so you can
avoid submitting interrupt URB always.

> status interrupt URB submission to device open/close isn't right.

In theory, drivers should support to report its link status
even it is closed, but looks no much actual usage, so guys opt to
submit the interrupt URB only after it is opened.


Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
