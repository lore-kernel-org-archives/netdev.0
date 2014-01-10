From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: PROBLEM: usbnet / ax88179_178a: Panic in usb_hcd_map_urb_for_dma
Date: Fri, 10 Jan 2014 23:09:08 +0100
Message-ID: <87ob3j1ocb.fsf@nemi.mork.no>
References: <CAHNSM4Kv5gcJn=H4k8QjPggWzjF0zRm_t_icAYXjCTqXx4xL2w@mail.gmail.com>
	<1389385824.2025.95.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Kear <thomas-hrxM1pTBpuF02iOg2JU2CQ@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1389385824.2025.95.camel-/LGg1Z1CJKQ+9kgCwbf1HqK4ta4zdZpAajtMo4Cw6ucAvxtiuMwx3w@public.gmane.org> (Ben
	Hutchings's message of "Fri, 10 Jan 2014 20:30:24 +0000")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org> writes:
> On Sat, 2014-01-11 at 08:56 +1300, Thomas Kear wrote:
>> USB3 gigabit ethernet adapters with the ASIX AX88179 chipset (LevelO=
ne
>> USB0401-V3, Plugable USB3-E1000, SIIG JU-NE0211-S1 and others) are
>> experiencing kernel panics in usb_hcd_map_urb_for_dma since 3.12.
> [...]
>> So far as I can tell, the driver is unaffected as late as 3.11.6, bu=
t
>> problematic as of 3.12 (and still affected in 3.13-rc5).  The histor=
y
>> of drivers/net/usb/ax88179_178a.c for this time period yields this
>> patch, which at least in my somewhat limited understanding appeared =
a
>> likely candidate.  I've reverted this on my system - against several
>> linux-next builds from the last 3-4 weeks - and have had no issues
>> with this network controller since.
>>=20
>> commit 3804fad45411b48233b48003e33a78f290d227c8
>> Author: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>> Date:   Thu Aug 8 21:48:25 2013 +0800
>>=20
>>     USBNET: ax88179_178a: enable tso if usb host supports sg dma
>
> Enabling SG DMA here has unfortunately caused a number of regressions=
 as
> the XHCI (USB 3 controller) hardware is a bit inflexible and the driv=
er
> wasn't quite ready to handle the SG lists generated for net devices.
>
> I don't think I've seen this particular symptom though, and it might
> indicate a bug in usbnet.

Yes, I believe this code in usbnet is still somewhat unmature and not
much tested.  Unfortunately I don't have any PC with xhci, so I can't d=
o
much about that.

But looking at the code I think I found and obvious miss in the SG list
initialisation.  I'll post a proposed fix for that.  Would be good if
someone was able to test it.



Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
