From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH] rtlwifi: Fix Kconfig for some corner cases
Date: Sun, 7 Jul 2013 10:42:31 +0100
Message-ID: <1373190151.3428.13.camel@deadeye.wl.decadent.org.uk>
References: <1373165244-9536-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1373165244-9536-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-07-06 at 21:47 -0500, Larry Finger wrote:
> Fengguang Wu reported the following errors in the build of rtlwifi with
> a random configuration:
> 
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux master
> head:   bcd7351e83728859833e3c5b8aae9a2816914e4b
> commit: 06e7cda3ce30dadc3454539127b4cfc3888c349e rtlwifi: Rework Kconfig
> date:   5 months ago
> config: i386-randconfig-s05-0703
> 
>    drivers/built-in.o: In function `rtl_usb_cleanup':
>    usb.c:(.text+0x114895): undefined reference to `usb_kill_anchored_urbs'
>    usb.c:(.text+0x114964): undefined reference to `usb_kill_anchored_urbs'
>    usb.c:(.text+0x11497c): undefined reference to `usb_kill_anchored_urbs'
>    drivers/built-in.o: In function `_usb_writeN_sync':
>    usb.c:(.text+0x114c9e): undefined reference to `usb_control_msg'
>    drivers/built-in.o: In function `rtl_usb_disconnect':
>    (.text+0x114d9c): undefined reference to `usb_put_dev'
>    drivers/built-in.o: In function `rtl_usb_start':
>    usb.c:(.text+0x114fb0): undefined reference to `usb_alloc_urb'
>    usb.c:(.text+0x115049): undefined reference to `usb_free_urb'
> --snip--
> 
> Although I could not duplicate this result on my machine, it seemed likely
> that it was due to the unusual configuration where rtlwifi was being built,
> but none of its dependent drivers were selected.

I think it just requires:

CONFIG_USB=m
CONFIG_RTLWIFI=y

> The fix is to select rtlwifi only when it is needed.

I don't think so.  Consider this configuration:

CONFIG_PCI=y
CONFIG_USB=m
CONFIG_RTL_CARDS=y
CONFIG_RTL8192CE=y
CONFIG_RTL8192CU=m
CONFIG_RTLWIFI=y     # maximum of RTL8192CE=y and RTL8192CU=m

The same breakage occurs.

> While making this
> change, I simplified the configuration so that variable RTLWIFI is never seen
> by the user.
[...]

This will break existing configurations as RTL_CARDS defaults to n.

Perhaps you should introduce separate modules for the common PCI and USB
support code, similarly to how the rt2x00 modules are organised.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
