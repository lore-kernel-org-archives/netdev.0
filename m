From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: PROBLEM: usbnet / ax88179_178a: Panic in usb_hcd_map_urb_for_dma
Date: Fri, 10 Jan 2014 20:30:24 +0000
Message-ID: <1389385824.2025.95.camel@bwh-desktop.uk.level5networks.com>
References: <CAHNSM4Kv5gcJn=H4k8QjPggWzjF0zRm_t_icAYXjCTqXx4xL2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Thomas Kear <thomas-hrxM1pTBpuF02iOg2JU2CQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAHNSM4Kv5gcJn=H4k8QjPggWzjF0zRm_t_icAYXjCTqXx4xL2w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2014-01-11 at 08:56 +1300, Thomas Kear wrote:
> USB3 gigabit ethernet adapters with the ASIX AX88179 chipset (LevelOne
> USB0401-V3, Plugable USB3-E1000, SIIG JU-NE0211-S1 and others) are
> experiencing kernel panics in usb_hcd_map_urb_for_dma since 3.12.
[...]
> So far as I can tell, the driver is unaffected as late as 3.11.6, but
> problematic as of 3.12 (and still affected in 3.13-rc5).  The history
> of drivers/net/usb/ax88179_178a.c for this time period yields this
> patch, which at least in my somewhat limited understanding appeared a
> likely candidate.  I've reverted this on my system - against several
> linux-next builds from the last 3-4 weeks - and have had no issues
> with this network controller since.
> 
> commit 3804fad45411b48233b48003e33a78f290d227c8
> Author: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Date:   Thu Aug 8 21:48:25 2013 +0800
> 
>     USBNET: ax88179_178a: enable tso if usb host supports sg dma

Enabling SG DMA here has unfortunately caused a number of regressions as
the XHCI (USB 3 controller) hardware is a bit inflexible and the driver
wasn't quite ready to handle the SG lists generated for net devices.

I don't think I've seen this particular symptom though, and it might
indicate a bug in usbnet.

[...]
> [2] http://i.imgur.com/NCanPUY.jpg

For those joining us on linux-usb, this is a photo of the panic.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
