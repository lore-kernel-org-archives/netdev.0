From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH] usbnet: rx_submit() should return an error code.
Date: Tue, 10 Aug 2010 09:42:05 +0200
Message-ID: <201008100942.05887.oneukum@suse.de>
References: <AANLkTimubaXzLjROeaNB0dV09thKfpLDyaEA-t_yzyV1@mail.gmail.com> <20100810.001855.179947437.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: ellyjones-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jglasgow-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100810.001855.179947437.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Dienstag, 10. August 2010, 09:18:55 schrieb David Miller:
> From: Elly Jones <ellyjones-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Date: Mon, 9 Aug 2010 18:37:50 -0400
> 
> > This patch makes rx_submit() return an error code, and makes some call sites
> > that care check the return value. This is important because it lets us properly
> > handle cases where the device isn't ready to handle URB submissions (e.g., when
> > it is autosuspended under some drivers); previously, we would attempt and fail
> > to submit URBs and reschedule ourselves to try and fail again. This patch is
> > against Linus's 2.6 repo commit 45d7f32c7a43cbb9592886d38190e379e2eb2226.
> > 
> > Signed-Off-By: Elizabeth Jones <ellyjones-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> What gets kevent() running again to run the rx_submit() calls when the
> device comes back from being suspended?
> 

usbnet_resume() schedules usbnet_bh() which will take care of that.

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
