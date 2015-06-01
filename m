From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [cdc_ncm] guidance and help refactoring cdc_ncm
Date: Mon, 1 Jun 2015 08:53:36 +0200 (CEST)
Message-ID: <alpine.LNX.2.20.1506010818110.3158@localhost.localdomain>
References: <alpine.LNX.2.20.1505311628420.16456@localhost.localdomain> <20150601005917.GB5320@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150601005917.GB5320-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Greg, hello everyone reading.
I am sorry If I wasn't specific enough - I'll be this time! :) Or I try at 
least.

On Mon, 1 Jun 2015, Greg KH wrote:

==Date: Mon, 1 Jun 2015 02:59:17
==From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
==To: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
==Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
==    Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
==Subject: Re: [cdc_ncm] guidance and help refactoring cdc_ncm
==
==On Sun, May 31, 2015 at 04:37:11PM +0200, Enrico Mioso wrote:
==> Hello guys.
==> I am writing to you all to ask for help and assistance in refactoring the
==> cdc_ncm driver to support newer devices.
==> In particular - I would need step-by-step guidance in doing this: or any
==> other kind of help would be anyway greatly apreciated.
==> 
==> 1 - What we need:
==>   We would need to refactor the driver to be able to re-order parts of the NCM
==>   package itself.
==>   In particular, being a single NCM frame composed of different parts, we would
==>   need more flexibility in changing their order.
==
==Do you have hardware that needs this now?  What exactly needs to be done
==here that currently doesn't work?

yes - there is hardware that curently doesn't work with the actual code.
In particular, I am referring to Huawei 3G / 4G modems:
- Huawei E3131: will not work with some firmware versions, works with others / 
  olders ones
- Huawei E3372 (LTE modem): will not work.

I received various mail messages from people trying to configure different 
devices that aren't working: and partly the situation is confusing since 
sometimes devices with very similar product names are pretty different, or 
derive from different hardware branches.

Regarding what needs to be done: it's important to note that those devices 
follow an USB specification.
the network control Model spec as found here:
http://www.usb.org/developers/docs/devclass_docs/NCM10_012011.zip
aims to provide more efficient netowkring over USB solutions, batching frames 
for example.
The fundamental packet unit here is the "NCM Package": which can hold more 
ethernet-style frames in it. The device and the host will negotiate once 
appropriate some frame characteristics.

The specification doesn't mandate where some parts of the package should be 
placed: infact, they can be put in somewhat arbitrary places.

This is true for the NDP part: we actually as I understand it, are putting it 
near the beginning of the frame.
Some Huawei devices, started to mandate it to be at the end of it, ignoring the 
frame otherwise.

==
==> 2 - What might be nice
==>   To do so, it would be nice to have the driver queue up frames, sending them
==>   out as needed. this already happens to a certain extent, but the NCM package
==>   is created in the process and updated in the while as I understood the code.
==>   The best thing would be to have the NCM package created only before sending
==>   it out, to achieve for best performance and code readability.
==
==Would this really make things faster?

Probably it would, depending on the setup we are considering. Considering a 
standard setup where those devices are being connected to a laptop or a PC with 
relatively high resources, this would not make so much difference.
But it's not so unusual to see these devices running coupled with small 
devices: and here this could make the difference in some cases.
But this would not be my main goal: getting things working faster is good, but 
I would like just to see them working now: and so I am trying to gather help / 
information / guidance / code in general so in case I might try if needed in 
the future.

==
==> I already contactedprivately some of you to have some more insight on what
==> needs to be done, and to understand better how to organize the effort. I
==> unfortunately miss the time to do this right now: and infact I can't even be
==> sure to be able to do this, due to various problems (my tesis, my life in
==> general).
==> But gathering more informations and in general trying to get some help is
==> the best thing I feel like doing right now.
==> 
==> The compelling reasons I find for trying to fix the situation are:
==> 1 - The fact these drivers are used in different products integrating or
==>   interfacing with 3G/4G technologies.
==
==Is there hardware that has out-of-tree drivers that implement what you
==are referring to here?  Or does someone just want this to make the
==hardware work "better"?
==
==I think we need more specifics before being able to determine exactly
==what needs to be done.
==
==thanks,
==
==greg k-h
==
Thank you Greg for your precious help.

Once again - some devices will just not work.

There is an out-of-tree vendor driver implementing what I am referring to: it 
contains code to work with many different devices from Huawei, but only the NCM 
related parts would be of use in this scenario. Other devices are already 
supported and working in the kernel.
the driver can be found here:
https://dl.dropboxusercontent.com/u/15043728/ArchLinuxArm/huawei_ndis/ndis_src.tar.xz

it works with kernels up to 3.18. then it doesn't, since there are some 
problems with the power management (PM) code in here.
As can be seen, there is various code coming from usbnet and the linu ncm 
headers.

All the rest as I can see it, isn't so important: the specification talks about 
different possibilities we are not implementing currently, but I think we can 
live without them if no other devices requiring them gest created. It remains 
to be seen if at some point we'll need additional features. Actually we are 
anyway deviating from the Huawei Windows driver, because we use 16-bit NCM 
while it uses the 32-bit version, we are not supporting CRC on frames and other 
things.
I think we can leave them out.
A 32-bit version of the driver (talking 32-bit NCM) is here:
http://www.gstorm.eu/cdc_ncm.c
I modified the original driver with the help of a very talented friend.
It works: but there seem to be no real reasons to implement this properly. We 
did this in a consistent effort to understand what was wrong, and here it is.
Thank you again guys for reading this messae.

Enrico
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
